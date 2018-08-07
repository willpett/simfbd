#!/usr/local/bin/python

import multiprocessing as mp
import subprocess
import sys
import os

from optparse import OptionParser

parser = OptionParser()
parser.add_option("-n", "--nreps", dest="n",
                  help="number of replicates", metavar="N")
parser.add_option("-k", "--ncpu", dest="k",
                  help="number of cpus", metavar="K")
parser.add_option("-m", "--model", dest="model",
                  help="morphological model to use", default="none", metavar="MODEL")
parser.add_option("-t", "--tree",
                  action="store_true", dest="tree", default=False,
                  help="use the full FBD tree model")
parser.add_option("-f", "--fixed",
                  action="store_true", dest="fixed", default=False,
                  help="use fixed FBD tree")


(options, args) = parser.parse_args()

models = ['asym','mk','none']

if options.model not in models:
	raise Exception("Morphological model must be one of: "+str(models))

if options.model == "mk" and not os.path.isfile("rateprior.rev"):
	raise Exception("rateprior.rev file not found")

if (not os.path.isfile("params.r") or not os.path.isfile("prior.rev")) and not options.fixed:
	raise Exception("params.r/prior.rev file not found")


os.system('rm -rf sims')
os.system('mkdir sims')

bindir = os.path.dirname(os.path.abspath(__file__))
simdir = os.path.abspath(os.getcwd())

def simulate(i):
	os.chdir(simdir+'/sims')
	ext = ("%0"+str(len(options.n))+"d") % (i + 1)
	os.system('mkdir sim'+ext)
	os.chdir('sim'+ext)

	if not options.fixed:
		os.system(bindir+'/simfbd.r ../../params.r')
	else:
		os.system('cp ../../tree.bd.tre ./')
		os.system('cp ../../tree.complete.tre ./')
		os.system('cp ../../taxa.fbd.tsv ./')
		os.system('cp ../../tree.fbd.tre ./')
		os.system('cp ../../taxa.sa.tsv ./')
		os.system('cp ../../tree.sa.tre ./')		

	if options.model == 'asym':
		os.system('rb '+bindir+'/sim-asym.rev')
		os.system('cp taxa.fbd.tsv diagnosed.taxa')
		os.system('cp asym.nex diagnosed.nex')
	elif options.model == 'mk' or options.fixed:
		os.system('rb '+bindir+'/sim-mk.rev')
		os.system(bindir+'/diagnose.py mk.fa taxa.sa.tsv')
	else:
		os.system('cp taxa.fbd.tsv diagnosed.taxa')

	if options.tree:
		if options.model == 'none':
			os.system('rb '+bindir+'/infer-tree.rev')
			os.system(bindir+'/summarize.r')
		else:
			os.system('rb '+bindir+'/infer-mk.rev')
			os.system(bindir+'/summarize.r 1')
	else:
		os.system('rb '+bindir+'/infer-range.rev')
		os.system(bindir+'/summarize.r')

pool = mp.Pool(processes=int(options.k))

for i in range(int(options.n)):
	pool.apply_async(simulate, args=(i,))

pool.close()
pool.join()
