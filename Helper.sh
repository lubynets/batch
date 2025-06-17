CP () {
  local SRC=$1
  local FILE=$2
  local TARGET=$3
  if [ ! -f $TARGET/$FILE ]; then
    cp $SRC/$FILE $TARGET
  fi
}

RM () {
  local FILE=$1
  if [ -f $FILE ]; then
    rm $FILE
  fi
}

CreateJobsArray () {
  local A_LOW=$1
  local A_HIGH=$2
  local SUCCESS_DIR=$3

  A=
  for X in `seq $A_LOW $A_HIGH`
  do
  if [[ ! -f $WORK_DIR/success/index_${X} && ! $X = $A_HIGH ]]
  then
  if [ -z $START_INTERVAL ]
  then
  START_INTERVAL=$X
  fi
  FINISH_INTERVAL=$X
  else
  if [ $START_INTERVAL = $FINISH_INTERVAL ]
  then
  INTERVAL=$START_INTERVAL
  else
  INTERVAL=$START_INTERVAL-$FINISH_INTERVAL
  fi
  if ! [ -z $INTERVAL ]
  then
  if [ -z $A ]
  then
  A=$INTERVAL
  else
  A=$A,$INTERVAL
  fi
  fi
  START_INTERVAL=
  FINISH_INTERVAL=
  INTERVAL=
  fi
  done

  echo "${A:-}"
}


export -f CP
export -f RM
export -f CreateJobsArray
