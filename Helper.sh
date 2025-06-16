CP () {
  SRC=$1
  FILE=$2
  TARGET=$3
  echo $SRC $FILE $TARGET
  if [ ! -f $TARGET/$FILE ]; then
    echo "aaa"
    cp $SRC/$FILE $TARGET
  fi
}

RM () {
  FILE=$1
  if [ -f $FILE ]; then
    rm $FILE
  fi
}

export -f CP
export -f RM
