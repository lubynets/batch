#!/bin/bash

echo
echo "Bash script started"
date

CORR_STEP=${1}
NSTEPS=${2}

source /lustre/cbm/users/lubynets/soft/root-6/install_6.24_cpp17_debian10/bin/thisroot.sh

SOFT_DIR=/lustre/cbm/users/lubynets/soft/QnAnalysis
INSTALL_DIR=install

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/$INSTALL_DIR/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/boost/install_1_77_0/lib

export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/$INSTALL_DIR/include
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/$INSTALL_DIR/include/AnalysisTree
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/$INSTALL_DIR/include/AnalysisTree/infra-1.0
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/$INSTALL_DIR/include/AnalysisTreeCutsRegistry
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/$INSTALL_DIR/include/QnAnalysis
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$SOFT_DIR/$INSTALL_DIR/include/QnTools

INDEX=${SLURM_ARRAY_TASK_ID}

CBM_FILES_PER_JOB=50

PROJECT_DIR=/lustre/cbm/users/lubynets/qna

# PBEAM=3.3
PBEAM=12

# EVEGEN=dcmqgsm_smm
EVEGEN=urqmd

SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/${EVEGEN}_pluto/auau/${PBEAM}agev/mbias/sis100_electron_target_25_mkm # dcmqgsm_smm & urqmd 12 agev (1-100, 21-60)
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/${EVEGEN}_pluto/auau/${PBEAM}agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56 # dcmqgsm_smm 3.3agev (1-60)

# SETUP_REC=recpid/lightcuts1/3122and310

ANATYPE=sim_tracks_flow
# ANATYPE=rec_tracks_psi
# ANATYPE=inv_mass_fit

EXE_DIR=$SOFT_DIR/$INSTALL_DIR/bin
INPUT_DIR_CBM=/lustre/cbm/users/lubynets/pidadd/outputs/$SETUP_SIM
INPUT_DIR_PFS=/lustre/cbm/users/lubynets/weightadd/outputs/$SETUP_SIM/$SETUP_REC
OUTPUT_DIR=$PROJECT_DIR/outputs/$ANATYPE/$EVEGEN/${PBEAM}agev
WORK_DIR=$PROJECT_DIR/workdir
YAML_DIR=/lustre/cbm/users/lubynets/qna/setup

if [ $CORR_STEP = 0 ]
then
mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
fi

cd $WORK_DIR/$INDEX

if [ ! -f "QnAnalysisCorrect" ]
then
cp $EXE_DIR/QnAnalysisCorrect ./
fi
if [ ! -f "QnAnalysisCorrelate" ]
then
cp $EXE_DIR/QnAnalysisCorrelate ./
fi

CORR_FILE=../correction_merged_out_$(($CORR_STEP-1)).root    
echo $CORR_STEP

# # ####### begin rec_tracks_psi and inv_mass_fit ###########################################
# if [ -f "filelist_cbm.list" ]
# then
# rm filelist_cbm.list
# fi
#
# if [ -f "filelist_pfs.list" ]
# then
# rm filelist_pfs.list
# fi
#
# ls -d $INPUT_DIR_PFS/fillerOut.$INDEX.root > filelist_pfs.list
#
# for K in `seq 1 $CBM_FILES_PER_JOB`
# do
# FILE_NUMBER=$(($(($CBM_FILES_PER_JOB*$(($INDEX-1))))+$K))
# ls -d $INPUT_DIR_CBM/centrality.analysistree.$FILE_NUMBER.root >> filelist_cbm.list
# done
#
# if [ $CORR_STEP -ne $NSTEPS ]
# then
# ./QnAnalysisCorrect -i filelist_cbm.list filelist_pfs.list \
#                     -t aTree aTree \
#                     --yaml-config-file $YAML_DIR/$ANATYPE.yml \
#                     --yaml-config-name cbm_analysis \
#                     --calibration-input-file $CORR_FILE \
#                     --cuts-macro $PROJECT_DIR/setup/CbmCuts.C \
#                     --n-events -1 \
#                     --event-cuts goodevents >& log_${INDEX}_${CORR_STEP}.txt
#
# mv correction_out.root correction_out_$CORR_STEP.root
# fi
#
# if [ $CORR_STEP = $NSTEPS ]
# then
# ./QnAnalysisCorrelate --configuration-file $YAML_DIR/$ANATYPE.yml \
#                       --configuration-name _tasks \
#                       --input-file correction_out_$(($NSTEPS-1)).root \
#                       -o correloutput.root \
#                       --n-samples 50 >& log_ana_${INDEX}.txt
#
# rm QnAnalysisCorrect QnAnalysisCorrelate filelist*
#
# cd ..
# mv $INDEX $OUTPUT_DIR
# fi
# # ####### end rec_tracks_psi and inv_mass_fit #############################################

####### begin sim_tracks_flow ###########################################################
if [ -f "filelist.list" ]
then
rm filelist.list
fi

for K in `seq 1 $CBM_FILES_PER_JOB`
do
FILE_NUMBER=$(($(($CBM_FILES_PER_JOB*$(($INDEX-1))))+$K))
ls -d $INPUT_DIR_CBM/pid.analysistree.$FILE_NUMBER.root >> filelist.list
done

if [ $CORR_STEP -ne $NSTEPS ]
then
./QnAnalysisCorrect -i filelist.list \
                    -t aTree \
                    --yaml-config-file $YAML_DIR/$ANATYPE.yml \
                    --yaml-config-name cbm_analysis \
                    --n-events -1 \
                    --calibration-input-file $CORR_FILE >& log_${INDEX}_${CORR_STEP}.txt

mv correction_out.root correction_out_$CORR_STEP.root
fi

if [ $CORR_STEP = $NSTEPS ]
then
./QnAnalysisCorrelate --configuration-file $YAML_DIR/$ANATYPE.yml \
                      --configuration-name _tasks \
                      --input-file correction_out_$(($NSTEPS-1)).root \
                      -o correloutput.root \
                      --n-samples 50 >& log_ana_${INDEX}.txt

rm QnAnalysisCorrect QnAnalysisCorrelate filelist.list

cd ..
mv $INDEX $OUTPUT_DIR
fi
####### end sim_tracks_flow #############################################################

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch step_${CORR_STEP}_index_${INDEX}

echo
echo "Bash script finished successfully"
date
