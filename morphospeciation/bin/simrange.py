#!/usr/bin/python

n = 100
dtA = 0.1
dtB = 0.1

print("taxon\tmin\tmax")

trefile = open("tree.fbd.tre", "w")

b = str(dtA+dtB)

newick = '(' * (n-2)
newick += "(t0:"+b+",t1:0.0):"+b

prev = 0.0 - dtB

for i in range(n):
	if i > 1:
		taxon = "t"+str(i)
		newick += ","+taxon+":0.0):"+b

	min = prev + dtB
	max = min + dtA

	prev = max

	print "t%d\t%f\t%f" % (i,min,max)

newick += ";"

trefile.write(newick)
trefile.close()
