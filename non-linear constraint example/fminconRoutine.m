% Placeholder values for variables to change
x0 = [-1,1,3];

% Put options here

% Call to fmincon 
[x,fval] = fmincon(@objfun,x0,[],[],[],[],[],[],@confuneq,options);