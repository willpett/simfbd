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
parser.add_option("-s", "--sim", dest="sim",
                  help="character simulation model", default="none", metavar="SIM")
parser.add_option("-i", "--infer", dest="infer",
                  help="inference model", default="range", metavar="SIM")
parser.add_option("-f", "--fixed",
                  action="store_true", dest="fixed", default=False,
                  help="use fixed tree simulation")

(options, args) = parser.parse_args()

char_models = ['none','asym','mk']
inf_models = ['range','tree','mk','mixed','mk-mixed']

if options.sim not in char_models:
	raise Exception("Morphological model must be one of: "+str(models))

if options.sim == "mk" and not os.path.isfile("rateprior.rev"):
	raise Exception("rateprior.rev file not found")

if (not os.path.isfile("params.r") or not os.path.isfile("prior.rev")) and not options.fixed:
	raise Exception("params.r/prior.rev file not found")

if re.search('mk',options.infer) and options.sim == 'none':
	raise Exception("cannot infer mk without simulating character data")

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

	if options.sim == 'asym':
		os.system('rb '+bindir+'/sim-asym.rev')
		os.system('cp taxa.fbd.tsv diagnosed.taxa')
		os.system('cp asym.nex diagnosed.nex')
	elif options.sim == 'mk':
		os.system('rb '+bindir+'/sim-mk.rev')
		os.system(bindir+'/diagnose.py mk.fa taxa.sa.tsv')
	else:
		os.system('cp taxa.fbd.tsv diagnosed.taxa')

	if options.infer == 'mk':
		os.system('rb '+bindir+'/infer-mk.rev')
	elif options.infer == 'mk-fixed':
		os.system('rb '+bindir+'/infer-mk-fixed.rev')
	elif options.infer == 'mk-mixed':
		os.system('rb '+bindir+'/infer-mk-mixed.rev')
	elif options.infer == 'msp-fixed':
		os.system('rb '+bindir+'/infer-msp-fixed.rev')
	elif options.infer == 'tree':
		os.system('rb '+bindir+'/infer-tree.rev')
	elif options.infer == 'tree-mixed':
		os.system('rb '+bindir+'/infer-tree-mixed.rev')
	elif options.infer == 'tree-fixed':
		os.system('rb '+bindir+'/infer-tree-fixed.rev')
	elif options.infer == 'tree-specimen':
		os.system('rb '+bindir+'/infer-tree-specimen.rev')
	elif options.infer == 'extended-sampled':
		os.system('rb '+bindir+'/infer-tree-extended.rev')
		os.system(bindir+'/summarize.r '+options.infer+' rb-extended.log')
		os.system('rb '+bindir+'/infer-tree-sampled.rev')
		os.system(bindir+'/summarize.r '+options.infer+' rb-sampled.log')
		return
	else:
		os.system('rb '+bindir+'/infer-range.rev')

	os.system(bindir+'/summarize.r '+options.infer)

pool = mp.Pool(processes=int(options.k))

for i in range(int(options.n)):
	pool.apply_async(simulate, args=(i,))

pool.close()
pool.join()
