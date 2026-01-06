#!/usr/bin/env python3

import pandas as pd
import csv
from Bio import SeqIO
import glob
import argparse
import os
from pathlib import Path

def start_end(fasta, contig_name):
    start = 1
    for record in SeqIO.parse(fasta, "fasta"):
        if record.id == contig_name:
            end = len(record.seq)
            return start, end
    return None, None

def mobsuite_to_gff(input_files, output_file):
    data = []


    for plasmid in input_files:
        plasmid_cluster = Path(plasmid).stem.split("_")[1]
        for record in SeqIO.parse(plasmid, "fasta"):
            seqid = record.id
            start, end = start_end(plasmid, seqid)
            if start is not None:
                entry = [seqid, "Mob-recon", "plasmid", start, end, ".", "+", ".", f"Cluster_ID={plasmid_cluster}"]
                data.append(entry)
    
    with open(output_file+"_mobsuite.gff", "w", newline="", encoding="utf-8") as tsvfile:
        writer = csv.writer(tsvfile, delimiter="\t")
        writer.writerows(data)

def virsorter2_to_gff(input_file, output_file):

    data = []
    df=pd.read_csv(input_file[0], sep='\t')
    for index, row in df.iterrows():
        complete=row['seqname_new'].split("||")[1]
        if "_" in complete:
            complete=complete.split("_")[1]
        start=row['trim_bp_start']
        end=row['trim_bp_end']
        if start>end:
            strand="-"
        else:
            strand="+"
        notes=f"Group={row['group']};Shape={row['shape']}"
        entry = [row["seqname"], "virsorter2", complete+"_phage", start, end, row['trim_pr'], strand, ".", notes]
        data.append(entry)
    with open(output_file+"_virsorter2.gff", "w", newline="", encoding="utf-8") as tsvfile:
        writer = csv.writer(tsvfile, delimiter="\t")
        writer.writerows(data)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert tool output to GFF format.")
    parser.add_argument("--input", required=True, help="Input directory or glob pattern",nargs="+")
    parser.add_argument("--mode", required=True, choices=["mobsuite", "virsorter2"], help="Mode to run (mobsuite or virsorter2)")
    parser.add_argument("--output", required=True, help="Output GFF filename")

    args = parser.parse_args()

    if args.mode == "mobsuite":
        mobsuite_to_gff(args.input, args.output)
    elif args.mode == "virsorter2":
        virsorter2_to_gff(args.input, args.output)
    
