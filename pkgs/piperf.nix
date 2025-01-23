# default.nix
{ pkgs ? import <nixpkgs> {} }:

let
piperf = pkgs.writeScriptBin "piperf" ''
  #!${pkgs.bash}/bin/bash

  set -euo pipefail

  # Default values
  START_PORT=5201
  NUM_INSTANCES=4
  SERVER_IP="localhost"
  BIND_IP="0.0.0.0"
  DURATION=30
  MODE="client"  # can be "server" or "client"
  WINDOW_SIZE=""
  BUFFER_SIZE=""
  LENGTH=""
  EXTRA_ARGS=""
  FQ_RATE=""
  WORKING_DIR="$(pwd)"
  CPU_CORES=""  # Comma-separated list of CPU cores
  IPERF_BIN="${pkgs.iperf3}/bin/iperf3"  # Default iperf3 binary path
  CONTROL_FD=""  # Control file descriptor for first instance

  # Help function
  show_help() {
      echo "Usage: $0 [--server <BIND_IP>|--client SERVER_IP] [OPTIONS]"
      echo "Options:"
      echo "  --help                Show this help message"
      echo "  --server BIND_IP      Run in server mode"
      echo "  --client SERVER_IP    Run in client mode (specify server IP)"
      echo "  --port PORT           Starting port number (default: 5201)"
      echo "  --instances NUM       Number of parallel instances (default: 4)"
      echo "  --time SECONDS        Test duration in seconds (default: 30)"
      echo "  --window SIZE         Set window size (optional, format: n[KMG])"
      echo "  --buffer SIZE         Set buffer length (optional, format: n[KMG])"
      echo "  --fqrate RATE         Set FQ rate (optional, format: n[KMG])"
      echo "  --length BYTES        Set test length in bytes (optional, format: n[KMG])"
      echo "  --directory PATH      Set working directory (default: current directory)"
      echo "  --affinity CORES      Comma-separated list of CPU cores to use (e.g., '0,2,4,6')"
      echo "  --iperf PATH          Path to iperf3 binary (default: $IPERF_BIN)"
      echo "  --control-fd FD       Control file descriptor (only applies to first instance)"
      echo "  --extra-args EXTRA    Extra arguments"
  }

  # Use enhanced getopt
  if ! ARGS=$(${pkgs.util-linux}/bin/getopt -o h \
      --long help,server:,client:,port:,instances:,time:,window:,buffer:,fqrate:,length:,directory:,affinity:,iperf:,control-fd:,extra-args: \
      -n "$0" -- "$@"); then
      echo "Error parsing arguments" >&2
      exit 1
  fi

  eval set -- "$ARGS"

  # Parse command line arguments
  while true; do
      case "$1" in
          --help|-h)
              show_help
              shift
              ;;
          --server)
              MODE="server"
              BIND_IP="$2"
              shift 2
              ;;
          --client)
              MODE="client"
              SERVER_IP="$2"
              shift 2
              ;;
          --port)
              START_PORT="$2"
              shift 2
              ;;
          --instances)
              NUM_INSTANCES="$2"
              shift 2
              ;;
          --time)
              DURATION="$2"
              shift 2
              ;;
          --window)
              WINDOW_SIZE="$2"
              shift 2
              ;;
          --buffer)
              BUFFER_SIZE="$2"
              shift 2
              ;;
          --fqrate)
              FQ_RATE="$2"
              shift 2
              ;;
          --length)
              LENGTH="$2"
              shift 2
              ;;
          --directory)
              WORKING_DIR="$2"
              shift 2
              ;;
          --affinity)
              CPU_CORES="$2"
              shift 2
              ;;
          --iperf)
              IPERF_BIN="$2"
              shift 2
              ;;
          --control-fd)
              CONTROL_FD="$2"
              shift 2
              ;;
          --extra-args)
              EXTRA_ARGS="$2"
              shift 2
              ;;
          --)
              shift
              break
              ;;
          *)
              echo "Invalid option: $1" >&2
              show_help
              ;;
      esac
  done

  # Convert comma-separated CPU cores to array
  if [ -n "$CPU_CORES" ]; then
      IFS=',' read -ra CORE_ARRAY <<< "$CPU_CORES"
      if [ "''${#CORE_ARRAY[@]}" -lt "$NUM_INSTANCES" ]; then
          echo "Warning: Fewer CPU cores specified than instances. Some instances will share cores."
      fi
  fi

  # Verify and create working directory if it doesn't exist
  if [ ! -d "$WORKING_DIR" ]; then
      mkdir -p "$WORKING_DIR" || { echo "Error: Cannot create working directory $WORKING_DIR"; exit 1; }
  fi
  cd "$WORKING_DIR" || { echo "Error: Cannot change to working directory $WORKING_DIR"; exit 1; }

  # Function to run iperf3 server instances
  run_servers() {
      for ((i=0; i<NUM_INSTANCES; i++)); do
          port=$((START_PORT + i))
          result_file="$WORKING_DIR/iperf-$i.json"
          echo "Starting iperf3 server on port $port"
          cmd="$IPERF_BIN -s -1 -p $port -J --logfile $result_file"
          
          # Apply CPU affinity if cores are specified
          if [ -n "$CPU_CORES" ]; then
              core_index=$((i % ''${#CORE_ARRAY[@]}))
              core=''${CORE_ARRAY[$core_index]}
              echo "Pinning iperf3 server instance $i to CPU core $core"
              cmd="$cmd -A $core"
          fi

          if [ -n "$BIND_IP" ]; then
              cmd="$cmd --bind $BIND_IP"
          fi

          cmd="$cmd -- "

          # Add control-fd option only to first instance
          if [ $i -eq 0 ] && [ -n "$CONTROL_FD" ]; then
              cmd="$cmd --control-fd $CONTROL_FD"
          fi

          cmd="$cmd -- $EXTRA_ARGS"

          echo "$cmd"
          
          $cmd &
      done
      
      # Wait for Ctrl+C
      echo "All servers started. Press Ctrl+C to stop..."
      wait
  }

  # Function to run iperf3 client instances
  run_clients() {
      # Start all client instances
      for ((i=0; i<NUM_INSTANCES; i++)); do
          port=$((START_PORT + i))
          result_file="$WORKING_DIR/iperf-$i.json"
          echo "Starting iperf3 client connecting to $SERVER_IP:$port"
          cmd="$IPERF_BIN -c $SERVER_IP -p $port -t $DURATION -J --logfile $result_file"
          [[ -n "$WINDOW_SIZE" ]] && cmd="$cmd -w $WINDOW_SIZE"
          [[ -n "$BUFFER_SIZE" ]] && cmd="$cmd -l $BUFFER_SIZE"
          [[ -n "$LENGTH" ]] && cmd="$cmd -n $LENGTH"
          [[ -n "$FQ_RATE" ]] && cmd="$cmd --fq-rate $FQ_RATE"

          # Apply CPU affinity if cores are specified
          if [ -n "$CPU_CORES" ]; then
              core_index=$((i % ''${#CORE_ARRAY[@]}))
              core=''${CORE_ARRAY[$core_index]}
              echo "Pinning iperf3 client instance $i to CPU core $core"
              cmd="$cmd -A $core"
          fi
          
          cmd="$cmd -- "

          # Add control-fd option only to first instance
          if [ $i -eq 0 ] && [ -n "$CONTROL_FD" ]; then
              cmd="$cmd --control-fd $CONTROL_FD"
          fi

          cmd="$cmd -- $EXTRA_ARGS"

          echo "$cmd"
          
          eval "$cmd" &
      done
      
      # Wait for all client processes to finish
      wait
      
      echo "Tests completed. Results saved in $WORKING_DIR/"
  }

  # Main execution
  echo "Running iperf3 with:"
  echo "Mode: $MODE"
  echo "Starting Port: $START_PORT"
  echo "Number of Instances: $NUM_INSTANCES"
  echo "Duration: $DURATION seconds"
  echo "Working Directory: $WORKING_DIR"
  echo "iperf3 Binary: $IPERF_BIN"
  [[ $MODE == "client" ]] && echo "Server IP: $SERVER_IP"
  [[ -n "$WINDOW_SIZE" ]] && echo "Window Size: $WINDOW_SIZE"
  [[ -n "$BUFFER_SIZE" ]] && echo "Buffer Size: $BUFFER_SIZE"
  [[ -n "$LENGTH" ]] && echo "Test Length: $LENGTH"
  [[ -n "$CPU_CORES" ]] && echo "CPU Cores: $CPU_CORES"
  [[ -n "$CONTROL_FD" ]] && echo "Control FD: $CONTROL_FD (first instance only)"

  if [[ $MODE == "server" ]]; then
      run_servers
  else
      run_clients
  fi
'';
in
pkgs.symlinkJoin {
  name = "piperf";
  paths = [
    piperf
    pkgs.iperf3
    pkgs.coreutils
  ];
  buildInputs = [ pkgs.makeWrapper ];
  meta = with pkgs.lib; {
    description = "iperf networking performance testing tool";
    platforms = platforms.unix;
    license = licenses.mit;
  };
}