suppressWarnings(suppressMessages(library(extraDistr)))

# number of time intervals
n <- 10

times <- seq(from=0,to=90, length.out=n)

mu <- rexp(n,10)
lambda <- mu + rexp(n,20)
psi <- rep(exp(runif(1,log(0.01),log(0.4))),n)
frac <- rep(1,n)

ntaxa <- 100
