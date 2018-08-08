#!/usr/local/bin/Rscript

args = commandArgs(trailingOnly=TRUE)

if(length(suppressWarnings(system('find sims -type f | grep inferred',intern=T))) == 0)
{
        cat("no completed simulations\n")
        quit()
}

args = commandArgs(trailingOnly=TRUE)

sim.type = args[1]
inf.type = args[2]

cat <- function(x)
{
        r = paste('find sims -type f | grep inferred | xargs dirname | awk \'{print $1"/',x,'"}\' | xargs cat > ',x,collapse="",sep="")
        return(r)
}

system(cat("params.fbd"))
system(cat("params.inferred"))

if(sim.type == "mk")
{
        system(cat("params.mk"))
}

sim = read.table("params.inferred")

names(sim) = c("lambda","mu","psi")
names.sim = c("lambda","lambda.05","lambda.median","lambda.95","mu","mu.05","mu.median","mu.95","psi","psi.05","psi.median","psi.95")
if(inf.type == "mk")
{
	names.sim = c(names.sim,"rate","rate.05","rate.median","rate.95")
}
names(sim) = names.sim

if(sim.type == "mk")
{
	mk = read.table("params.mk")
	names(mk) = c("rate","n")
}

l = min(length(sim$lambda),length(mk$rate))

sim = sim[1:l,]
mk = mk[1:l,]

xlims = c(0.0001,0.025)

pdf("sim.pdf")
plot(mk$rate, sim$lambda,log="xy", xlab="morphological substitution rate", ylab="lambda")
abline(h=1/3,col="red")
plot(mk$rate, sim$mu,log="xy", xlab="morphological substitution rate",ylab="mu")
abline(h=1/10,col="red")
plot(mk$rate, sim$psi,log="xy", xlab="morphological substitution rate",ylab="psi")
abline(h=1/2,col="red")
plot(mk$rate, mk$n,log="xy", xlab="morphological substitution rate",ylab="# diagnosed species")
if(inf.type == "mk")
{
	plot(mk$rate, sim$rate, xlab="morphological substitution rate",ylab="inferred rate")
	abline(0,1)
}
dev.off()
