#!/bin/bash
#
# harvest_dot_aws/AWS.sh

. ./common/start.sh

DATADIR="data/${YEAR}/harvest_dot_aws/"

CWD=`pwd`

mkdir -p ${CWD}/${DATADIR} >& /dev/null

CURMNTH=`date --date="$TODAY" +%b`
CURYEAR=`date --date="$TODAY" +%Y`
ISO=`date +%d%H`

# echo CURMNTH = \"$CURMNTH\"
# echo CURYEAR = \"$CURYEAR\"
# echo ISO = \"$ISO\"

/bin/rm -rf tmp
mkdir tmp >& /dev/null

aws s3 cp --recursive s3://cibu.ocean/TideUTAmazon/BAR tmp/BAR >& /dev/null
aws s3 cp --recursive s3://cibu.ocean/TideUTAmazon/FBV tmp/FBV >& /dev/null

cd tmp

for dir in BAR FBV ; do
  if [ -d $dir ] ; then
    mkdir ${CWD}/${DATADIR}/${dir} >& /dev/null
    cd $dir
    for f in ${dir}_${CURMNTH}_${CURYEAR}*.txt ; do
      # echo File \"$f\"
      n=`echo $f | sed -e 's/.txt//'`
      # echo Root \"$n\"
      mv $f ${n}_$ISO.txt
      /bin/rm ${CWD}/${DATADIR}/${dir}/${dir}_${CURMNTH}_${CURYEAR}_*.txt >& /dev/null
      /bin/mv ${n}_$ISO.txt ${CWD}/${DATADIR}/${dir}/
    done
    for f in * ; do
      if [ ! -f ${CWD}/${DATADIR}/${dir}/$f ] ; then
        /bin/mv $f ${CWD}/${DATADIR}/${dir}/
      else
        /bin/rm $f
      fi
    done
    cd ..
  fi
done

cd ..
#/bin/rm -rf tmp

. ./common/finish.sh

exit 0
