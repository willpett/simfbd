#!/usr/local/bin/Rscript

true = read.table("params.true")
sim = read.table("params.inferred")

names(true) = c("n","lambda","mu","psi")
names(sim) = c("lambda","lambda.05","lambda.median","lambda.95","mu","mu.05","mu.median","mu.95","psi","psi.05","psi.median","psi.95")

l = min(length(true$lambda),length(sim$lambda))

true = true[1:l,]
sim = sim[1:l,]

lambda.coverage = sum(true$lambda > sim$lambda.05 & true$lambda < sim$lambda.95)/l
mu.coverage = sum(true$mu > sim$mu.05 & true$mu < sim$mu.95)/l
psi.coverage = sum(true$psi > sim$psi.05 & true$psi < sim$psi.95)/l

print(lambda.coverage)
print(mu.coverage)
print(psi.coverage)

lambda.max = max(c(true$lambda,sim$lambda))
mu.max = max(c(true$mu,sim$mu))
psi.max = max(c(true$psi,sim$psi))

pdf("sim.pdf")
plot(true$lambda, sim$lambda, xlim=c(0,lambda.max),ylim=c(0,lambda.max),xlab="true lambda", ylab="inferred lambda")
abline(0,1)
plot(true$mu, sim$mu, xlim=c(0,mu.max),ylim=c(0,mu.max), xlab="true mu",ylab="inferred mu")
abline(0,1)
plot(true$psi, sim$psi, xlim=c(0,psi.max),ylim=c(0,psi.max), xlab="true psi",ylab="inferred psi")
abline(0,1)
dev.off()
