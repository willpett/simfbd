#!/usr/local/bin/python

import multiprocessing as mp
import subprocess
import sys
import os
import re

from optparse import OptionParser

parser = OptionParser()
parser.add_option("-n", "--nreps", dest="n",
                  help="number of replicates", metavar="N")
parser.add_option("-k", "--ncpu", dest="k",
                  help="number of cpus", metavar="K")

(options, args) = parser.parse_args()

if (not os.path.isfile("params.r") or not os.path.isfile("prior.rev")) and not options.fixed:
	raise Exception("params.r/prior.rev file not found")

os.system('rm -rf sims')
os.system('mkdir sims')

bindir = os.path.dirname(os.path.abspath(__file__))
simdir = os.path.abspath(os.getcwd())

def simulate(i):
	print(simdir)
	os.chdir(simdir+'/sims')
	ext = ("%0"+str(len(options.n))+"d") % (i + 1)
	os.system('mkdir sim'+ext)
	os.chdir('sim'+ext)

	os.system(bindir+'/simfbd.r ../../params.r')	

	os.system('rb '+bindir+'/infer-range.rev')

	os.system(bindir+'/summarize.r '+options.infer)

def main():
	pool = mp.Pool(processes=int(options.k))

	for i in range(int(options.n)):
		pool.apply_async(simulate, args=(i,))

	pool.close()
	pool.join()

if __name__ == "__main__":
    main()
