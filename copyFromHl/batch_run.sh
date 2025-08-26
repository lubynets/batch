#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

source /lustre/alice/users/lubynets/.export_tokens.sh

export INDEX=${SLURM_ARRAY_TASK_ID}

export PROJECT_DIR=/lustre/alice/users/lubynets/ao2ds

export IO_PREFIX=alice/data/2023/LHC23zzo/545210/apass5/2020

export FILELIST=$PROJECT_DIR/filelist.list

export O2_CTF_DIR=$(head -n $INDEX $FILELIST | tail -n 1)

export FILE_NUMBER_1=$(((2*INDEX)-1))
export FILE_NUMBER_2=$((2*INDEX))

mkdir -p $PROJECT_DIR/log/jobs
cd $PROJECT_DIR/log/jobs

apptainer shell -B /lustre -B /scratch /lustre/alice/containers/singularity_base_o2compatibility.sif << \EOF
alienv -w /scratch/alice/lubynets/alice/sw enter O2::latest

alien_cp /$IO_PREFIX/$O2_CTF_DIR/001/AO2D.root file:$PROJECT_DIR/$IO_PREFIX/$O2_CTF_DIR/001/AO2D.root >& log_$FILE_NUMBER_1.txt
alien_cp /$IO_PREFIX/$O2_CTF_DIR/002/AO2D.root file:$PROJECT_DIR/$IO_PREFIX/$O2_CTF_DIR/002/AO2D.root >& log_$FILE_NUMBER_2.txt

EOF
# EOF to trigger the end of the singularity command

ln -s $PROJECT_DIR/$IO_PREFIX/$O2_CTF_DIR/001/AO2D.root $PROJECT_DIR/$IO_PREFIX/AO2D.$FILE_NUMBER_1.root
ln -s $PROJECT_DIR/$IO_PREFIX/$O2_CTF_DIR/002/AO2D.root $PROJECT_DIR/$IO_PREFIX/AO2D.$FILE_NUMBER_2.root

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
