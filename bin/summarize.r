#!/usr/local/bin/Rscript

#!/usr/local/bin/Rscript

args = commandArgs(trailingOnly=TRUE)

x = read.table("rb.log",header=TRUE)

x = x[-(1:500),]

params = c( mean(x$lambda), quantile(x$lambda, c(0.05, 0.5, 0.95) ), mean(x$mu), quantile(x$mu, c(0.05, 0.5, 0.95) ), mean(x$psi), quantile(x$psi, c(0.05, 0.5, 0.95) )  )

if(length(args))
{
	params = c(params, mean(x$rate), quantile(x$rate, c(0.05, 0.5, 0.95) ) )
}

write(params,file="params.inferred", append=FALSE, sep="\t", ncolumns=length(params))