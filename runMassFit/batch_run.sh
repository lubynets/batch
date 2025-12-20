#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

gcc --version
cc --version

# source /lustre/alice/users/lubynets/soft/qa2_vae23/bin/qa2Config.sh
source /lustre/alice/users/lubynets/soft/qa2/bin/qa2Config.sh

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/alice/users/lubynets/QA

MACRO_DIR=$PROJECT_DIR/macro

OUTPUT_DIR=$PROJECT_DIR/outputs/runMassFit/HL/mc/HF_LHC24h1b_All/568123/ctbin1/pt_3_20/DSCB/preFit
# OUTPUT_DIR=$PROJECT_DIR/outputs/runMassFit/draft
WORK_DIR=$PROJECT_DIR/workdir
LOG_DIR=$OUTPUT_DIR/log
BATCH_LOG_DIR=$PROJECT_DIR/log

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR/jobs
mkdir -p $LOG_DIR/out
mkdir -p $LOG_DIR/error

cd $WORK_DIR/$INDEX

SCORES="0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99"

CONFIG_FILE=config_massfitter.signal.json

mkdir -p mInvFit mInvFit_Residuals RawYields_Lc configs
for score in $SCORES
do
mkdir -p $score
cd $score
cp $MACRO_DIR/$CONFIG_FILE .
sed -i "s/BDT_SCORE_TO_BE_REPLACED/$score/g" $CONFIG_FILE
sed -i "s/RANDOM_SEED_TO_BE_REPLACED/$INDEX/g" $CONFIG_FILE
echo "start processing score = $score"
date
echo
runMassFitter $CONFIG_FILE  >& log_$INDEX.txt
echo "finish processing score = $score"
date
echo
mv fileOut.root ../RawYields_Lc.NPgt${score}.root
mv fileOut.pdf ../mInvFit.NPgt${score}.pdf
mv fileOut_Residuals.pdf ../mInvFit_Residuals.NPgt${score}.pdf
mv log_$INDEX.txt ..
mv $CONFIG_FILE ../configs/$score.$CONFIG_FILE
cd -
rm -r $score
done
mv mInvFit.*pdf ./mInvFit
mv mInvFit_Residuals*pdf ./mInvFit_Residuals
mv RawYields_Lc*root ./RawYields_Lc
cd ..
tar rf RawYields_Lc.$INDEX.tar $INDEX/RawYields_Lc/RawYields_Lc.*
cd -

mv log* $LOG_DIR/jobs
mv $BATCH_LOG_DIR/out/$INDEX.out.log $LOG_DIR/out
mv $BATCH_LOG_DIR/error/$INDEX.err.log $LOG_DIR/error

cd ..
if [ "$INDEX" -eq 1 ]; then
  mv $INDEX $OUTPUT_DIR
fi
mv RawYields_Lc.$INDEX.tar $OUTPUT_DIR

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch index_${INDEX}

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
