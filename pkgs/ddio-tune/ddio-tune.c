/*
 * Changing DDIO State
 *
 * Copyright (c) 2020, Alireza Farshin, KTH Royal Institute of Technology - All
 * Rights Reserved
 */

#include <fcntl.h>
#include <getopt.h>
#include <inttypes.h>
#include <pci/pci.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/io.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#define PCI_VENDOR_ID_INTEL 0x8086
#define SKX_PERFCTRLSTS_0 0x180
#define SKX_use_allocating_flow_wr_MASK 0x80
#define SKX_nosnoopopwren_MASK 0x8

/*
 * Find the proper pci device (i.e., PCIe Root Port) based on the nic device
 * For instance, if the NIC is located on 0000:17:00.0 (i.e., BDF)
 * 0x17 is the nic_bus (B)
 * 0x00 is the nic_device (D)
 * 0x0  is the nic_function (F)
 */

struct pci_access *pacc;

void init_pci_access(void) {
  pacc = pci_alloc(); /* Get the pci_access structure */
  pci_init(pacc);     /* Initialize the PCI library */
  pci_scan_bus(pacc); /* We want to get the list of devices */
}

struct pci_dev *find_ddio_device(uint8_t nic_bus) {
  struct pci_dev *dev;
  for (dev = pacc->devices; dev; dev = dev->next) {
    pci_fill_info(dev, PCI_FILL_IDENT | PCI_FILL_BASES | PCI_FILL_NUMA_NODE |
                           PCI_FILL_PHYS_SLOT);
    /*
     * Find the proper PCIe root based on the nic device
     * For instance, if the NIC is located on 0000:17:00.0 (i.e., BDF)
     * 0x17 is the nic_bus (B)
     * 0x00 is the nic_device (D)
     * 0x0  is the nic_function (F)
     * TODO: Fix this for Haswell, i.e., 03:00.0 -- Dev and Fun might be
     * different
     */
    if (/*dev->func == 0 && dev->dev == 0  && */ pci_read_byte(
            dev, PCI_SUBORDINATE_BUS) ==
        nic_bus /*&& dev->numa_node==1 && dev->domain==0x10001*/) {
      return dev;
    }
  }
  printf("Could not find the proper PCIe root!\n");
  return NULL;
}

/*
 * perfctrlsts_0
 * bit 3: NoSnoopOpWrEn -> Should be 1b
 * bit 7: Use_Allocating_Flow_Wr -> Should be 0b
 * Check p. 68 of IntelÂ® XeonÂ® Processor Scalable Family
 * Datasheet, Volume Two: Registers
 * May 2019
 * link:
 * https://www.intel.com/content/www/us/en/processors/xeon/scalable/xeon-scalable-datasheet-vol-2.html
 */
int ddio_status(uint8_t nic_bus) {
  uint32_t val;
  if (!pacc)
    init_pci_access();

  struct pci_dev *dev = find_ddio_device(nic_bus);
  if (!dev) {
    printf("No device found!\n");
    exit(1);
  }
  val = pci_read_long(dev, SKX_PERFCTRLSTS_0);
  printf("perfctrlsts_0 val: 0x%" PRIx32 "\n", val);
  printf("NoSnoopOpWrEn val: 0x%" PRIx32 "\n", val & SKX_nosnoopopwren_MASK);
  printf("Use_Allocating_Flow_Wr val: 0x%" PRIx32 "\n",
         val & SKX_use_allocating_flow_wr_MASK);
  if (val & SKX_use_allocating_flow_wr_MASK)
    return 1;
  else
    return 0;
}

void ddio_enable(uint8_t nic_bus) {
  uint32_t val;
  if (!pacc)
    init_pci_access();

  if (!ddio_status(nic_bus)) {
    struct pci_dev *dev = find_ddio_device(nic_bus);
    if (!dev) {
      printf("No device found!\n");
      exit(1);
    }
    val = pci_read_long(dev, SKX_PERFCTRLSTS_0);
    pci_write_long(dev, SKX_PERFCTRLSTS_0,
                   val | SKX_use_allocating_flow_wr_MASK);
    printf("DDIO is enabled!\n");
  } else {
    printf("DDIO was already enabled!\n");
  }
}

void ddio_disable(uint8_t nic_bus) {
  uint32_t val;
  if (!pacc)
    init_pci_access();

  if (ddio_status(nic_bus)) {
    struct pci_dev *dev = find_ddio_device(nic_bus);
    if (!dev) {
      printf("No device found!\n");
      exit(1);
    }
    val = pci_read_long(dev, SKX_PERFCTRLSTS_0);
    pci_write_long(dev, SKX_PERFCTRLSTS_0,
                   val & (~SKX_use_allocating_flow_wr_MASK));
    printf("DDIO is disabled!\n");
  } else {
    printf("DDIO was already disabled\n");
  }
}

void print_dev_info(struct pci_dev *dev) {
  if (!dev) {
    printf("No device found!\n");
    exit(1);
  }
  unsigned int c;
  char namebuf[1024], *name;
  printf("========================\n");
  printf("%04x:%02x:%02x.%d vendor=%04x device=%04x class=%04x irq=%d (pin %d) "
         "base0=%lx \n",
         dev->domain, dev->bus, dev->dev, dev->func, dev->vendor_id,
         dev->device_id, dev->device_class, dev->irq, c,
         (long)dev->base_addr[0]);
  name = pci_lookup_name(pacc, namebuf, sizeof(namebuf), PCI_LOOKUP_DEVICE,
                         dev->vendor_id, dev->device_id);
  printf(" (%s)\n", name);
  printf("========================\n");
}

int main(int argc, char *argv[]) {
  int opt;
  unsigned int bus_value = 0;
  bool bus_given = false;
  bool enabled = false;

  struct option long_options[] = {{"bus", required_argument, 0, 'b'},
                                  {"enabled", no_argument, 0, 'e'},
                                  {"disabled", no_argument, 0, 'd'},
                                  {0, 0, 0, 0}};

  while ((opt = getopt_long(argc, argv, "b:ed", long_options, NULL)) != -1) {
    switch (opt) {
    case 'b':
      bus_value = (unsigned int)strtol(optarg, NULL, 16);
      bus_given = true;
      break;
    case 'e':
      enabled = true;
      break;
    case 'd':
      enabled = false;
      break;
    default:
      fprintf(stderr, "Usage: %s --bus <hex_value> [--enabled | --disabled]\n",
              argv[0]);
      exit(EXIT_FAILURE);
    }
  }

  if (!bus_given) {
    fprintf(stderr, "Error: --bus option is required.\n");
    fprintf(stderr, "Usage: %s --bus <hex_value> [--enabled | --disabled]\n",
            argv[0]);
    exit(EXIT_FAILURE);
  }

  init_pci_access();

  /* Define nic_bus and ddio_state */
  uint8_t nic_bus = bus_value, ddio_state = enabled;

  struct pci_dev *dev = find_ddio_device(nic_bus);
  print_dev_info(dev);

  if (ddio_state) {
    ddio_enable(nic_bus);
  } else {
    ddio_disable(nic_bus);
  }

  pci_cleanup(pacc); /* Close everything */
  return 0;
}