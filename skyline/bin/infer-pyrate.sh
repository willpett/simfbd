/usr/local/bin/PyRate/PyRate.py pyrate_PyRate.py -fixShift epochs.txt -cauchy 0 0 -n 1000000 -s 100 -out _$1
cp /usr/local/bin/PyRate/pyrate_mcmc_logs/pyrate_1_$1_BDS_mcmc.log ./pyrate.log
