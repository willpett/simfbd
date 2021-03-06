#!/usr/local/bin/Rscript

if(length(suppressWarnings(system('find sims -type f | grep inferred',intern=T))) == 0)
{
	cat("no completed simulations\n")
	quit()
}

args = commandArgs(trailingOnly=TRUE)

sim.type = args[1]
inf.type = args[2]

catcmd <- function(x)
{
	r = paste('find sims -type f | grep inferred | xargs dirname | awk \'{print $1"/',x,'"}\' | xargs cat > ',x,collapse="",sep="")
	return(r)
}

system(catcmd("params.fbd"))
system(catcmd("params.inferred"))

if(sim.type == "mk")
{
	system(catcmd("params.mk"))
}

true = read.table("params.fbd")
sim = read.table("params.inferred")

names(true) = c("n","lambda","mu","psi")
names.sim = c("lambda","lambda.05","lambda.median","lambda.95","mu","mu.05","mu.median","mu.95","psi","psi.05","psi.median","psi.95")
if(inf.type == "mk" || inf.type == "mk-fixed" || inf.type == "msp-fixed")
{
	names.sim = c(names.sim,"rate","rate.05","rate.median","rate.95")
}
names(sim) = names.sim

l = min(length(true$lambda),length(sim$lambda))

if(sim.type == "mk")
{
	mk = read.table("params.mk")
	names(mk) = c("rate","n")
	l = min(l,length(mk$rate))
	mk = mk[1:l,]
}

true = true[1:l,]
sim = sim[1:l,]

lambda.coverage = sum(true$lambda > sim$lambda.05 & true$lambda < sim$lambda.95)/l
mu.coverage = sum(true$mu > sim$mu.05 & true$mu < sim$mu.95)/l
psi.coverage = sum(true$psi > sim$psi.05 & true$psi < sim$psi.95)/l

cat("lambda\t",lambda.coverage,"\n")
cat("mu\t",mu.coverage,"\n")
cat("psi\t",psi.coverage,"\n")

lambda.max = max(c(true$lambda,sim$lambda))
mu.max = max(c(true$mu,sim$mu))
psi.max = max(c(true$psi,sim$psi))

al = 1.5

pdf("sim.pdf")
plot(true$lambda, sim$lambda, cex.lab=al, xlim=c(0,lambda.max),ylim=c(0,lambda.max),xlab=expression(paste("true ", lambda)), ylab=expression(paste("inferred ", lambda)))
abline(0,1)
plot(true$mu, sim$mu, cex.lab=al, xlim=c(0,mu.max),ylim=c(0,mu.max), xlab=expression(paste("true ", mu)),ylab=expression(paste("inferred ", mu)))
abline(0,1)
plot(true$psi, sim$psi, cex.lab=al, xlim=c(0,psi.max),ylim=c(0,psi.max), xlab=expression(paste("true ", psi)),ylab=expression(paste("inferred ", psi)))
abline(0,1)

if(inf.type == "mk" || inf.type == "mk-fixed" || inf.type == "msp-fixed")
{
	if(sim.type == "mk")
	{
		rate.coverage = sum(mk$rate > sim$rate.05 & mk$rate < sim$rate.95)/l
		cat("rate\t",rate.coverage,"\n")

		rate.max = max(c(mk$rate,sim$rate))
		plot(mk$rate, sim$rate, cex.lab=al, xlim=c(0,rate.max),ylim=c(0,rate.max), xlab="true morphological substitution rate",ylab="inferred morphological substitution rate")
		abline(0,1)
	}
	else
	{
		rate.max = max(c(true$lambda,sim$rate*1000))
                plot(true$lambda, sim$rate*1000, cex.lab=al, xlim=c(0,rate.max),ylim=c(0,rate.max), xlab=expression(paste("true ", lambda)),ylab="inferred morphological substitution rate")
                abline(0,1)

		rate.max = max(c(sim$lambda,sim$rate*1000))
		plot(sim$lambda, sim$rate*1000, cex.lab=al, xlim=c(0,rate.max),ylim=c(0,rate.max), xlab=expression(paste("inferred ", lambda)),ylab="inferred substitution rate * n")
		abline(0,1)

                hist(sim$lambda/sim$rate,prob=T,breaks=20,cex.lab=al, xlab=expression(paste(lambda, "/rate")),main="",ylab="")
                abline(v=1000,col="red",lwd=2)
	}
}

garbage <- dev.off()
