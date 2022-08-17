#!/bin/bash

echo
echo "Bash script started"
date

CORR_STEP=${1}

source /lustre/cbm/users/lubynets/soft/root-6/install_6.20_cpp17_debian10/bin/thisroot.sh

SOFT_DIR=/lustre/cbm/users/lubynets/soft/QnAnalysis
# BUILD_DIR=build_master
INSTALL_DIR=install

# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/$BUILD_DIR/src/QnAnalysisBase
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/$BUILD_DIR/src/QnAnalysisCorrelate
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/$BUILD_DIR/_deps/qntools-build/src/base
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/$BUILD_DIR/_deps/qntools-build/src/correction
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/boost/install_1_77_0/lib

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/$INSTALL_DIR/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/boost/install_1_77_0/lib

export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/$INSTALL_DIR/include
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/$INSTALL_DIR/include/AnalysisTree
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/$INSTALL_DIR/include/AnalysisTree/infra-1.0
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/$INSTALL_DIR/include/AnalysisTreeCutsRegistry
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/$INSTALL_DIR/include/QnAnalysis

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/lubynets/qna

# PBEAM=3.3
PBEAM=12

EVEGEN=dcmqgsm_smm
# EVEGEN=urqmd

PDG=3122
# PDG=310
# PDG=3312

SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/${EVEGEN}_pluto/auau/${PBEAM}agev/mbias/sis100_electron_target_25_mkm # dcmqgsm_smm & urqmd 12 agev (1-100, 21-60)
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/${EVEGEN}_pluto/auau/${PBEAM}agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56_MF_56 # dcmqgsm_smm 3.3agev (1-60)

SETUP_REC=recpid/lightcuts1
# SETUP_REC=recpid/defaultcuts

EXE_DIR=$SOFT_DIR/$INSTALL_DIR/bin
OUTPUT_DIR=${PROJECT_DIR}/outputs_brex/$SETUP_SIM/$SETUP_REC/$PDG/set4
WORK_DIR=$PROJECT_DIR/workdir
FILELIST_DIR=/lustre/cbm/users/lubynets/filelists/pidadd/${SETUP_SIM}_brex/50perfile
YAML_DIR=/lustre/cbm/users/lubynets/qna/setup

if [ $CORR_STEP = 0 ]
then
mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
fi

cd $WORK_DIR/$INDEX

if [ $CORR_STEP = 0 ]
then
cp $EXE_DIR/QnAnalysisCorrect ./
cp $EXE_DIR/QnAnalysisCorrelate ./

ls -d /lustre/cbm/users/lubynets/weightadd/outputs/$SETUP_SIM/$SETUP_REC/3122and310/${PDG}_brex/fillerOut.$INDEX.root > filelist_sec.list
fi

CORR_FILE=../correction_merged_out_$(($CORR_STEP-1)).root    
echo $CORR_STEP

./QnAnalysisCorrect -i $FILELIST_DIR/filelist.$INDEX.list filelist_sec.list \
                    -t aTree aTree \
                    --yaml-config-file $YAML_DIR/corr-and-corr.$PDG.${PBEAM}agev.psd.yml \
                    --yaml-config-name cbm_analysis \
                    --calibration-input-file $CORR_FILE \
                    --cuts-macro $PROJECT_DIR/setup/CbmCuts.C \
                    --event-cuts goodevents >& log_${INDEX}_${CORR_STEP}.txt
                    
mv correction_out.root correction_out_$CORR_STEP.root

if [ $CORR_STEP = 2 ]
then
./QnAnalysisCorrelate --configuration-file $YAML_DIR/corr-and-corr.$PDG.${PBEAM}agev.psd.yml \
                      --configuration-name _tasks \
                      --input-file correction_out_2.root \
                      -o correloutput.root >& log_ana_${INDEX}.txt

rm QnAnalysisCorrect QnAnalysisCorrelate filelist_sec.list


# ./QnAnalysisCorrect -i $FILELIST_DIR/filelist.$INDEX.list \
#                     -t rTree \
#                     --yaml-config-file $YAML_DIR/usim_qpsi.yml \
#                     --yaml-config-name lambda_analysis \
#                     --calibration-input-file $CORR_FILE \
#                     --cuts-macro $PROJECT_DIR/setup/CbmCuts.C \
#                     --event-cuts goodevents >& log_${INDEX}_${CORR_STEP}.txt
#                     
# mv correction_out.root correction_out_$CORR_STEP.root
# 
# if [ $CORR_STEP = 2 ]
# then
# ./QnAnalysisCorrelate --configuration-file $YAML_DIR/usim_qpsi.yml \
#                       --configuration-name _tasks \
#                       --input-file correction_out_2.root \
#                       -o correloutput.root >& log_ana_${INDEX}.txt

# rm QnAnalysisCorrect QnAnalysisCorrelate

# ./QnAnalysisCorrect -i $FILELIST_DIR/filelist.$INDEX.list \
#                     -t aTree \
#                     --yaml-config-file $YAML_DIR/psd-config.yml \
#                     --yaml-config-name psd_analysis \
#                     --calibration-input-file $CORR_FILE \
#                     --cuts-macro $PROJECT_DIR/setup/CbmCuts.C \
#                     --event-cuts goodevents >& log_${INDEX}_${CORR_STEP}.txt
#                     
# mv correction_out.root correction_out_$CORR_STEP.root
# 
# if [ $CORR_STEP = 2 ]
# then
# ./QnAnalysisCorrelate --configuration-file $YAML_DIR/psd-config.yml \
#                       --configuration-name _tasks \
#                       --input-file correction_out_2.root \
#                       -o correloutput.root >& log_ana_${INDEX}.txt
#                       
# rm QnAnalysisCorrect QnAnalysisCorrelate

cd ..
mv $INDEX $OUTPUT_DIR
fi

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch step_${CORR_STEP}_index_${INDEX}

echo
echo "Bash script finished successfully"
date