suppressWarnings(suppressMessages(library(extraDistr)))

# number of time intervals
n <- 100

times <- seq(from=0,to=(n-1)*10, length.out=n)

mu <- rexp(n,10)
lambda <- mu + rexp(n,25)
psi <- rep(exp(runif(1,log(0.003),log(0.3))),n)
frac <- rep(1,n)

ntaxa <- 100
