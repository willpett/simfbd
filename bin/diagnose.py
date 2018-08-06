#!/usr/local/bin/python

import sys
import math
import os

from Bio.Seq import Seq
from Bio.Alphabet import generic_alphabet

seqfile = sys.argv[1]
taxfile = sys.argv[2]

taxa = {}

first = True
with open(taxfile, "r") as f:
	for line in f:
		if first:
			first = False
			continue
		sid,minage,maxage=line.split("\t")
		taxa[sid] = float(minage)

species = {}

i = 1

ranges = {}

lastseq = None
variable = None

from Bio import SeqIO
for record in SeqIO.parse(seqfile, "fasta"):
	sid = record.id
	seq = str(record.seq)

	if seq not in species:
		new_record = record
		new_record.seq = record.seq
		new_record.id = "s_"+str(i)
		new_record.description = record.id

		species[seq] = new_record
		i += 1

	new_record = species[seq]

	if new_record.id not in ranges:
		ranges[new_record.id] = [math.inf,0]

	if taxa[sid] < ranges[new_record.id][0]:
		ranges[new_record.id][0] = taxa[sid]
		
	if taxa[sid] > ranges[new_record.id][1]:
		ranges[new_record.id][1] = taxa[sid]

with open('diagnosed.taxa', 'w') as f:
    f.write("taxon\tmin\tmax\n")

    for s in ranges:
    	f.write(s+"\t"+str(ranges[s][0])+"\t"+str(ranges[s][1])+"\n")
    	

with open("diagnosed.fa", "w") as output_handle:
    SeqIO.write(species.values(), output_handle, "fasta")

os.system('aln2aln -from fasta -to nexus -i diagnosed.fa -o diagnosed.nex')
os.system("sed -i '' 's/protein/restriction/' diagnosed.nex")
os.system("sed -i '' 's/ symbols.*;/;/' diagnosed.nex")

with open('params.mk', 'a') as f:
    f.write(str(len(ranges))+"\n")
