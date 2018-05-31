% Main Script for determining measurement likelihood 
%
%
%
clear all
%% Load Data
% Vector Test Data
load('Initial_image_pose.mat') %Use for POSE? 
%POSE=[N E D; theta phi psi; dtheta dphi dpsi];

load('calibration_sample_vector_points.mat')


p.vec1 = rHCc_norm(:,2);
p.vec2 = rHCc_norm(:,2);


% Lookup idle and part-load exhaust cam maps [deg BTDC] for each time step
p.mu_cex_is = mean2(p.vec1);
p.mu_cex_pl = mean2(p.vec2);
p.min=-15;
p.max=15;

%% Tuning parameters

% Standard deviation of measurement likelihood

sigma_cex_is = 0.5;  % stdev of exhaust cam phase uncertainty
sigma_cex_pl=0.2;


% Uncomment one model type below
%modelType = 'binary';
modelType = 'ternary';
% modelType = 'quaternary';

% Prior hypothesis probabilities (common prior for each time step)
switch modelType
    case 'ternary'          
        P_is	= 0.4;
        P_pl	= 0.3;
        P_null	= 0.3; 
    otherwise
        error('Invalid mode');
end
assert(P_is + P_pl + + P_null == 1, 'Prior probabilities must sum to 1');

% Pack parameters
theta = [sigma_cex_is;sigma_cex_pl;P_is;P_pl;P_null];

%% Automatic parameter tuning

% Find optimal parameters
theta = TuningLikelihood_3(theta, modelType, p);

%% Plot
% % Unpack results
% 
% sigma_cex_is = theta(1);
% sigma_cex_pl = theta(2);
% P_is         = theta(3);
% P_pl         = theta(4);
% P_null       = theta(5);
% 
% %% Run engine mode estimator and retrieve output struct
% 
% [~, o] = Likelihood_3(theta, p);
% 
% %% Plot all the things
% 
% % Plot recorded data 95% confidence region of measurement likelihood functions
% 
% mu_m_cex_is = p.mu_cex_is - 2*sigma_cex_is;
% mu_p_cex_is = p.mu_cex_is + 2*sigma_cex_is;
% mu_m_cex_pl = p.mu_cex_pl - 2*sigma_cex_pl;
% mu_p_cex_pl = p.mu_cex_pl + 2*sigma_cex_pl;
% 
% p.time=linspace(1,3,3)';
% 
% fig = 2;
% hf = figure(fig);clf(fig);
% hf.Color = 'w';
% ax1 = subplot(4,1,[1 2],'Parent',hf,'FontSize',12);
% hold(ax1,'on')
% 
% 
% h_p_cex_is=plot(ax1,p.time,mu_p_cex_is,'LineStyle',':','Color','k');
% h_m_cex_is=plot(ax1,p.time,mu_m_cex_is,'LineStyle',':','Color','k');
% h_p_cex_pl=plot(ax1,p.time,mu_p_cex_pl,'LineStyle','--','Color','k');
% h_m_cex_pl=plot(ax1,p.time,mu_m_cex_pl,'LineStyle','--','Color','k');
% hold(ax1,'off')
% title(ax1,'Measured and predicted data')
% ylabel(ax1,'Phase [\circ BTDC]')
% grid(ax1,'on')
% 
% % Plot evidence
% ax2 = subplot(4,1,3,'Parent',hf,'FontSize',12);
% plot(ax2,p.time,o.e_dB_is_D,p.time,o.e_dB_pl_D,p.time,o.e_dB_null_D,p.time,o.lik_dB);
% legend(ax2,'e(H_{is}|D)','e(H_{pl}|D)','e(H_{null}|D)','marginal likelihood [dB]', ...
%     'location','NorthEast')
% title(ax2,'Evidence')
% ylim(ax2,[-100 100])
% ylabel(ax2,'Evidence [dB]')
% grid(ax2,'on')
% 
% % Plot maximum a posteriori (MAP) engine mode
% [~,idx_H] = max([o.e_dB_is_D,o.e_dB_pl_D,o.e_dB_null_D],[],2);
% ax3 = subplot(4,1,4,'Parent',hf,'FontSize',12);
% stairs(ax3,p.time,idx_H)
% yticks(ax3,[1 2 3 4])
% yticklabels(ax3,{'H_{is}','H_{pl}','H_{pu}','H_{null}'})
% ylim(ax3,[0.5 4.5])
% xlabel(ax3,'Time [s]')
% title(ax3,'Maximum a posteriori hypothesis, arg max_i e(H_i|D)')
% 
% set(findall(fig,'-property','FontSize'),'FontSize',12)
% 
% % Share common time axis zoom
% linkprop([ax1,ax2,ax3],{'XLim'});