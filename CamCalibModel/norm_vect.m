%% Nonlincon: Constrain the 3 coordinate values to a unit vector
function [c,ceq] = norm_vect(intc)
global param

c=[];
for l=1:param.k
    ceq(12*l-2 : 12*l) = 1 - sqrt(intc(12*l-2).^2 + intc(12*l-1).^2 + intc(12*l).^2);
end

end