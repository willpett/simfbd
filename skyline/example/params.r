suppressWarnings(suppressMessages(library(MCMCpack)))

# hyperprior for variance-covariance matrix
sigma_0 <- 0.1

# number of time intervals
n <- 10

# total time
t <- 1


sigma <- riwish(3, matrix(c(sigma_0,0,0,0,sigma_0,0,0,0,sigma_0),3,3))
m <- numeric(3)

dt <- t/n

times <- seq(0,t,dt)

lambda <- numeric(n+1)
mu <- numeric(n+1)
psi <- numeric(n+1)

x_0 <- mvrnorm(1,m,sigma)

lambda[1] <- exp(x_0[1])
mu[1] <- exp(x_0[2])
psi[1] <- exp(x_0[3])

for(i in 2:length(times))
{
	x_i <- mvrnorm(1,x_0,sigma*t/n)

	lambda[i] <- (exp(x_0[1])+exp(x_i[1]))/dt
	mu[i] <- (exp(x_0[2])+exp(x_i[2]))/dt
	psi[i] <- (exp(x_0[3])+exp(x_i[3]))/dt

	x_0 <- x_i
}

#plot(times,lambda,ylim=c(0,max(c(lambda,mu,psi))))
#points(times,mu,col="blue")
#points(times,psi,col="red")

ntaxa <- 10
