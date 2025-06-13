#!/bin/bash

: '
  FLAMEGPU2 Agent-Based Model

  generate_configuration.sh

  Generate the configuration file of a specific scenario of the ABM.

  Inputs:
      -expdir or --experiment_dir:          directory with the scenario to simulate
      -e      or --ensemble:                run with ensemble
      -cps    or --checkpoint_simulation:   run the model in a simplified version with the aim to obtain a checkpoint

  Authors: Daniele Baccega, Irene Terrone, Simone Pernice
'

# Default values for input parameters
EXPERIMENT_DIR="None"
ENSEMBLE="OFF"
CHECKPOINT_SIMULATION="OFF"

while [[ $# -gt 0 ]]; do
  case $1 in
    -expdir|--experiment_dir)
      EXPERIMENT_DIR="$2"
      shift
      shift
      ;;
    -cps|--checkpoint_simulation)
      CHECKPOINT_SIMULATION="$2"
      shift
      shift
      ;;
    -e|--ensemble)
      ENSEMBLE="$2"
      shift
      shift
      ;;
    -h|--help)
  	  printf "./run.sh - run the ABM\n\n"
  	  printf "Arguments:\n"
      printf "        -expdir or --experiment_dir:          directory with the scenario to simulate\n"
      printf "        -e      or --ensemble:                run with ensemble (default: OFF; possible values: ON, OFF)\n"
      printf "        -cps    or --checkpoint_simulation:   run the model in a simplified version with the aim to obtain a checkpoint (default: OFF; possible values: ON, OFF)"
      exit 1
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1")   # Save positional arg
      shift                     # Past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}"  # Restore positional parameters

DIR="resources/f4f/$EXPERIMENT_DIR"

# Check if the directory exists
if [ ! -d "$DIR" ]; then
    echo "❌ Error: Directory $DIR does not exist."
    exit 1
fi

# Generate the XML file
cd resources
python3 CreateMapEncoding.py -dirname_experiment $EXPERIMENT_DIR
python3 generate_xml.py -dirname_experiment $EXPERIMENT_DIR -ensemble $ENSEMBLE -checkpoint $CHECKPOINT_SIMULATION
cd ..

awk 'NR > 1 {
    if ($2 == "CPOINT" || $2 == "DOOR") {
        next
    } 
    if (NF == 3 || NF == 1) {
        next
    } 
    if (NF == 5) {
        print $1, $3+1, $4, $5+1
    } 
}' resources/G.txt > results/$EXPERIMENT_DIR/rooms_mapping.txt