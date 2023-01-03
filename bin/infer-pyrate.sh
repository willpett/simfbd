/usr/local/bin/PyRate/PyRate.py taxa_PyRate.py -fixShift epochs.txt -cauchy 0 0 -n 1000000 -s 100 -p 1000000 -out _$1
mv /usr/local/bin/PyRate/pyrate_mcmc_logs/taxa_1_$1_BDS_mcmc.log ./pyrate.log
rm /usr/local/bin/PyRate/pyrate_mcmc_logs/taxa_1_$1_BDS_*
