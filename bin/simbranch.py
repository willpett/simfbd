#!/usr/bin/python


n = 1000
t = 1.0

b = str(t/n)

newick = '(' * (n-2)

newick += "(t_1:"+b+",t_2:0.0):"+b

for i in range(n - 2):
	newick += ",t_"+str(i+3)+":0.0):"+b

newick += ";"

print(newick)