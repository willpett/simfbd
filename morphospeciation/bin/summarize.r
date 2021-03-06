#!/usr/local/bin/Rscript

args = commandArgs(trailingOnly=TRUE)

filename = "rb.log"

if ( length(args) > 1 )
{
	filename <- args[2]
}

x = read.table(filename,header=TRUE)

x = x[-(1:500),]

params = c( mean(x$lambda), quantile(x$lambda, c(0.05, 0.5, 0.95) ), mean(x$mu), quantile(x$mu, c(0.05, 0.5, 0.95) ), mean(x$psi), quantile(x$psi, c(0.05, 0.5, 0.95) )  )

if(length(args))
{
	if(args[1] == "mk" || args[1] == "mk-mixed" || args[1] == "mk-fixed" || args[1] == "msp" || args[1] == "msp-fixed")
	{
		params = c(params, mean(x$rate), quantile(x$rate, c(0.05, 0.5, 0.95) ) )
	}
	if(args[1] == "mixed" || args[1] == "mk-mixed")
	{
		params = c(params, mean(x$lambda_a), quantile(x$lambda_a, c(0.05, 0.5, 0.95) ) )
	}
}

outfile = "params.inferred"

if ( length(args) > 1 )
{
	outfile = gsub(".log", ".inferred", args[2])
}

write(params,file=outfile, append=FALSE, sep="\t", ncolumns=length(params))
