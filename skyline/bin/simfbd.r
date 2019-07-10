#!/usr/local/bin/Rscript

args = commandArgs(trailingOnly=TRUE)

suppressWarnings(suppressMessages(library(TreeSim)))
suppressWarnings(suppressMessages(library(FossilSim)))
suppressWarnings(suppressMessages(library(ape)))
suppressWarnings(suppressMessages(library(R.utils)))
suppressWarnings(suppressMessages(library(MCMCpack)))

params.file = args[1]

n.ages<-function(tree){

  depth = ape::node.depth.edgelength(tree)
  node.ages = max(depth) - depth
  names(node.ages) <- 1:(tree$Nnode+length(tree$tip))

  # adding possible offset if tree fully extinct
  if(!is.null(tree$root.time)) node.ages = node.ages + tree$root.time - max(node.ages)

  return(node.ages)
}

is.extinct <- function (phy, tol=NULL) {
    if (!"phylo" %in% class(phy)) {
        stop("\"phy\" is not of class \"phylo\".");
    }
    if (is.null(phy$edge.length)) {
        stop("\"phy\" does not have branch lengths.");
    }
    if (is.null(tol)) {
        tol <- min(phy$edge.length)/100;
    }
    Ntip <- length(phy$tip.label)
    phy <- ape::reorder.phylo(phy);
    xx <- numeric(Ntip + phy$Nnode);
    for (i in 1:length(phy$edge[,1])) {
        xx[phy$edge[i,2]] <- xx[phy$edge[i,1]] + phy$edge.length[i];
    }
    aa <- max(xx[1:Ntip]) - xx[1:Ntip] > tol;
    if (any(aa)) {
        return(phy$tip.label[which(aa)]);
    } else {
        return(NULL);
    }
}

sim <- function(){
  # simulate fbd parameters
  # params = c(ntaxa, lambda, mu, psi)
  source(params.file)

  # simulate bd tree
  tree.bd <<- sim.rateshift.taxa(ntaxa, 1, lambda=lambda, mu=mu, frac=1, times=times)[[1]]
  
  node.ages <- n.ages(tree.bd)

  origin = max(node.ages) + tree.bd$root.edge

  times <- c(times, max(origin+1,max(times)+1))
  # simulate fossils
  s = sim.taxonomy(tree.bd)
  f = sim.fossils.intervals(rates=psi, interval.ages=times, taxonomy=s)

  # build fbd tree
  tree <- SAtree.from.fossils(tree.bd,f)

  tree.complete <<- tree

  fossil.tips = is.extinct(tree, tol=0.00000001)
  sa.tips = tree$tip.label[tree$edge[,2][(tree$edge[,2] %in% 1:length(tree$tip.label)) & (tree$edge.length == 0.0)]]
  unsampled.tips = fossil.tips[!(fossil.tips %in% sa.tips)]
  tmp <- ape::drop.tip(tree, unsampled.tips)
  node.ages <- n.ages(tmp)
  tmp$root.edge <- origin - max(node.ages)

  tree.sa <<- tmp

  x = data.frame(tmp$tip.label)
  names(x) = c("taxon")
  x$min = node.ages[1:length(tmp$tip.label)]
  x$min[!(x$taxon %in% fossil.tips)] = 0
  x$max = x$min

  foss.sa <<- x

  #print(tmp$tip.label,quote=TRUE)
  tips.fbd <- tmp$tip.label
  tips.split <- strsplit(tmp$tip.label,'_')
  if(length(tips.split[[1]]) == 2)
  {
    b <- data.frame( sapply(tips.split,function(x){x[1]}))
    b$sample <- sapply(tips.split,function(x){strtoi(x[2])})
    names(b) = c("taxon","sample")
    #print(b,quote=TRUE)
    b <- aggregate(. ~ taxon,b,FUN=max)
    b$sample <- gsub(" ","",b$sample) 
    #print(b,quote=TRUE)

    tips.fbd <- apply(b,1,function(x){paste(x,sep="",collapse="_")})
    #print(tips.fbd,quote=TRUE)

    tmp <- ape::drop.tip(tmp, tmp$tip.label[!(tmp$tip.label %in% tips.fbd)])
    #print(tmp$tip.label,quote=TRUE)
    #tmp$tip.label <- sapply(strsplit(tmp$tip.label,'_'),function(x){x[1]})
    node.ages <- n.ages(tmp)
    tmp$root.edge <- origin - max(node.ages)
  }

  tree.fbd <<- tmp
  #print(tmp$tip.label,quote=TRUE)

  x$taxon <- sapply(tips.split,function(x){x[1]})
  b <- aggregate(. ~ taxon,x,FUN=min)
  b$max <- aggregate(. ~ taxon,x,FUN=max)$max
  b$taxon <- tips.fbd
  #print(b)
  foss.fbd <<- b

  0
}

test = NULL

while(is.null(test))
{
  # simulate bd tree
  test = withTimeout( sim(), timeout=10, onTimeout="silent")
}

write(paste(ntaxa,collapse="\t"),file="params.fbd")
write(paste(sigma,collapse="\t"),file="params.fbd",append=TRUE)
write(paste(lambda,collapse="\t"),file="params.fbd",append=TRUE)
write(paste(mu,collapse="\t"),file="params.fbd",append=TRUE)
write(paste(psi,collapse="\t"),file="params.fbd",append=TRUE)
write.table(foss.sa, "taxa.sa.tsv", col.names = TRUE, row.names=FALSE, quote=FALSE, sep="\t")
write.table(foss.fbd, "taxa.fbd.tsv", col.names = TRUE, row.names=FALSE, quote=FALSE, sep="\t")
#write.tree(tree.bd, file = "tree.bd.tre")
#write.tree(tree.complete, file = "tree.complete.tre")
#write.tree(tree.sa, file = "tree.sa.tre")
#write.tree(tree.fbd, file = "tree.fbd.tre")
