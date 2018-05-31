function [surprisal, o] = Likelihood_3(x, p)

% Standard deviation of measurement likelihood

sigma_cex_is = x(1);
sigma_cex_pl = x(2);


% Prior hypothesis probabilities (common prior for each time step)
P_is         = x(3);
P_pl         = x(4);
P_null       = x(5);

%% Evaluate data likelihood functions

% Data likelihoods [dB]
lik_dB_cex_is   = normalEvidence(p.vec1, p.mu_cex_is, sigma_cex_is);
lik_dB_cex_pl   = normalEvidence(p.vec2, p.mu_cex_pl, sigma_cex_pl);
lik_dB_cex_null = uniformEvidence(p.vec1, p.min, p.max);


%% Evaluate posterior evidence for each hypothesis

% Data likelihoods [dB] assuming each hypothesis is true, i.e., 10*log10(p(D|H))
o.lik_dB_is   =  lik_dB_cex_is ;
o.lik_dB_pl   =  lik_dB_cex_pl ; 
o.lik_dB_null = lik_dB_cex_null ;

lik_dB_all    = [o.lik_dB_is, o.lik_dB_pl, o.lik_dB_null];
P_all         = [P_is, P_pl, P_null];

if nargout >= 2
    % Data likelihoods [dB] assuming each hypothesis is false, i.e., 10*log10(p(D|notH))
    o.lik_dB_not_is   = marginalEvidence([o.lik_dB_pl,o.lik_dB_null],[P_pl,P_null]) - 10*log10(sum([P_pl, P_null]));
    o.lik_dB_not_pl   = marginalEvidence([o.lik_dB_is,o.lik_dB_null],[P_is, P_null])- 10*log10(sum([P_is, P_null]));
    o.lik_dB_not_null = marginalEvidence([o.lik_dB_is,o.lik_dB_pl],[P_is, P_pl])- 10*log10(sum([P_is, P_pl]));
    
    % Evaluate prior evidence [dB]
    o.e_dB_is         = 10*log10(P_is/(P_pl + P_null));
    o.e_dB_pl         = 10*log10(P_pl/(P_is  + P_null));
    o.e_dB_null       = 10*log10(P_null/(P_is + P_pl ));
    
    % Evaluate posterior evidence [dB]
    o.e_dB_is_D       = o.e_dB_is   + o.lik_dB_is   - o.lik_dB_not_is;
    o.e_dB_pl_D       = o.e_dB_pl   + o.lik_dB_pl   - o.lik_dB_not_pl;
    o.e_dB_null_D	  = o.e_dB_null + o.lik_dB_null - o.lik_dB_not_null;
end

% Marginal likelihood [dB]
o.lik_dB = marginalEvidence(lik_dB_all, P_all);
surprisal=-sum(o.lik_dB);
% Total surprisal 

if ~isfinite(surprisal) || ~isreal(surprisal)
    error('SOME FRIES MOTHERF****R: A surprising error was encountered while computing the surprisal.')
end
