#!/usr/bin/env python3

import csv
import argparse
import os
import re

def get_args():
    parser = argparse.ArgumentParser(description="Setup and link data for candidate diploid/hybrids.")
    parser.add_argument('-d', '--directory',
        type=str,
        default='/bigdata/stajichlab/shared/projects/Rhodotorula/ExtremeRhodotorula_DraftGenomes/',
        help='Directory containing the assembly / annotation data files (default: %(default)s)'
    )
    parser.add_argument('-a', '--annotation',
        type=str,
        default='annotation',
        help='Directory containing the annotations by species (default: %(default)s)'
    )
    parser.add_argument('-t','--target', type=str, default='annotations', 
                        help='Target to copy annotations (default: %(default)s)')

    parser.add_argument('-s','--stats', type=str, default='asm_stats.tsv', 
                        help='Assembly stats file (default: %(default)s)')
    parser.add_argument('-m','--samples', type=str, default='samples.csv', 
                        help='Sample metadata file (default: %(default)s)')
    parser.add_argument('-c','--cutoff', type=int, default=30000000, 
                        help='Lower bound cutoff size for detecting non-haploids (default: %(default)s)')
    
    return parser.parse_args()

args = get_args()
if not os.path.exists(args.target):
    os.mkdir(args.target)
    os.mkdir(os.path.join(args.target,'cds'))
    os.mkdir(os.path.join(args.target,'gff'))
    os.mkdir(os.path.join(args.target,'dna'))
    
sample_metadata = {}
with open(os.path.join(args.directory,args.samples), 'r') as fh:
    samples = csv.DictReader(fh)
    for row in samples:
        sample_metadata[row['Strain']] = row

with open(os.path.join(args.directory,args.stats), 'r') as fh:
    stats = csv.DictReader(fh, delimiter="\t")
    for row in stats:
        if int(row['TOTAL_LENGTH']) > args.cutoff:
#            print(f"{row['SampleID']}\t{row['TOTAL_LENGTH']}")
            id = row['SampleID'].split('.')[0]
            if id in sample_metadata:
                species = sample_metadata[id]['Species'] + "_" + sample_metadata[id]['Strain']
                species = species.replace(' ','_')
                if os.path.exists(os.path.join(args.directory,args.annotation)):
                    print(f"{id} {species} {os.path.join(args.directory,args.annotation)}")
                    cds = os.path.join(args.target,'cds',f'{species}.cds.fa')
                    dna = os.path.join(args.target,'dna',f'{species}.scaffolds.fa')
                    gff = os.path.join(args.target,'gff',f'{species}.gff3')

                    if not os.path.exists(cds):
                        os.symlink(os.path.join(args.directory,args.annotation,species,
                                                'predict_results',
                                                f'{species}.cds-transcripts.fa'),
                                                cds)
                    if not os.path.exists(gff):
                        os.symlink(os.path.join(args.directory,args.annotation,species,
                                                'predict_results',
                                                f'{species}.gff3'),
                                                gff)
                    if not os.path.exists(dna):
                        os.symlink(os.path.join(args.directory,args.annotation,species,
                                                'predict_results',
                                                f'{species}.scaffolds.fa'),
                                                dna)

                else:
                    print(f"Error: No annotation for {id} {species}",file=sys.stderr)
            else:
                print(f"Error: {id} not found",file=sys.stderr)
