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

# osp_run.sh loads singularitypro itself and forwards our arguments verbatim to
# the container pipeline (input_gen -> retrieve_cs_data), writing to ./outputs.
./osp_run.sh -m "Study 22.12 LF" -p "Site Info" --filter SITE_NAME=USC