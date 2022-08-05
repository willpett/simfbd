#!/usr/bin/Rscript

suppressWarnings(suppressMessages(library(data.table)))
suppressWarnings(suppressMessages(library(reshape2)))
suppressWarnings(suppressMessages(library(ggplot2)))

args = commandArgs(trailingOnly=TRUE)
dir = args[1]

lambda <- c(0.1, 0.4, 0.2, 0.3)
mu <- c(0.2, 0.1, 0.4, 0.05)

truth = c(rev(lambda),rev(mu))

burnin=2000

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

baseLeft <- function(x, n){
  substr(x, 1, nchar(x)-1)
}

pyrate.mse = function(f) {
	df = fread(f,skip=burnin)[,12:19]
	err = apply(df, FUN=function(x){ (x - truth)^2 },1)
	mean( apply(err,FUN=mean,1) )
}

rb.mse = function(f) {
	df = fread(f,skip=burnin)[,6:13]
	err = apply(df, FUN=function(x){ (x - truth)^2 },1)
	mean( apply(err,FUN=mean,1) )
}

pyrate.means = function(f) {
	df = fread(f,skip=burnin)[,12:19]
	apply(df,FUN=mean,2)
}

rb.means = function(f) {
	df = fread(f,skip=burnin)[,6:13]
	apply(df,FUN=mean,2)
}

pyrate.files <- list.files(dir, pattern="pyrate.log", full.names=TRUE, recursive=TRUE)
rb.files <- paste(dirname(pyrate.files),"/rb.log",sep="")
psi.files <- paste(dirname(pyrate.files),"/psi.dat",sep="")

### Get psi

psi <- as.vector(sapply(psi.files, function(x){ read.table(x,header=F)$V1[1] }))

### Mean plots

segments.lambda = data.frame(
	Interval = as.factor(seq(0,3,1)),
	y = rev(lambda),
	variable = "speciation"
)

segments.mu = data.frame(
	Interval = as.factor(seq(0,3,1)),
	y = rev(mu),
	variable = "extinction"
)

segments = rbind(segments.lambda, segments.mu)
labels = c("speciation0","speciation1","speciation2","speciation3","extinction0","extinction1","extinction2","extinction3")

rb.mean <- data.frame(t(sapply(rb.files, FUN=rb.means) ))
pyrate.mean <- data.frame(t( sapply(pyrate.files, FUN=pyrate.means) ))

names(rb.mean) = labels
names(pyrate.mean) = labels

rb.mean$Method = "FBDRP"
pyrate.mean$Method = "BDS"

low_sampling = (psi < 0.1)

for(complete in c(TRUE,FALSE)) {

pdf(paste("means",complete,".pdf",sep=""))

all.means = rbind(rb.mean[low_sampling | complete,], pyrate.mean[low_sampling | complete,])

m.df <- melt(all.means, id.var="Method")
m.df$Interval = as.factor(substrRight(as.character(m.df$variable),1))
m.df$variable = as.factor(baseLeft(as.character(m.df$variable),1))

plot <- ggplot(m.df, aes(x=Interval, y=value)) +
#geom_segment(aes(x = x-0.5, y = y, xend = x+0.5, yend = y), data=segments) +
geom_boxplot(aes(fill=Method), outlier.shape = NA) +
geom_errorbar(data=segments, aes(y=y,ymin=y,ymax=y),size=1,colour="black",linetype="dashed",alpha=0.3) +
facet_wrap(variable ~ ., nrow = 2) + 
scale_y_continuous(limits = c(0,0.8)) +
theme(legend.key.size = unit(1, 'cm'),
		legend.key.height = unit(1, 'cm'),
		legend.key.width = unit(1, 'cm'),
		legend.title = element_text(size=16),
		legend.text = element_text(size=14)) +
ylab("Posterior Mean") +
theme(strip.text.x = element_text(size = 14))

print(plot)

dev.off()

}


### Error plot

pdf("mse.pdf")

rb.error <- as.vector(sapply(rb.files, FUN=rb.mse) )
pyrate.error <- as.vector(sapply(pyrate.files, FUN=pyrate.mse) )
diff = pyrate.error - rb.error

plot(psi,diff,ylim=c(-0.5,2),pch=18,xlab="Fossil Sampling Rate",ylab="Difference in MSE (BDS - FBDRP)")

dev.off()
