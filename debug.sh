#!/bin/bash
# debug.sh - Opens an interactive shell inside the cs_data_tutorial container
#
# Run this script directly from the login node:  ./debug.sh
# Do NOT submit it with sbatch - an interactive session cannot run as a batch
# job. Instead, the script requests a Slurm allocation (salloc) and drops you
# into the container shell on a compute node via srun --pty.
#
# `singularity shell` is the Singularity equivalent of `docker run -it`: it
# gives an interactive session where you can navigate inside the container.
# Type `exit` to leave the container, then `exit` again to end the allocation.

IMAGE="cs_data_tutorial.sif"    # Pulled by get_img.sh (sceccode/cs_data_tutorial)

salloc \
    --account=usc143 \
    --partition=debug \
    --exclude=exp-12-44 \
    --nodes=1 \
    --ntasks-per-node=1 \
    --cpus-per-task=4 \
    --mem=8G \
    --time=00:30:00 \
    srun --pty bash -lc "
      module load singularitypro
      echo \"Interactive container session. Exit twice to leave (container, then allocation).\"
      singularity shell '$IMAGE'
    "