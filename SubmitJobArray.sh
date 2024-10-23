#!/bin/bash

#SBATCH --job-name=o2-AF-bench  # Task name
#SBATCH --array=1-100

#SBATCH --chdir=/lustre/alice/users/jwilkins/VirgoIntro/initJobScript       # Working directory on shared storage
#SBATCH --time=480 # Run time limit in minutes
#SBATCH --mem=8G   # job memory
#SBATCH --cpus-per-task=2  # cpus per task
#SBATCH --partition=main   # job partition (debug, main)
#SBATCH -o %a/job.out      # Standard and error output in different files
#SBATCH -e %a/job.err      # "%a" means the wtory = the array number


# the following line moves the job into the folder for the array ID - DO NOT REMOVE!! 
cd $SLURM_ARRAY_TASK_ID



# edit the path to your singularity shell as needed
singularity shell -B /cvmfs -B /lustre  /lustre/alice/singularity/singularity_base_o2compatibility.sif <<\EOF
export JALIEN_TOKEN_CERT=/lustre/alice/users/jwilkins/token/tokencert_6873.pem
export JALIEN_TOKEN_KEY=/lustre/alice/users/jwilkins/token/tokenkey_6873.pem
source /cvmfs/alice.cern.ch/etc/login.sh
alienv enter O2Physics::nightly-20230308-1

# YOUR O2 WORKFLOW HERE, using --configuration json://../configuration.json and --aod-file @input_data.txt
# The following line is an example:
o2-analysis-pid-tpc-full -b --configuration json://../configuration.json | o2-analysis-timestamp -b --configuration json://../configuration.json | o2-analysis-event-selection -b --configuration json://../configuration.json | o2-analysis-pid-tpc-base -b --configuration json://../configuration.json | o2-analysis-pid-tpc-qa -b --configuration json://../configuration.json --aod-file @input_data.txt



EOF


