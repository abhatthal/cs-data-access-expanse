#!/bin/bash
# osp_run.sh - Script executed by Quakeworx app, processes user input and runs app

# Tapis/Quakeworx provides the job environment; tolerate local testing without it.
if [ -f ./tapisjob.env ]; then
    source ./tapisjob.env
fi

# Package is called `singularitypro` on SDSC Expanse. Names vary across HPC systems.
module load singularitypro

# Fail the job if any stage fails (input_gen or retrieve_cs_data).
set -euo pipefail

# Shared SIF image, pulled once by get_img.sh into the Quakeworx apps directory
# (read-only squashfs; safe for concurrent jobs/users, so no per-user copy needed).
IMAGE="/expanse/lustre/projects/usc143/qwxdev/apps/expanse/rocky8.8/cs-data-access/cs_data_tutorial.sif"
CONTAINER_HOME="/home/cs_data_user"
OUTPUT_DIR="./outputs"                          # persistent results (job dir)
TEMP_DIR="/scratch/$USER/job_$SLURM_JOBID/tmp"  # node-local NVMe, purged at job end

mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"

echo "Running request with parameters: $*"

# Output/temp paths are bind-mounted into the container (the image FS is
# read-only under singularity); the bind target is named "outputs" to match
# the host directory name.
HOST_BINDS="--bind $PWD/$OUTPUT_DIR:$CONTAINER_HOME/outputs --bind $TEMP_DIR:$CONTAINER_HOME/tmp"

# Forward the caller's parameters verbatim to input_gen. printf %q quotes each
# argument so values with spaces (e.g. "Study 22.12 LF") and repeated --filter
# flags survive the nested bash -c.
INPUT_GEN_ARGS=$(printf '%q ' "$@")

# Single container: the pipe between input_gen and retrieve_cs_data lives inside
# the one invocation. The nested bash -c needs its own pipefail (the outer
# 'set -euo pipefail' does not propagate into it); input_gen writes the request
# JSON to stdout (summary to stderr) and retrieve_cs_data reads it from stdin
# via '-i -', per the cs-data-tools docs.
singularity exec $HOST_BINDS "$IMAGE" bash -c "set -o pipefail; cd $CONTAINER_HOME && python3 cs-data-tools/src/input_gen/run_input_gen.py $INPUT_GEN_ARGS | python3 cs-data-tools/src/retrieve_cs_data.py -i - -o $CONTAINER_HOME/outputs -t $CONTAINER_HOME/tmp -c cs-data-tools/src/db_wrapper/carc.cfg"

echo "Done. Results are in $OUTPUT_DIR"