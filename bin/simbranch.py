#!/usr/bin/python

import sys

taxfile = open("taxa.sa.tsv", "w")
trefile = open("tree.sa.tre", "w")

n = int(sys.argv[1])
t = float(sys.argv[2])

b = str(t/n)

newick = '(' * (n-2)

newick += "(t_1:"+b+",t_2:0.0):"+b

taxfile.write("taxon\tmin\tmax\n");
taxfile.write("t_1\t0.0\t0.0\n");
taxfile.write("t_2\t"+b+"\t"+b+"\n");

for i in range(n - 2):
	taxon = "t_"+str(i+3)
	age = str((i+2)*t/n)
	newick += ","+taxon+":0.0):"+b
	taxfile.write(taxon+"\t"+age+"\t"+age+"\n")

newick += ";"

trefile.write(newick)

taxfile.close()
trefile.close()
