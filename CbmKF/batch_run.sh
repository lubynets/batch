#!/bin/bash

echo
echo "Bash script started"
date

# CBMROOT=/lustre/cbm/users/lubynets/soft/cbmroot/install
CBMROOT=/lustre/cbm/users/lubynets/soft/cbmroot/install_apr20_at2_debian10

source $CBMROOT/bin/CbmRootConfig.sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CBMROOT/lib/
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$CBMROOT/include/
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$CBMROOT/include/AnalysisTree

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/lubynets/CbmKF
MACRO_DIR=$PROJECT_DIR/macro
MACRO=kf_kfparticle.C
MACRO_SECOND=histo_extract.C

if [[ $INDEX -gt 0 && $INDEX -lt 1001 ]]
then
SETUP_IN=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_w/auau/12agev/mbias/sis100_electron_target_25_mkm #          1-1000
fi
if [[ $INDEX -gt 1000 && $INDEX -lt 2001 ]]
then
SETUP_IN=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_wdalitz/auau/12agev/mbias/sis100_electron_target_25_mkm # 1001-2000
fi
if [[ $INDEX -gt 2000 && $INDEX -lt 3001 ]]
then
SETUP_IN=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_etap/auau/12agev/mbias/sis100_electron_target_25_mkm #    2001-3000
fi
if [[ $INDEX -gt 3000 && $INDEX -lt 4001 ]]
then
SETUP_IN=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_phi/auau/12agev/mbias/sis100_electron_target_25_mkm #     3001-4000
fi
if [[ $INDEX -gt 4000 && $INDEX -lt 5001 ]]
then
SETUP_IN=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_rho0/auau/12agev/mbias/sis100_electron_target_25_mkm #    4001-5000
fi

SETUP_OUT=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm/tofpid

INPUT_DIR=/lustre/cbm/pwg/common/mc/cbmsim/$SETUP_IN
OUTPUT_DIR=${PROJECT_DIR}/outputs_withomega/$SETUP_OUT
LOG_DIR=$OUTPUT_DIR/log
WORK_DIR=$PROJECT_DIR/workdir

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_DIR

cd $WORK_DIR/$INDEX

cp ${MACRO_DIR}/${MACRO} ./
cp ${MACRO_DIR}/${MACRO_SECOND} ./

NEVENTS=1000
N=1
DATA_SET=$(($(($(($INDEX-1))/$N))+1))
RESIDUE=$(($(($(($INDEX-1))%$N))))
EVE_FROM=$(($RESIDUE*$NEVENTS/$N))
EVE_TO=$(($(($RESIDUE+1))*$NEVENTS/$N))

root -l -b -q "${MACRO}(\"${INPUT_DIR}/\", \"${INDEX}\")" >& log_${INDEX}.txt
# root -l -b -q "${MACRO}(\"${INPUT_DIR}/\", \"${DATA_SET}\", ${EVE_FROM}, ${EVE_TO})" >& log_${INDEX}.txt

root -l -b -q "${MACRO_SECOND}(\"CbmKFParticleFinderQA.root\")"

rm $MACRO $MACRO_SECOND L1_histo.root FairRunInfo_phys.root Efficiency.txt phys.root core*

mv CbmKFParticleFinderQA.root CbmKFParticleFinderQA.$INDEX.root
mv CbmKFQA.root CbmKFQA.$INDEX.root

mv *root $OUTPUT_DIR
mv log* $LOG_DIR

cd ..
rm -r $INDEX

mkdir -p $WORK_DIR/success
cd $WORK_DIR/success
touch index_${INDEX}

echo
echo "Bash script finished successfully"
date