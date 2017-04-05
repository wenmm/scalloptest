#!/bin/bash

coverage="default"
platform="linux_x86_64"

while getopts "c:p:" arg
do
	case $arg in 
	c) 
		coverage=$OPTARG
		;;
	p) 
		platform=$OPTARG
		;;
	esac
done

dir=`pwd`
bin=$dir/../programs/$platform

list=$dir/encode10.list
datadir=$dir/../data/encode10
results=$dir/../results/encode10

mkdir -p $results

for x in `cat $list`
do
	id=`echo $x | cut -f 1 -d ":"`
	ss=`echo $x | cut -f 2 -d ":"`
	gm=`echo $x | cut -f 3 -d ":"`
	gtf=$dir/../data/ensembl/$gm.gtf

	for aa in `echo "tophat star hisat"`
	do
		bam=$datadir/$id/$aa.sort.bam
		cur=$results/$id.$aa/transcomb.$coverage
		mkdir -p $cur

		cd $cur

		if [ "$coverage" == "default" ]
		then
			{ /usr/bin/time -v $bin/transcomb -b $bam -s $ss > transcomb.log; } 2> time.log
		else
			{ /usr/bin/time -v $bin/transcomb -b $bam -s $ss -f $coverage > transcomb.log; } 2> time.log
		fi

		cat TransComb.gtf | sed 's/^chr//g' > transcomb.tmp.xxx.gtf
		mv transcomb.tmp.xxx.gtf transcomb.gtf

		$bin/gffcompare -o gffmul -r $gtf transcomb.gtf -M -N
		$bin/gffcompare -o gffall -r $gtf transcomb.gtf

		cd -
	done
done