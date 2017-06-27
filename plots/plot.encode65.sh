#!/bin/bash

dir=`pwd`
datadir=$dir/encode65/collect.B759
outdir=$dir/encode65/adjust
texdir=$dir/tex
mkdir -p $outdir

for ppp in `echo "multi"`
do
	for kkk in `echo "zero default"`
	do
		for sss in `echo "correct2 correct3 precision2 precision3"`
		do
			for ttt in `echo "A B C"`
			do
				max=""
				if [ "$sss" == "correct2" ] || [ "$sss" == "precision2" ]; then
					ttt=""
				fi

				if [ "$sss" == "correct2" ] || [ "$sss" == "correct3" ]; then
					max=19000
				else
					max=70
				fi

				accfile=$datadir/$ppp.$kkk.$sss$ttt
				tmpfile=$dir/tmpfile.R
				rm -rf $tmpfile
				
				echo "library(\"tikzDevice\")" > $tmpfile
				echo "source(\"$dir/R/adjust.R\")" >> $tmpfile
				
				echo "plot.$sss(\"$accfile\", \"$ppp-$kkk-$sss$ttt.tex\", $max)" >> $tmpfile
				
				cd $outdir
				
				R CMD BATCH $tmpfile
				
				for id in `echo "$ppp-$kkk-$sss$ttt"`
				do
					$dir/wrap.sh $id.tex
					cat $id.tex | sed 's/ENCFF//g' > NOENCFF;
					mv NOENCFF $id.tex
					$dir/myepstool.sh $id
				done

				rm -rf $tmpfile
			done
		done
	done
done

cd $outdir
cat $texdir/adjust.tex | sed 's/NAME/multi-zero-correct/g' > multi-zero-correct.tex; $dir/myepstool.sh multi-zero-correct
cat $texdir/adjust.tex | sed 's/NAME/multi-zero-precision/g' > multi-zero-precision.tex; $dir/myepstool.sh multi-zero-precision

cat $texdir/adjust.tex | sed 's/NAME/multi-default-correct/g' > multi-default-correct.tex; $dir/myepstool.sh multi-default-correct
cat $texdir/adjust.tex | sed 's/NAME/multi-default-precision/g' > multi-default-precision.tex; $dir/myepstool.sh multi-default-precision