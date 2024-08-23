#!/bin/bash

echo
echo "Bash script started"
date

START_TIME=$SECONDS

g++ --version
gcc --version
cc --version

source /lustre/cbm/users/lubynets/soft/root-6/install_6.24_cpp17_debian10/bin/thisroot.sh
ANALYSISTREE_DIR=AnalysisTree/install_root6.24_master
QNTOOLS_DIR=QnTools/install_discr

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/$ANALYSISTREE_DIR/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/cbm/users/lubynets/soft/$QNTOOLS_DIR/lib
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/$ANALYSISTREE_DIR/include/AnalysisTree
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:/lustre/cbm/users/lubynets/soft/$QNTOOLS_DIR/include

echo
echo "Environment variables are set"
date

INDEX=${SLURM_ARRAY_TASK_ID}

FILES_PER_JOB=50

PROJECT_DIR=/lustre/cbm/users/lubynets/QA

BEAM_MOM=12
# BEAM_MOM=3.3

# EVEGEN=dcmqgsm
EVEGEN=urqmd

# PDGS=3122and310
# PDG=3122
# PDG=310

# PDGS=3312and3334
# PDG=3312

# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/${EVEGEN}_smm_pluto/auau/${BEAM_MOM}agev/mbias/sis100_electron_target_25_mkm # 1 - 5000, dcmqgsm, 12agev
SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/${EVEGEN}_pluto/auau/${BEAM_MOM}agev/mbias/sis100_electron_target_25_mkm # 1001 - 3000, urqmd, 12agev
# SETUP_SIM=apr20_fr_18.2.1_fs_jun19p1/${EVEGEN}_smm_pluto/auau/${BEAM_MOM}agev/mbias/sis100_electron_target_25_mkm_psd_v18e_p3.3_56 # 1 - 3000, dcmqgsm, 3.3agev

# SETUP_REC=recpid/lightcuts1
# SETUP_REC=recpid/defaultcuts
# SETUP_REC=recpid/optimcuts1

SETUP_REC=$SETUP_REC/$PDGS

MACRO_DIR=$PROJECT_DIR/macro

INPUT_DIR_SIM=/lustre/cbm/users/lubynets/cbm2atree/outputs/$SETUP_SIM/AT2
# INPUT_DIR_SIM=/lustre/cbm/users/lubynets/centradd/outputs/$SETUP_SIM
# INPUT_DIR_SIM=/lustre/cbm/users/lubynets/pidadd/outputs/$SETUP_SIM

# INPUT_DIR_REC=/lustre/cbm/users/lubynets/pfsimple/outputs/$SETUP_SIM/$SETUP_REC

# MACRO=massDC
# MACRO=cplxmap_pt_y_C
# MACRO=recmap_pipos
MACRO=multiplicity_qa
# MACRO=m2_pq_vtx
# MACRO=covariances_scol
# MACRO=qvec_qa
# MACRO=psd_modules_qa

# PARTICLE=lambda
# PARTICLE=pipos
# PARTICLE=pineg

OUTPUT_DIR=$PROJECT_DIR/outputs/$MACRO/$SETUP_SIM
# OUTPUT_DIR=$PROJECT_DIR/outputs/$MACRO/$SETUP_SIM/$SETUP_REC/${PDG}_psd
# OUTPUT_DIR=$PROJECT_DIR/outputs/$MACRO/$SETUP_SIM/$SETUP_REC/${PDG}_finept
# OUTPUT_DIR=$PROJECT_DIR/outputs/$MACRO/inv_mass_flow/${EVEGEN}/${BEAM_MOM}agev/$PDG
WORK_DIR=$PROJECT_DIR/workdir
LOG_DIR=$OUTPUT_DIR/log

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

cp $MACRO_DIR/${MACRO}.C ./

if [ -f "filelist_sim.list" ]
then
rm filelist_sim.list
fi

if [ -f "filelist_rec.list" ]
then
rm filelist_rec.list
fi

for K in `seq 1 $FILES_PER_JOB`
do
FILE_NUMBER=$(($(($FILES_PER_JOB*$(($INDEX-1))))+$K))
ls -d $INPUT_DIR_SIM/$FILE_NUMBER.analysistree.root >> filelist_sim.list
# ls -d $INPUT_DIR_SIM/pid.analysistree.$FILE_NUMBER.root >> filelist_sim.list
done
#
ls -d $INPUT_DIR_REC/PFSimpleOutput.$INDEX.root >> filelist_rec.list

# root -l -b -q "${MACRO}.C(\"filelist_rec.list\")" >& log_${INDEX}.txt # recmap_pipos
# root -l -b -q "${MACRO}.C(\"filelist_sim.list\", \"filelist_rec.list\", $BEAM_MOM)" >& log_${INDEX}.txt # cplxmap_pt_y_C
# root -l -b -q "${MACRO}.C(\"filelist_sim.list\", \"filelist_rec.list\", $PDG)" >& log_${INDEX}.txt # massDC
root -l -b -q "${MACRO}.C({\"filelist_sim.list\"})" >& log_${INDEX}.txt # multiplicity_qa
# root -l -b -q "${MACRO}.C(\"filelist_sim.list\")" >& log_${INDEX}.txt
# root -l -b -q "${MACRO}.C(\"/lustre/cbm/users/lubynets/qna/outputs/$SETUP_SIM/$SETUP_REC/$PDG/$INDEX/correction_out_2.root\")" >& log_${INDEX}.txt

rm $MACRO.C

mv $MACRO.root $MACRO.$INDEX.root

mv *root $OUTPUT_DIR
# mv filelist_sim.list $OUTPUT_DIR/filelist_sim.$INDEX.list
mv log* $LOG_DIR

cd ..
rm -r $INDEX

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch index_${INDEX}

echo
echo "Bash script finished successfully"
date

FINISH_TIME=$SECONDS
echo
echo "elapsed time " $(($(($FINISH_TIME-$START_TIME))/60)) "m " $(($(($FINISH_TIME-$START_TIME))%60)) "s"
