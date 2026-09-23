#!/bin/bash                                                                        
# get-img.sh - Gets the sceccode/cs_data_tutorial Docker image as an SIF           
                                                                                   
#SBATCH --job-name=get_cs_data_img    # Name of the job shown in squeue            
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
                                                                                   
# Download and convert the Docker image into a Singularity file (.sif)             
singularity pull cs_data_tutorial.sif docker://sceccode/cs_data_tutorial  
