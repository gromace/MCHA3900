function out = S(in)

% Skew matrix S(u)
out = [0, -in(3), in(2);
       in(3), 0, -in(1);
       -in(2), in(1), 0];