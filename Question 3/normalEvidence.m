function evidence = normalEvidence(x, mu, sigma)

evidence = 10/log(10)*((-0.5*((x - mu)/(sigma)).^2) - log(sigma*sqrt(2*pi)));