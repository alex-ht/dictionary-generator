#!/bin/bash
outdir=moedict
[ ! -d $outdir ] && mkdir -p $outdir
for f in dict_revised_1.xls dict_revised_2.xls dict_revised_3.xls; do
  wget https://github.com/g0v/moedict-data/raw/master/dict_revised/$f -O $outdir/$f
done

exit 0;
