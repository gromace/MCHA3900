function evidence = uniformEvidence(x, a, b)

% Wrong method:
%evidence = -10*log10(1/b - a) * (a <= x & x <= b);
 evidence = 10*log10(1/(b - a)) + log(real((a <= x) & (x <= b)));
