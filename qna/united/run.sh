#!/bin/bash
LOGDIR=/lustre/cbm/users/$USER/qna/log
mkdir -p $LOGDIR
mkdir -p $LOGDIR/out
mkdir -p $LOGDIR/error

module use /cvmfs/it.gsi.de/modulefiles
module load boost/1.71.0_gcc9.1.0 compiler/gcc/9.1.0

source /lustre/cbm/users/lubynets/soft/root-6/install_6.20_cpp17/bin/thisroot.sh

SOFT_DIR=/lustre/cbm/users/lubynets/soft/QnAnalysis

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/build/src/QnAnalysisBase
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/build/src/QnAnalysisCorrelate
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/build/_deps/qntools-build/src/base
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFT_DIR/build/_deps/qntools-build/src/correction

sbatch --job-name=QnA \
       --wait \
       -t 07:20:00 \
       --partition main \
       --output=$LOGDIR/out/%j.out.log \
       --error=$LOGDIR/error/%j.err.log \
       -a 1-100 \
       -- $PWD/batch_run_0.sh
       
hadd -T /lustre/cbm/users/$USER/qna/workdir/correction_merged_out_0.root /lustre/cbm/users/$USER/qna/workdir/*/correction_out_0.root >& log_merge_0.txt

sbatch --job-name=QnA \
       --wait \
       -t 07:20:00 \
       --partition main \
       --output=$LOGDIR/out/%j.out.log \
       --error=$LOGDIR/error/%j.err.log \
       -a 1-100 \
       -- $PWD/batch_run_1.sh
       
hadd -T /lustre/cbm/users/$USER/qna/workdir/correction_merged_out_1.root /lustre/cbm/users/$USER/qna/workdir/*/correction_out_1.root >& log_merge_1.txt

sbatch --job-name=QnA \
       -t 07:20:00 \
       --partition main \
       --output=$LOGDIR/out/%j.out.log \
       --error=$LOGDIR/error/%j.err.log \
       -a 1-100 \
       -- $PWD/batch_run_2.sh