#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

export INDEX=${SLURM_ARRAY_TASK_ID}

export O2PHYSICS_DIR=/scratch/alice/lubynets/alice2/O2Physics
export PROJECT_DIR=/lustre/alice/users/lubynets/syst/cutVar
OUTPUT_DIR=$PROJECT_DIR/outputs
export EXE_NAME=configCutVarWriter
export CONFIG_TEMPLATE=config_cutvar.json

LEFT_RANGES=(2.12 2.13 2.14 2.15 2.16 2.17 2.18) # 7
RIGHT_RANGES=(2.42 2.41 2.40 2.39 2.38 2.37 2.36) # 7
REBIN_FACTORS=(1 2 3 4 5 6 8 10) # 8
BG_FUNCTIONS=(2 5) # 2
HISTO_STRATEGIES=("hRawYieldsSignal" "hRawYieldsSignalCounted") # 2

export CT_LO=1
export CT_HI=6

########## decode multidimensional indices from one-dimensional ############
idx=$(($INDEX - 1))

L=${#LEFT_RANGES[@]}
R=${#RIGHT_RANGES[@]}
B=${#REBIN_FACTORS[@]}
F=${#BG_FUNCTIONS[@]}
H=${#HISTO_STRATEGIES[@]}

i_left=$(( idx % L ))
idx=$(( idx / L ))

i_right=$(( idx % R ))
idx=$(( idx / R ))

i_rebin=$(( idx % B ))
idx=$(( idx / B ))

i_bg=$(( idx % F ))
idx=$(( idx / F ))

i_hs=$(( idx % H ))
############################################################################
lera=${LEFT_RANGES[$i_left]}
rira=${RIGHT_RANGES[$i_right]}
refa=${REBIN_FACTORS[$i_rebin]}
bgfu=${BG_FUNCTIONS[$i_bg]}
export hist=${HISTO_STRATEGIES[$i_hs]}

export dirPath=lera_$lera/rira_$rira/refa_$refa/bgfu_$bgfu

if [[ $hist == "hRawYieldsSignal" ]]; then
  suffix="get"
else
  suffix="count"
fi

mkdir -p $OUTPUT_DIR/$dirPath/$suffix
cd $OUTPUT_DIR/$dirPath/$suffix

ln -s $PROJECT_DIR/$CONFIG_TEMPLATE $CONFIG_TEMPLATE

apptainer shell /lustre/alice/users/lubynets/singularities/bdt.sif << \EOF
source /usr/local/install/bin/thisroot.sh

$PROJECT_DIR/$EXE_NAME $CONFIG_TEMPLATE $dirPath/RawYields_Lc $hist

for ICT in `seq $CT_LO $CT_HI`; do
  python3 $O2PHYSICS_DIR/PWGHF/D2H/Macros/compute_fraction_cutvar.py config_cutvar_ct${ICT}.json >> log_$INDEX.txt 2>&1
done

$PROJECT_DIR/mergeIndividualCutVarOutputs.sh $CT_LO $CT_HI >> log_$INDEX.txt 2>&1

EOF
# EOF to trigger the end of the singularity command

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
