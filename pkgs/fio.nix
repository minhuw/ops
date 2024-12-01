# default.nix
{ pkgs ? import <nixpkgs> {} }:

let
  fio-test-script = pkgs.writeScriptBin "fio-test" ''
    #!${pkgs.bash}/bin/bash

    # Exit on error, undefined variables, and pipe failures
    set -euo pipefail

    # Default values
    TEST_DIR="/tmp/fio_test"
    DURATION=60
    FILE_SIZE="1G"
    NUM_JOBS=4
    OUTPUT_DIR="fio_results_$(date +%Y%m%d_%H%M%S)"
    SEQ_BS="1M"    # Sequential block size
    RAND_BS="4K"   # Random block size

    # Function to display usage
    usage() {
        echo "Usage: $0 [-d test_directory] [-t duration] [-s file_size] [-j num_jobs] [-o output_directory] [-b seq_blocksize] [-r rand_blocksize]"
        echo "Options:"
        echo "  -d: Directory to perform the test (default: /tmp/fio_test)"
        echo "  -t: Test duration in seconds (default: 60)"
        echo "  -s: File size for test, e.g., 1G, 500M (default: 1G)"
        echo "  -j: Number of parallel jobs (default: 4)"
        echo "  -o: Output directory name (default: fio_results_timestamp)"
        echo "  -b: Sequential operations block size (default: 1M)"
        echo "  -r: Random operations block size (default: 4K)"
        echo
        echo "Block size examples: 4K, 8K, 64K, 128K, 1M, 2M"
        exit 1
    }

    # Parse command line options
    while getopts "d:t:s:j:o:b:r:h" opt; do
        case $opt in
            d) TEST_DIR="$OPTARG" ;;
            t) DURATION="$OPTARG" ;;
            s) FILE_SIZE="$OPTARG" ;;
            j) NUM_JOBS="$OPTARG" ;;
            o) OUTPUT_DIR="$OPTARG" ;;
            b) SEQ_BS="$OPTARG" ;;
            r) RAND_BS="$OPTARG" ;;
            h) usage ;;
            ?) usage ;;
        esac
    done

    # Validate block sizes
    validate_blocksize() {
        local bs="$1"
        local name="$2"
        if ! [[ "$bs" =~ ^[0-9]+[KMG]$ ]]; then
            echo "Error: Invalid $name block size format: $bs"
            echo "Expected format: <number>[K|M|G] (e.g., 4K, 1M, 2G)"
            exit 1
        fi
    }

    validate_blocksize "$SEQ_BS" "sequential"
    validate_blocksize "$RAND_BS" "random"

    # Create test and output directories
    mkdir -p "$TEST_DIR" "$OUTPUT_DIR"

    # Create FIO job file
    cat > "$OUTPUT_DIR/io_test.fio" << EOF
    [global]
    ioengine=libaio
    direct=1
    group_reporting=1
    time_based=1
    runtime=$DURATION
    size=$FILE_SIZE
    directory=$TEST_DIR
    
    [sequential-write]
    description=Sequential write test with $SEQ_BS blocks
    rw=write
    bs=$SEQ_BS
    iodepth=64
    numjobs=$NUM_JOBS
    filename=seq_write_test_file
    stonewall

    [sequential-read]
    description=Sequential read test with $SEQ_BS blocks
    rw=read
    bs=$SEQ_BS
    iodepth=64
    numjobs=$NUM_JOBS
    filename=seq_read_test_file
    stonewall

    [random-write]
    description=Random write test with $RAND_BS blocks
    rw=randwrite
    bs=$RAND_BS
    iodepth=32
    numjobs=$NUM_JOBS
    filename=rand_write_test_file
    stonewall

    [random-read]
    description=Random read test with $RAND_BS blocks
    rw=randread
    bs=$RAND_BS
    iodepth=32
    numjobs=$NUM_JOBS
    filename=rand_read_test_file
    stonewall
    EOF

    echo "Starting FIO I/O performance test..."
    echo "Test directory: $TEST_DIR"
    echo "Duration: $DURATION seconds"
    echo "File size: $FILE_SIZE"
    echo "Number of jobs: $NUM_JOBS"
    echo "Sequential block size: $SEQ_BS"
    echo "Random block size: $RAND_BS"
    echo "Results will be saved in: $OUTPUT_DIR"
    echo

    # Run FIO test and show output directly
    ${pkgs.fio}/bin/fio "$OUTPUT_DIR/io_test.fio" | tee "$OUTPUT_DIR/detailed_results.txt"

    # Cleanup
    echo -e "\nCleaning up test files..."
    rm -f "$TEST_DIR"/*_test_file

    echo "Test completed successfully!"
  '';
in
pkgs.symlinkJoin {
  name = "fio-test";
  paths = [
    fio-test-script
    pkgs.fio
    pkgs.coreutils
  ];
  buildInputs = [ pkgs.makeWrapper ];
  meta = with pkgs.lib; {
    description = "FIO read/write performance testing tool";
    platforms = platforms.unix;
    license = licenses.mit;
  };
}