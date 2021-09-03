#!/bin/bash

# CBMROOT=/lustre/cbm/users/lubynets/soft/cbmroot/install
CBMROOT=/lustre/cbm/users/lubynets/soft/cbmroot/install_apr20_at2

source $CBMROOT/bin/CbmRootConfig.sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CBMROOT/lib/
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$CBMROOT/include/
export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$CBMROOT/include/AnalysisTree

INDEX=${SLURM_ARRAY_TASK_ID}

PROJECT_DIR=/lustre/cbm/users/lubynets/CbmKF
MACRO_DIR=${PROJECT_DIR}/macro
MACRO=kf_kfparticle.C
MACRO_SECOND=histo_extract.C

# SETUP_IN=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_w/auau/12agev/mbias/sis100_electron_target_25_mkm #          1-1000
# SETUP_IN=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_wdalitz/auau/12agev/mbias/sis100_electron_target_25_mkm # 1001-2000
# SETUP_IN=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_etap/auau/12agev/mbias/sis100_electron_target_25_mkm #    2001-3000
# SETUP_IN=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_phi/auau/12agev/mbias/sis100_electron_target_25_mkm #     3001-4000
SETUP_IN=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto_rho0/auau/12agev/mbias/sis100_electron_target_25_mkm #    4001-5000

SETUP_OUT=apr20_fr_18.2.1_fs_jun19p1/dcmqgsm_smm_pluto/auau/12agev/mbias/sis100_electron_target_25_mkm

INPUT_DIR=/lustre/cbm/pwg/common/mc/cbmsim/$SETUP_IN
OUTPUT_DIR=${PROJECT_DIR}/outputs/$SETUP_OUT
WORK_DIR=$PROJECT_DIR/workdir

mkdir -p $WORK_DIR/$INDEX
mkdir -p $OUTPUT_DIR

cd $WORK_DIR/$INDEX

cp ${MACRO_DIR}/${MACRO} ./
cp ${MACRO_DIR}/${MACRO_SECOND} ./

NEVENTS=1000
N=1
DATA_SET=$(($(($(($INDEX-1))/$N))+1))
RESIDUE=$(($(($(($INDEX-1))%$N))))
EVE_FROM=$(($RESIDUE*$NEVENTS/$N))
EVE_TO=$(($(($RESIDUE+1))*$NEVENTS/$N))

# root -l -b -q "${MACRO}(\"${INPUT_DIR}/\", \"${INDEX}\")" >& log_${INDEX}.txt
root -l -b -q "${MACRO}(\"${INPUT_DIR}/\", \"${DATA_SET}\", ${EVE_FROM}, ${EVE_TO})" >& log_${INDEX}.txt

root -l -b -q "${MACRO_SECOND}(\"CbmKFParticleFinderQA.root\")"

rm ${MACRO} ${MACRO_SECOND} L1_histo.root FairRunInfo_phys.root Efficiency.txt phys.root

cd ..
mv $INDEX $OUTPUT_DIR