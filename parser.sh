#!/bin/bash
shopt -s xpg_echo
TIMEFORMAT="%Rs"

### setup output folder
# \THH_TODO: put this back before submission.
# DATE=`date +"%Y-%m-%d@%T"`
DATE="today"

OUTFOLDER="build_"${DATE}"/"
rm -f -R "build_today/"
mkdir ${OUTFOLDER}

QCIR_OUT=output.qcir
QUABS_OUT=result.quabs


### Parameters
PARSER=parser.py
GENQBF=./genqbf.native
QUABS=./quabs
FORMULA=""

echo "\n------( Hybmc START! )------\n"


# if wrong number of arguments
if [ "$#" -ne 4 ] && [ "$#" -ne 5 ]; then
  echo "Hybmc error: wrong number of arguments of Hybmc: \n"
  echo "- HyperCTL* BMC: $0 {model}.smv {formula}.hc"
  echo "\n------(END Hybmc)------\n"
  exit 1
fi

#  BMC of HyperCTL*
if [ "$#" -eq 4 ]; then
    echo "received 4 arguments, perform BMC of HyperCTL*"
    echo "\n============ Parse SMV Model and HyperCTL* Formula ============"
    NUSMVFILE=$1
    FORMULA=$2
    k=$3
    SEM=$4
    # PARSER_AND_TRANSLATOR=src/parser.py

    if [ ! -f "$NUSMVFILE" ]; then
        echo "error: $NUSMVFILE does not exist"
        exit 1
    fi

    if [ ! -f "$FORMULA" ]; then
        echo "error: $FORMULA does not exist"
        exit 1
    fi

    I=I.bool
    R=R.bool
    P=P.bool
     python3 ${PARSER} ${NUSMVFILE} ${FORMULA} ${I} ${R} ${P}
fi

# BMC of HyperCTL* with a flag
if [ "$#" -eq 5 ] ; then
    FLAG=$5
    # echo "DEBBBBUUUUUUUUUUUUUUUUUG"
    echo $FLAG
    if  [ "$FLAG" = "-bughunt" ]; then
      # echo "DEBBBBUUUUUUUUUUUUUUUUUG"
      echo "received 5 arguments with a -bughunt, doing BMC in bug hunting mode."
      echo "(input formula is negated.)"
      echo "\n============ Parse SMV Model and HyperCTL* Formula ============"
      NUSMVFILE=$1
      FORMULA=$2
      k=$3
      SEM=$4
      # PARSER_AND_TRANSLATOR=src/parser.py

      if [ ! -f "$NUSMVFILE" ]; then
          echo "error: $NUSMVFILE does not exist"
          exit 1
      fi

      if [ ! -f "$FORMULA" ]; then
          echo "error: $FORMULA does not exist"
          exit 1
      fi


      I=I.bool
      R=R.bool
      P=P.bool
      python3 ${PARSER} ${NUSMVFILE} ${FORMULA} ${I} ${R} ${P} $FLAG
      # read QS from formula translation
      # if [ ! -f "QS.bool" ]; then
      #     exit 1
      # fi
      # source QS.bool
      # echo $QS

    elif  [ "$FLAG" = "-find" ]; then
      # echo "DEBBBBUUUUUUUUUUUUUUUUUG"
      echo "received 4 arguments with a -find flag, doing BMC in find mode."
      echo "(input formula is negated.)"
      echo "\n============ Parse SMV Model and HyperCTL* Formula ============"
      NUSMVFILE=$1
      FORMULA=$2
      k=$3
      SEM=$4
      # PARSER_AND_TRANSLATOR=src/single_model_parser.py
      # PARSER_AND_TRANSLATOR=dist/parser/parser
      if [ ! -f "$NUSMVFILE" ]; then
          echo "error: $NUSMVFILE does not exist"
          exit 1
      fi

      if [ ! -f "$FORMULA" ]; then
          echo "error: $FORMULA does not exist"
          exit 1
      fi
      I=I.bool
      R=R.bool
      P=P.bool
      python3 ${PARSER} ${NUSMVFILE} ${FORMULA} ${I} ${R} ${P} $FLAG
      # read QS from formula translation
      # if [ ! -f "QS.bool" ]; then
      #     exit 1
      # fi
      # source QS.bool
      # echo $QS

    else
      echo "error: Only -find flag or -bughunt flag can be received"
      exit 1
    fi
fi

# Syntax check SEMANTICS
if [ "$SEM" = "pes" ]; then
  SEM="PES"
elif [ "$SEM" = "opt" ]; then
  SEM="OPT"
else
  echo "Hybmc error: incorrect semantic input. "
  echo " use {pes | opt} semantics of the unrolling from one of the follows:"
  echo "             (pessimistic / optimistic )"
  exit 1
fi

###------------------semantics--------------------###

echo "\n--------------- Summary of Model Checking Info ---------------"
echo "|  Bound k:    " ${k}
echo "|  Semantics:  " ${SEM}
echo "|  Model:      " ${NUSMVFILE}
echo "|  HyperCTL formula: " ${FORMULA}
echo "-------------------------------------------------------------- \n\n"

###---------------------------BMC-------------------------###
echo "\n============ Unrolling with genQBF + Solving with QuAbS ============"
 echo "---Generating QCIR---"
echo "generating QBF BMC..."
 ${GENQBF} -I ${I} -R ${R} -Q ${P} -k ${k} -sem ${SEM} -f qcir -o ${QCIR_OUT} -n
#-f qcir -o ${QCIR_OUT} -n --fast
 # echo "---QUABS solving---"
echo "solving QBF..."
  ${QUABS}  --partial-assignment ${QCIR_OUT} 2>&1 | tee ${QUABS_OUT}
#  ${QUABS} --statistics --preprocessing 0 --partial-assignment ${QCIR_OUT} 2>&1 | tee ${QUABS_OUT}

## echo "---Parse All Binary Numbers---"
#echo "\n============ Get Nice-formatted Output if Output is avaialbe ============"
#
#if [ ! -f "$QCIR_OUT" ]; then
#    echo "$QCIR_OUT not exists"
#    exit 1
#fi
#
#echo "parsing into readable format..."
# # echo "---Counterexample Mapping---"
# javac ${MAP}.java
# java ${MAP}.java ${QCIR_OUT} ${QUABS_OUT} ${MAP_OUT1} ${MAP_OUT2}
#${MAP} ${QCIR_OUT} ${QUABS_OUT} ${MAP_OUT1} ${MAP_OUT2}
#
# javac ${PARSE_BOOL}.java
# java ${PARSE_BOOL}.java ${MAP_OUT2} ${PARSE_OUT}
#${PARSE_BOOL} ${MAP_OUT2} ${PARSE_OUT}
# echo  "(under condtruction...)"
# python3 ${PARSE_OUTPUT} ${MAP_OUT2} ${PARSE_OUT} ${k}
# #by time

echo "\n------(END Hybmc)------\n"


