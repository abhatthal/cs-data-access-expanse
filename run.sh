#!/bin/bash                                                                        
# run.sh - Hardcoded input variables for testing the workflow                      
                                                                                   
#SBATCH --job-name=cs_data_access     # Name of the job shown in squeue            
#SBATCH --nodes=1                     # Mandate allocation on exactly ONE node  
#SBATCH --ntasks-per-node=1           # Number of tasks/processes to run on that node
#SBATCH --cpus-per-task=4             # Request multiple CPU cores if your script is multi-threaded
#SBATCH --mem=8G                      # Request 8 Gigabytes of RAM for the node 
#SBATCH --time=00:30:00               # Time limit (HH:MM:SS) - 30 minutes         
#SBATCH --output=job_out_%j.txt       # Standard output file (%j expands to JobID)
#SBATCH --error=job_err_%j.txt        # Standard error file                        
                                                                                   
#SBATCH --account=usc143                                                           
#SBATCH --exclude=exp-12-44                                                        
#SBATCH --partition debug                                                          
                                                                                   
# Package is called `singularitypro` on SDSC Expanse. Names vary across HPC systems.
module load singularitypro

# Fail the job if any stage fails (input_gen or retrieve_cs_data).
set -euo pipefail

# --- Hardcoded test input ---------------------------------------------------
IMAGE="cs_data_tutorial.sif"    # Pulled by get_img.sh (sceccode/cs_data_tutorial)
MODEL="Study 22.12 LF"
PRODUCT="Site Info"
FILTER="SITE_NAME=USC"
OUTPUT_DIR="./out"
TEMP_DIR="./tmp"
# -----------------------------------------------------------------------------

mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"

echo "Running request: model='$MODEL' product='$PRODUCT' filter='$FILTER'"

# The tools live in /home/cs_data_user inside the image, and the image's
# filesystem is read-only under Singularity, so:
#   - cd into the image's home directory inside the container (singularity
#     exec does NOT start in the image's WORKDIR), and
#   - bind-mount host directories for the output and temp paths (the
#     "-B .:/home/cs_data_user/output" pattern), since results must be
#     written to the host's scratch space.
CONTAINER_HOME="/home/cs_data_user"
HOST_BINDS="--bind $PWD/$OUTPUT_DIR:$CONTAINER_HOME/output --bind $PWD/$TEMP_DIR:$CONTAINER_HOME/tmp"

# input_gen validates the request and writes the request JSON to stdout
# (human-readable summary goes to stderr); retrieve_cs_data reads it from
# stdin via '-i -', per the cs-data-tools docs:
#   src/input_gen/run_input_gen.py -m "Study 22.12 LF" -p "Site Info" \
#       --filter SITE_NAME=USC | src/retrieve_cs_data.py -i - -o ./out -t ./tmp
singularity exec $HOST_BINDS "$IMAGE" bash -c "cd $CONTAINER_HOME && python3 src/input_gen/run_input_gen.py -m '$MODEL' -p '$PRODUCT' --filter '$FILTER'" \
  | singularity exec $HOST_BINDS "$IMAGE" bash -c "cd $CONTAINER_HOME && python3 src/retrieve_cs_data.py -i - -o $CONTAINER_HOME/output -t $CONTAINER_HOME/tmp"

echo "Done. Results are in $OUTPUT_DIR"
