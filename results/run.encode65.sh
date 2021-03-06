#!/bin/bash

dir=`pwd`
bin=$dir/../programs
list=$dir/../data/encode65.list
datadir=$dir/../data/encode65
results=$dir/../results/encode65
mkdir -p $results

scripts=`tempfile -d $dir`
rm -f $scripts

function make.scripts
{
	algo=$1;
	suffix=$2;
	coverage=$3;

	if [ ! -x $bin/$1 ]; then
		echo "please make sure $bin/scallop is available/executable"
		exit
	fi
	
	if [ ! -x $bin/gffcompare ]; then
		echo "please make sure $bin/gffcompare is available/executable"
		exit
	fi

	for x in `cat $list`
	do
		id=`echo $x | cut -f 1 -d ":"`
		ss=`echo $x | cut -f 2 -d ":"`
		gm=`echo $x | cut -f 3 -d ":"`
		gtf=$dir/../data/ensembl/$gm.gtf
	
		if [ ! -s $gtf ]; then
			echo "make sure $gtf is available"
			exit
		fi
	
		bam=$datadir/$id.bam
	
		if [ ! -s $bam ]; then
			echo "make sure $bam is available"
			exit
		fi
	
		cur=$results/$id/$algo.$suffix
	
		echo "./run.$algo.sh $cur $bam $gtf $coverage $ss" >> $scripts
	done
}

## MODIFY THE FOLLOWING LINES TO SPECIFIY EXPERIMENTS
#usage: make.scripts <scallop|stringtie|transcomb> <ID of this run> <minimum-coverage>
make.scripts scallop B673 default
#make.scripts stringtie test3 0.01
#make.scripts transcomb test3 0.01

xarglist=`tempfile -d $dir`
rm -f $xarglist

cat $scripts | sort -R > $xarglist

## MODIFY -P TO SPECIFY CPU CORES
nohup cat $xarglist | xargs -L 1 -I CMD -P 10 bash -c CMD > /tmp/null &
