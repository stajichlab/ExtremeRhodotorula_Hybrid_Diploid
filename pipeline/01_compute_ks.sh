#!/usr/bin/bash -l
#SBATCH -c 32 -n 1 -N 1 --mem 32gb --out logs/ksd.%a.log

CPU=2
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi

module load wgd
module load workspace/scratch

INDIR=annotations
OUTDIR=wgd
mkdir -p $OUTDIR
INFILE=$(ls $INDIR/cds/*.cds.fa | sed -n ${N}p)
STRAIN=$(basename $INFILE .cds.fa)
RBH=$OUTDIR/$STRAIN/dmd/$(basename $INFILE).tsv
KSDIST=$OUTDIR/$STRAIN/ksd/$(basename $INFILE).tsv.ks.tsv
mkdir -p $OUTDIR/$STRAIN

if [ ! -f $RBH ]; then
    wgd dmd -o $OUTDIR/$STRAIN/dmd $INFILE -t $SCRATCH -n $CPU
fi

if [ ! -f $KSDIST  ]; then
    wgd ksd $RBH $INFILE -o $OUTDIR/$STRAIN/ksd -t $SCRATCH -n $CPU
fi

#if [ ! -s $OUTDIR/$STRAIN/ ]; then
    wgd peak $KSDIST -o $OUTDIR/$STRAIN/wgd_peak > $OUTDIR/$STRAIN/wgd_peak.txt
#fi
