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
  
  times <- c(times, tree.max(tree.bd) )
  
  # simulate fossils
  s = sim.taxonomy(as.phylo(tree.bd))
  f = sim.fossils.intervals(rates=psi, interval.ages=times, taxonomy=s)
  
  extant = subset(s, round(end,13)==0)
  extant = extant[!(extant$sp %in% f$sp),]
  extant = extant %>% group_by(sp) %>% summarise(min = 0, max = 0) %>% rename(taxon=sp)
  
  taxon_data = f %>% group_by(sp) %>% summarise(min = round(min(hmin),13), max = round(max(hmax),13)) %>% rename(taxon=sp)
  
  taxon_data = full_join(extant, taxon_data)
  
  taxon_data$min[1:ntaxa]=0
  taxon_data <<- as.data.frame(taxon_data)
  
  i = 1
  
  new_col <- paste0("int",i)
  fossil_data = f %>% group_by(sp) %>% summarise(!!new_col := sum(hmin > times[i] & hmin < times[i+1])) %>% rename(taxon=sp)
  
  i = i+1
  
  while(i < length(times))
  {
	  new_col <- paste0("int",i)
	  df = f %>% group_by(sp) %>% summarise(!!new_col := sum(hmin > times[i] & hmin < times[i+1])) %>% rename(taxon=sp)
	  fossil_data = left_join(df, fossil_data, by = c("taxon"))
	  
	  i = i+1
  }
  
  for(e in extant$taxon)
  {
	  fossil_data = rbind(c(e, rep(0,length(times)-1)), fossil_data)
  }
  
  fossil_data <<- as.data.frame(fossil_data)
  
  pyrate = subset(as.data.frame(f), select=c("sp","hmin","hmax"))
  names(pyrate) = c("Species","min_age","max_age")
  
  txt = c("extinct","extant")
  
  status = s %>% group_by(sp) %>% summarise(Status = txt[sum(round(end,13)==0)+1]) %>% rename(Species=sp)
  pyrate <<- left_join(pyrate, status, by = c("Species")) %>% relocate(Status, .after = Species)
  
  0
}

test = NULL

while(is.null(test) || test=="stopped" || test=="errored")
{
  test=tryCatch({
    withTimeout( sim(), timeout=5, onTimeout="silent") 
  }, error=function(cond){
    print(cond)
    return("errored")
  })
}

write.table(psi[1],file="psi.dat",row.names=FALSE,col.names=FALSE)
write.table(taxon_data, "taxa.tsv", col.names = TRUE, row.names=FALSE, quote=FALSE, sep="\t")
write.table(fossil_data, "fossils.tsv", col.names = TRUE, row.names=FALSE, quote=FALSE, sep="\t")
write.table(pyrate, "pyrate.tsv", col.names = TRUE, row.names=FALSE, quote=FALSE, sep="\t")
extract.ages(file="pyrate.tsv",random=FALSE,replicates=1)
write.table(times[-1],file="epochs.txt",row.names=FALSE,col.names=FALSE)
