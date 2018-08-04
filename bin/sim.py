#!/usr/local/bin/python

import multiprocessing as mp
import subprocess
import sys
import os

n = int(sys.argv[1])
k = int(sys.argv[2])
analysis = sys.argv[3]

os.system('rm -rf sims')
os.system('mkdir sims')

bindir = os.path.dirname(os.path.abspath(__file__))
simdir = os.path.abspath(os.getcwd())

def simulate(i):
	os.chdir(simdir+'/sims')
	ext = ("%0"+str(len(str(n)))+"d") % (i + 1)
	os.system('mkdir sim'+ext)
	os.chdir('sim'+ext)

	os.system(bindir+'/simfbd.r ../../params.r')
	if analysis == 'morpho':
		os.system('rb '+bindir+'/simnex.rev')
	os.system('rb '+bindir+'/infer-'+analysis+'.rev')
	os.system(bindir+'/summarize.r '+analysis)

pool = mp.Pool(processes=k)

for i in range(n):
	pool.apply_async(simulate, args=(i,))

pool.close()
pool.join()