#!/usr/bin/bash -l
module load minimap2
minimap2 --cs=long  -t 4 -x asm20 Rhodotorula_mucilaginosa_NRRL_Y-2510.fsa Rhodotorula_mucilaginosa_DBVPG_3857.scaffolds.fa > DBVPG_3857.paf

paf2pid.py DBVPG_3857.paf > DBVPG_3857.pid


