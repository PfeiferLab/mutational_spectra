#!/bin/bash

# Written By Suhail Ghafoor
# Date 7 Dec 2022

# This code choose $3 amount of individuals from the input $1 vcf
# and prints the list of individuals to $2 file. This is kept as
# a separate step for debugging purposes.

# Usage
# $1 path to input vcf
# $2 path to output list
# $3 number of desired samples

in_vcf=$1
out_list=$2
sample_size=$3

NUM=15 # This line contains column headers
pop_amount=$(sed "${NUM}q;d" $in_vcf | awk -F' ' '{print NF; exit}') # Get number of columns in pop
pop_amount=$((pop_amount-10)) # Subtract first 10 metadata columns
entries=($(shuf -i 0-$pop_amount -n $sample_size)) # Select $sample_size number of individuals from 0 to $pop_amount
printf "i%s\n" "${entries[@]}" > $out_list # print the selected individuals to given file