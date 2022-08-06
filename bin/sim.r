#!/usr/bin/Rscript

args = commandArgs(trailingOnly=TRUE)

suppressWarnings(suppressMessages(library(TreeSim)))
suppressWarnings(suppressMessages(library(FossilSim)))
suppressWarnings(suppressMessages(library(phytools)))
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(R.utils)))

params.file = args[1]

source("/usr/local/bin/PyRate/pyrate_utilities.r")

sim <- function(){
  # simulate fbd parameters
  # params = c(ntaxa, lambda, mu, psi)
  source(params.file)
  
  tree.bd <<- sim.rateshift.taxa(numbsim=1, n=ntaxa, frac = frac, lambda = lambda, mu = mu, times = times  )[[1]]
  
  if(tree.max(tree.bd) > max(times))
  { 
    times <- c(times,tree.max(tree.bd) )
  }
  else
  {
    times <- c(times,max(times)+10)
  }
  # simulate fossils
  s = sim.taxonomy(as.phylo(tree.bd))
  f = sim.fossils.intervals(rates=psi, interval.ages=times, taxonomy=s, use.exact.times=F)
  
  extant = subset(s, round(end,13)==0)
  extant = extant[!(extant$sp %in% f$sp),]
  extant = extant %>% group_by(sp) %>% summarise(min = 0, max = 0) %>% rename(taxon=sp)
  
  taxon_data = subset(as.data.frame(f), select=c("sp","hmin","hmax"))
  names(taxon_data) = c("taxon","min_age","max_age")
  
  txt = c("extinct","extant")
  
  status = s %>% group_by(sp) %>% summarise(status = txt[sum(round(end,13)==0)+1]) %>% rename(taxon=sp)
  taxon_data <<- left_join(taxon_data, status, by = c("taxon")) %>% relocate(status, .after = taxon)
 
  0
}

test=NULL
while(is.null(test) || test=="stopped" || test=="errored")
{
  test=tryCatch({
    withTimeout( sim(), timeout=5, onTimeout="silent") 
  }, error=function(cond){
    print(cond)
    return("errored")
  })
}
#print(c(tree.max(tree.bd),length(unique(taxon_data$taxon)),psi[1]))

write.table(psi[1],file="psi.dat",row.names=FALSE,col.names=FALSE)
write.table(cbind(lambda,mu)[which(times<max(taxon_data$max_age)),],file="lambdamu.dat",row.names=FALSE,col.names=TRUE)
write.table(taxon_data, "taxa.tsv", col.names = TRUE, row.names=FALSE, quote=FALSE, sep="\t")
extract.ages(file="taxa.tsv",random=FALSE,replicates=1)
write.table(times[-1],file="epochs.txt",row.names=FALSE,col.names=FALSE)
