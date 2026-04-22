#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

gcc --version
cc --version

source /lustre/alice/users/lubynets/soft/qa2_m25/bin/qa2Config.sh

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/alice/users/lubynets/syst/multiFit
INPUT_DIR=/lustre/alice/users/lubynets/runMassFit/outputs/HL/data/HF_LHC23_pass4_Thin_2P3PDstar/574294/ctbin2/syst
WORK_DIR=/tmp/lubynets/multiFit
OUTPUT_DIR=$PROJECT_DIR/rawy

LEFT_RANGES=(2.12 2.13 2.14 2.15 2.16 2.17 2.18) # 7
RIGHT_RANGES=(2.42 2.41 2.40 2.39 2.38 2.37 2.36) # 7
REBIN_FACTORS=(1 2 3 4 5 6 8 10) # 8
BG_FUNCTIONS=(2 5) # 2
N_TRIALS=100

########## decode multidimensional indices from one-dimensional ############
idx=$(($INDEX - 1))

L=${#LEFT_RANGES[@]}
R=${#RIGHT_RANGES[@]}
B=${#REBIN_FACTORS[@]}
F=${#BG_FUNCTIONS[@]}

i_left=$(( idx % L ))
idx=$(( idx / L ))

i_right=$(( idx % R ))
idx=$(( idx / R ))

i_rebin=$(( idx % B ))
idx=$(( idx / B ))

i_bg=$(( idx % F ))
############################################################################
lera=${LEFT_RANGES[$i_left]}
rira=${RIGHT_RANGES[$i_right]}
refa=${REBIN_FACTORS[$i_rebin]}
bgfu=${BG_FUNCTIONS[$i_bg]}

dirPath=lera_$lera/rira_$rira/refa_$refa/bgfu_$bgfu

mkdir -p $OUTPUT_DIR/$dirPath
mkdir -p $OUTPUT_DIR/log
rm -r $WORK_DIR/$dirPath
mkdir -p $WORK_DIR/$dirPath/trials
cd $WORK_DIR/$dirPath/trials

cp $INPUT_DIR/$dirPath/RawYields_Lc*tar .
for I in `seq 1 $N_TRIALS`; do
  tar -xvf RawYields_Lc.$I.tar
done
cd ..
multifit_qa >& log_${INDEX}.txt
mv log*txt $OUTPUT_DIR/log

mv smooth/RawYields_Lc $OUTPUT_DIR/$dirPath
cd hTrials
tar -rf hTrials.tar h*
mv hTrials.tar $OUTPUT_DIR/$dirPath
cd ..
rm -r hTrials

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
