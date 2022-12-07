# Written By: Suhail Ghafoor
# Date: May 19 2022

import io
import os
import pandas as pd
import socket
import csv
import argparse

parser = argparse.ArgumentParser(description="Converts a VCF file to a csv representation for our graph")
parser.add_argument('--input', required=True)
parser.add_argument('--output', required=True)
args = parser.parse_args()

file_path = args.input
filename = os.path.basename(file_path)
csv_path = args.output

print("Input file", file_path)
print("Output file", csv_path)

# Parameters
chromesome = "CM009259.2" # This is printed in the chromosome column in the final csv
chr_path = "CM009259.2.fa" # Path to chr fasta

# Function copied from https://gist.github.com/dceoy/99d976a2c01e7f0ba1c813778f9db744
def read_vcf(path):
    with open(path, 'r') as f:
        lines = [l for l in f if not l.startswith('##')]
    return pd.read_csv(
        io.StringIO(''.join(lines)),
        dtype={'POS': int, 'REF': str, 'ALT': str},
        usecols=['POS', 'REF', 'ALT'],
        sep='\t'
    ).rename(columns={'#CHROM': 'CHROM'})

# Converted from SLiM code written by me
def build_codon():
    genes = ['A', 'C', 'G', 'T']
    codon = {}

    for i in genes:
        for j in genes:
            for k in genes:
                for l in genes:
                    if j != l:
                        codon[(i + j + k + '>' + l)] = 0
    return codon

def write_dict_to_csv(codon):
    print("Creating file", csv_path)
    with open(csv_path, 'w') as csv_file:
        header = csv.DictWriter(csv_file, codon.keys())
        header.writeheader()
        header.writerow(codon)


#Variables
fasta_file = ''.join(open(chr_path).readlines()[0]).replace('\n', '')

info = {
    "pop": filename[filename.find("pop") + 3],
    "chr": chromesome,
    "seed": filename.split("_")[0],
    "sample_size": filename.split('_')[-2],
    "total_mut": 0,
    "hostname": socket.gethostname(),
    "username": os.environ.get('USER'),
    "draw": filename.split('_')[3].split('.')[0]
}
codon = build_codon()
codon = {**codon, **info}
vcf_frame = read_vcf(file_path)

for index, row in vcf_frame.iterrows():
    sequence = fasta_file[row['POS'] - 2:row['POS']+1] + '>' + row['ALT'][0]
    if sequence in codon:
        codon["total_mut"] += 1
        codon[sequence] += 1
    else:
        pass
write_dict_to_csv(codon)

print("Done!")
