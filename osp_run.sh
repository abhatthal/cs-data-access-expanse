#!/bin/bash                                                                        
# osp_run.sh - Script executed by Quakeworx app, processes user input and runs app 
                                                                                   
source ./tapisjob.env                                                              
                                                                                
# Package is called `singularitypro` on SDSC Expanse. Names vary across HPC systems.
module load singularitypro                                                      
                                                                                
printf "Invoked command: %s" "$0" > out.txt                                        
printf " '%s'" "$@" >> out.txt                                                  
printf "\n" >> out.txt                                                             
