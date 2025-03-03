#!/usr/bin/bash -l
#SBATCH -c 32 -n 1 -N 1 --mem 32gb --out logs/ksd_interp.%a.log

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
OUTDIR=undup_cmp
mkdir -p $OUTDIR
REF=undup/cds/Rhodotorula_mucilaginosa_DBVPG_3775.cds.fa
REFSTRAIN=$(basename $REF .cds.fa)
INFILE=$(ls $INDIR/cds/*.cds.fa | sed -n ${N}p)
STRAIN=$(basename $INFILE .cds.fa)
RBH=$OUTDIR/$STRAIN/dmd/Orthogroups.representives.tsv
RBH=$OUTDIR/$STRAIN/dmd/Orthogroups.sp.tsv
KSDIST=$OUTDIR/$STRAIN/ksd/$(basename $INFILE).tsv.ks.tsv
mkdir -p $OUTDIR/$STRAIN

if [ ! -f $RBH ]; then
    time wgd dmd -o $OUTDIR/$STRAIN/dmd $INFILE $REF -t $SCRATCH -n $CPU -oi -oo -t $SCRATCH -bs 100 
fi

if [ ! -f $KSDIST  ]; then
    time wgd ksd $RBH $INFILE $REF -o $OUTDIR/$STRAIN/ksd -t $SCRATCH -n $CPU
fi

