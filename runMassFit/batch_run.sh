#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS
PARTITION=${1}

gcc --version
cc --version

source /lustre/alice/users/lubynets/soft/qa2/bin/qa2Config.sh

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/alice/users/lubynets/runMassFit

CONFIG_DIR=$PROJECT_DIR/config

# IO_PREFIX=HL/mc/HF_LHC24h1b_All/576378
IO_PREFIX=HL/data/HF_LHC23_pass4_Thin_2P3PDstar/574294

# LEFT_RANGES=(2.12 2.14 2.16 2.18) # 4
# RIGHT_RANGES=(2.42 2.40 2.38 2.36) # 4
# REBIN_FACTORS=(1 2 4 6 8 10) # 6
# BG_FUNCTIONS=(2 5) # 2
# N_JOBS_WITH_TRIALS=10
# N_TRIALS_PER_JOB=10

LEFT_RANGES=(2.12 2.14) # 2
RIGHT_RANGES=(2.42 2.40) # 2
REBIN_FACTORS=(4 6) # 2
BG_FUNCTIONS=(2 5) # 2
N_JOBS_WITH_TRIALS=9
N_TRIALS_PER_JOB=11


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
idx=$(( idx / F ))

i_job_with_trial=$(( idx % N_JOBS_WITH_TRIALS ))

trial_from=$(( i_job_with_trial*N_TRIALS_PER_JOB + 1 ))
trial_to=$(( i_job_with_trial*N_TRIALS_PER_JOB + N_TRIALS_PER_JOB ))
############################################################################
lera=${LEFT_RANGES[$i_left]}
rira=${RIGHT_RANGES[$i_right]}
refa=${REBIN_FACTORS[$i_rebin]}
bgfu=${BG_FUNCTIONS[$i_bg]}

# SCORES="0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99"

# SCORES="0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90"
SCORES="0.01 0.02"

OUTPUT_DIR=$PROJECT_DIR/outputs/$IO_PREFIX/ctbin2/syst/lera_$lera/rira_$rira/refa_$refa/bgfu_$bgfu
# if [[ $PARTITION == "debug" ]]; then
#   OUTPUT_DIR=$PROJECT_DIR/outputs/draft
#   SCORES="0.01 0.02"
# fi

WORK_DIR=$PROJECT_DIR/workdir
BATCH_LOG_DIR=$PROJECT_DIR/log

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR

cd $WORK_DIR/$INDEX

if [[ $IO_PREFIX == *"/mc/"* ]]; then
  CONFIG_FILE=config_massfitter.signal.json
elif [[ $IO_PREFIX == *"/data/"* ]]; then
  CONFIG_FILE=config_massfitter.syst.json
fi

mkdir -p RawYields_Lc

for i_trial in `seq $trial_from $trial_to`; do
  echo "start processing trial = $i_trial"
  for score in $SCORES; do
    cd $WORK_DIR/$INDEX
    mkdir -p $i_trial/$score
    cd $i_trial/$score
    cp $CONFIG_DIR/$CONFIG_FILE .
    sed -i "s/BDT_SCORE_TO_BE_REPLACED/$score/g" $CONFIG_FILE
    sed -i "s/RANDOM_SEED_TO_BE_REPLACED/$i_trial/g" $CONFIG_FILE
    sed -i "s/LEFT_RANGE_TO_BE_REPLACED/$lera/g" $CONFIG_FILE
    sed -i "s/RIGHT_RANGE_TO_BE_REPLACED/$rira/g" $CONFIG_FILE
    sed -i "s/REBIN_FACTOR_TO_BE_REPLACED/$refa/g" $CONFIG_FILE
    sed -i "s/BG_FUNCTION_TO_BE_REPLACED/$bgfu/g" $CONFIG_FILE
    echo "start processing score = $score"
    date
    echo
    runMassFitter $CONFIG_FILE >& log.NPgt${score}.trial${i_trial}.txt
    echo "finish processing score = $score"
    date
    echo

    tar -uf $OUTPUT_DIR/mInvFit.pdf.tar --transform="s|fileOut.pdf|mInvFit.NPgt${score}.trial${i_trial}.pdf|" fileOut.pdf
    tar -uf $OUTPUT_DIR/mInvFit_Residuals.pdf.tar --transform="s|fileOut_Residuals.pdf|mInvFit_Residuals.NPgt${score}.trial${i_trial}.pdf|" fileOut_Residuals.pdf
    tar -uf $OUTPUT_DIR/mInvFit_Ratios.pdf.tar --transform="s|fileOut_Ratio.pdf|mInvFit_Ratio.NPgt${score}.trial${i_trial}.pdf|" fileOut_Ratio.pdf
    tar -uf $OUTPUT_DIR/configs.json.tar --transform="s|$CONFIG_FILE|$score.trial${i_trial}.$CONFIG_FILE|" $CONFIG_FILE
    tar -uf $OUTPUT_DIR/jobs.log.tar log.NPgt${score}.trial${i_trial}.txt

    mv fileOut.root ../../RawYields_Lc/RawYields_Lc.NPgt${score}.trial${i_trial}.root

    cd $WORK_DIR/$INDEX
    rm -r $i_trial/$score
  done

  tar rf RawYields_Lc.$i_trial.tar --transform="s|RawYields_Lc|$i_trial/RawYields_Lc|" --transform="s|trial${i_trial}.||" RawYields_Lc/RawYields_Lc.*trial${i_trial}.root
  rm RawYields_Lc/RawYields_Lc.*trial${i_trial}.root
  mv RawYields_Lc.$i_trial.tar $OUTPUT_DIR
  cd ..

echo "finish processing trial = $i_trial"
done

cd $OUTPUT_DIR
rm -r mInvFit mInvFit_Residuals mInvFit_Ratios configs log

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch index_${INDEX}

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"

tar -uf "$OUTPUT_DIR/out.log.tar" -C "$BATCH_LOG_DIR/out" "$INDEX.out.log"
tar -uf "$OUTPUT_DIR/error.log.tar" -C "$BATCH_LOG_DIR/error" "$INDEX.err.log"
