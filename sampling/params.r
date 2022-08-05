suppressWarnings(suppressMessages(library(extraDistr)))

# number of time intervals
n <- 10

times <- seq(from=0,to=90, length.out=n)

lambda <- rhcauchy(n,0.1)+0.01
mu <- rhcauchy(n,0.1)
psi <- rep(exp(runif(1,log(0.04),log(0.3))),n)
frac <- rep(1,n)

ntaxa <- 100
