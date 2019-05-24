#!/usr/local/bin/Rscript

if(length(suppressWarnings(system('find sims -type f | grep inferred',intern=T))) == 0)
{
	cat("no completed simulations\n")
	quit()
}

catcmd <- function(x)
{
	r = paste('find sims -type f | grep rb-sampled.inferred | xargs dirname | awk \'{print $1"/',x,'"}\' | xargs cat > ',x,collapse="",sep="")
	return(r)
}

system(catcmd("rb-extended.inferred"))
system(catcmd("rb-sampled.inferred"))

extended = read.table("rb-extended.inferred")
sampled = read.table("rb-sampled.inferred")

names.sim = c("lambda","lambda.05","lambda.median","lambda.95","mu","mu.05","mu.median","mu.95","psi","psi.05","psi.median","psi.95")

names(extended) = names.sim
names(sampled) = names.sim

overlap.lambda = (abs(extended$lambda.05-sampled$lambda.05)+abs(extended$lambda.95-sampled$lambda.95))/(extended$lambda.95-extended$lambda.05 + sampled$lambda.95-sampled$lambda.05)
x <- data.frame(overlap.lambda)

x$overlap.mu = (abs(extended$mu.05-sampled$mu.05)+abs(extended$mu.95-sampled$mu.95))/(extended$mu.95-extended$mu.05 + sampled$mu.95-sampled$mu.05)
x$overlap.psi = (abs(extended$psi.05-sampled$psi.05)+abs(extended$psi.95-sampled$psi.95))/(extended$psi.95-extended$psi.05 + sampled$psi.95-sampled$psi.05)

write.table(x,"test.dat",quote=F,row.names=F,sep="\t")
