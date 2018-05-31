function evidence = normalPlusUniformEvidence(x, mu, sigma, a, b)

% Naive method:
%evidence = 10*log10(normcdf(b, x - mu, sigma) - normcdf(a, x - mu, sigma)) - 10*log10(b - a);

% This is equivalent to the following:

x1 = (a + mu - x)./sigma;
x2 = (b + mu - x)./sigma;
z1 = -x1/sqrt(2);
z2 = -x2/sqrt(2);

assert(all(z1 > z2), 'Expecting integral bounds to have positive difference');
if ((b-a) < sigma)
    evidence = 10*( log10(erfc(z2) - erfc(z1)) - log10(2) - log10(b - a) );%22
elseif (sigma < (b-a))
    evidence = 10*( log10(erfc(-z1)-erfc(-z2)) - log10(2) - log10(b - a) );%22
elseif (((b-a) <= (sigma)) && ((b-a) >= (sigma)) )
    evidence = -0.5*b^2 + 10*( log10(erfcx(z2)) - log10(2) - log10(b - a) ) ;%24
end
