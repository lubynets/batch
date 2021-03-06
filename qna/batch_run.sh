#!/bin/bash

module use /cvmfs/it.gsi.de/modulefiles
module load boost/1.71.0_gcc9.1.0 compiler/gcc/9.1.0

source /lustre/cbm/users/lubynets/soft/root-6/install_6.20_cpp17/bin/thisroot.sh

SOFT_DIR=/lustre/cbm/users/lubynets/soft/QnAnalysis

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/build/src/QnAnalysisBase
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/build/src/QnAnalysisCorrelate
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/build/_deps/qntools-build/src/base
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/build/_deps/qntools-build/src/correction

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/lubynets/qna

SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm
SETUP_REC=nopid/defaultcuts

EXE_DIR=$SOFT_DIR/build/src
OUTPUT_DIR=${PROJECT_DIR}/outputs/$SETUP_SIM/$SETUP_REC/set3/sgnl_12
WORK_DIR=$PROJECT_DIR/workdir
FILELIST_DIR=/lustre/cbm/users/lubynets/pfsimple/filelists/$SETUP_SIM
FILELIST_SEC_DIR=$PROJECT_DIR/filelists/$SETUP_SIM/$SETUP_REC
YAML_DIR=/lustre/cbm/users/lubynets/qna/setup

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR

cd $WORK_DIR/$INDEX

cp $EXE_DIR/QnAnalysisCorrect/QnAnalysisCorrect ./
cp $EXE_DIR/QnAnalysisCorrelate/QnAnalysisCorrelate ./

# ls -d /lustre/cbm/users/lubynets/atfiller/outputs/$SETUP_SIM/$SETUP_REC/$INDEX/fillerOut.$INDEX.root > filelist_sec.list

for CORR_STEP in `seq 0 2`;
do
CORR_FILE=correction_out_$(($CORR_STEP-1)).root    
echo $CORR_STEP
# ./QnAnalysisCorrect -i $FILELIST_DIR/filelist.$INDEX.list filelist_sec.list \
./QnAnalysisCorrect -i $FILELIST_DIR/filelist.$INDEX.list $FILELIST_SEC_DIR/filelist_sec.$INDEX.list \
                    -t aTree cTree \
                    --yaml-config-file $YAML_DIR/lambda-analysis-config.yml \
                    --yaml-config-name lambda_analysis \
                    --calibration-input-file $CORR_FILE \
                    --cuts-macro $SOFT_DIR/setups/CbmCuts.C >& log_${INDEX}_${CORR_STEP}.txt
                    
mv correction_out.root correction_out_$CORR_STEP.root
done

./QnAnalysisCorrelate --configuration-file $YAML_DIR/lambda.yml \
                      --configuration-name _tasks \
                      --input-file correction_out_2.root \
                      -o correloutput.root >& log_ana_${INDEX}.txt
                      
rm QnAnalysisCorrect QnAnalysisCorrelate filelist_sec.list

cd ..
mv $INDEX $OUTPUT_DIR

