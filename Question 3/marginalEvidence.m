%
% Helper function to compute 10*log10(sum(10.^(lik_dB/10) .* P, 2)) using
% the log-sum-exp trick.
% See also https://en.wikipedia.org/wiki/LogSumExp
%

function evidence = marginalEvidence(lik_dB, P)

% Crap method:
%evidence = 10*log10(sum(10.^(lik_dB/10) .* P, 2));


index = P> 0;
lik_dB(:,index);
P(index);
exponents=lik_dB/10 + log10(P);
max_exp=max((exponents),[],2);


evidence = 10.*(max_exp + log10(sum((10.^(exponents-max_exp)),2)));