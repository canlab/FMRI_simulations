%% Kalman filter

n = 100; %number of trials to simulate

% generative model: 'true' parameters
% -------------------------------------------------------------------------
sh = 1;  % variance of random walk step (drift in true mean)
se = 5;  % variance of observation noise

% generate data, conditional on model parameters
% -------------------------------------------------------------------------

m_true = cumsum(randn(n,1) * sqrt(sh));         % sequence of true values, random walk with var = sh, std = sqrt(sh)
obs_values = m_true + randn(n,1) * sqrt(se);    % sequence of observations; obs noise is independent across time

% Physical
% truck
% Kalman gain
% predict and update steps

% a rat presses a lever, and gets a reward of variable magnitude.
% the psychological model is that the rat thinks there is an expected reward 
% magnitude E(reward) that changes across time (according to a Gaussian random walk), 
% and the realized reward on a trial is the E(reward) plus a draw from a second Gaussian random variable  
% Further assumptions: rat is inferring ... Bayes...

% The Kalman filter can be written as a single equation; however, it is most often conceptualized as two distinct phases: "Predict" and "Update". The predict phase uses the state estimate from the previous timestep to produce an estimate of the state at the current timestep. This predicted state estimate is also known as the a priori state estimate because, although it is an estimate of the state at the current timestep, it does not include observation information from the current timestep. In the update phase, the innovation (the pre-fit residual), i.e. the difference between the current a priori prediction and the current observation information, is multiplied by the optimal Kalman gain and combined with the previous state estimate to refine the state estimate. This improved estimate based on the current observation is termed the a posteriori state estimate.

% estimate mean m_hat, conditional on model parameters
% -------------------------------------------------------------------------

% the 'oracle' Kalman filter knows the true parameter values sh and se
sh_hat = sh;  % estimated true drift variance
se_hat = se;  % estimated observation noise variance

%mj: of course when applied to a real experiment, the inputs (obs_values) will be whatever was presented to the subject, rather than something produced by the KF generating process
%    therefore the notion of "true" se and sh isn't meaningful
%    in fact, this entire cell of code wouldn't be used when fitting data; you'd start in the next cell 

m_hat = zeros(n+1,1);                    % fitted (estimated) sequence of means; zero for first trial
s_hat = zeros(n+1,1);                    % fitted (estimated) sequence of variances; sh for first trial
s_hat(1) = sh_hat;

for i = 1:n
    
    % precision-weighted mean
    m_hat(i+1) = (m_hat(i) * se_hat + obs_values(i) * s_hat(i)) / (se_hat + s_hat(i));  
    %mj: m_hat(i+1) is the mean for both the posterior on trial i and the prior on trial i+1 
    
    s_hat(i+1) = se_hat * s_hat(i) / (se_hat + s_hat(i)) + sh_hat;
    %mj: s_hat(i+1) is the variance for the prior on trial i+1
    %    the variance for the posterior on trial i would be given by the same expression except without adding sh_hat 
end

% plot
figure(4), clf, subplot(1, 2, 1); set(gca, 'FontSize', 16); hold on
plot(m_true,'k', 'LineWidth', 2)
plot(obs_values,'bo:', 'LineWidth', .5, 'MarkerFaceColor', [.5 .5 1])
plot(m_hat,'b', 'LineWidth', 2)

legend({'True latent mean' 'Observed' 'Estimated mean'});
b = fill([1:n+1,n+1:-1:1], [m_hat-sqrt(s_hat);flipud(m_hat+sqrt(s_hat))],[.8 .8 1], 'linestyle','none');
set(b, 'FaceAlpha', .5);
axis tight

title('Oracle Kalman filter')

%% Now estimate parameters

% If we do not know the true variance parameters sh and se, we need to
% estimate them: 
ssq = @(x) sum(x .^ 2); %  sums of squares

% Objective function to minimize: Diff between observed and smoothed fits
err_fun = @(se_hat_sh_hat) ssq(obs_values -  est_kalman_simple(obs_values, se_hat_sh_hat(1), se_hat_sh_hat(2)));
%mj: this isn't the right comparison
%    obs_values are the stimuli
%    what you need are a sequence of responses
%    then you want an objective function that compares the response sequence to the model's predicted responses 
%    also, est_kalman_simple doesn't directly return model predictions (see my comment in that function) 

b_start = std(obs_values) * [.7 .3]; % Naive guess at parameters

b_hat = fminsearch(err_fun, b_start); % find the best parameters, b_hat
                                    % this may not be a parameterization
                                    % that returns very efficient
                                    % (high-power for inference) estimates, though!

% generate fits
% This function returns fits given parameter estimates - the "forward model"
[m_hat, s_hat] = est_kalman_simple(obs_values, b_hat(1), b_hat(2));

% Print true and estimated parameters
%mj: no notion of true parameters (see comment above: obs_values are the actual stimuli given to the subject) 
fprintf('True:\t%3.2f %3.2f\nEst:\t%3.2f %3.2f\n', se, sh, b_hat(1), b_hat(2));

subplot(1, 2, 2); cla, set(gca, 'FontSize', 16); hold on

plot(m_true,'k', 'LineWidth', 2)
plot(obs_values,'bo:', 'LineWidth', .5, 'MarkerFaceColor', [.5 .5 1])
plot(m_hat,'b', 'LineWidth', 2)

legend({'True latent mean' 'Observed' 'Estimated mean'});
b = fill([1:n,n:-1:1], [m_hat-sqrt(s_hat);flipud(m_hat+sqrt(s_hat))],[.8 .8 1], 'linestyle','none');
alpha(b,.5)
axis tight

title('Fitted Kalman filter')

%% How does the model perform?
% Now simulate bias and variance in parameter estimates

niter = 1000;

param_est = zeros(niter, 2);

[sse, sse_loss] = deal(zeros(niter, 1));

for i = 1:niter
    
% generate data, conditional on model parameters
% -------------------------------------------------------------------------

m_true = cumsum(randn(n,1) * sqrt(sh));         % sequence of true values, random walk with var = sh, std = sqrt(sh)
obs_values = m_true + randn(n,1) * sqrt(se);    % sequence of observations; obs noise is independent across time

% fit the model, find best parameters
% -------------------------------------------------------------------------

err_fun = @(se_hat_sh_hat) ssq(obs_values -  est_kalman_simple(obs_values, se_hat_sh_hat(1), se_hat_sh_hat(2)));
b_start = var(obs_values) * [.7 .3]; % Naive guess at parameters
b_hat = fminsearch(err_fun, b_start); % find the best parameters, b_hat

param_est(i, :) = b_hat;
sse(i, 1) = err_fun(b_hat);

sse_loss(i, 1) = sse(i, 1) - err_fun([se sh]); % difference between estimated and optimal error

end

figure(3); 
barplot_columns(param_est, 'nofig');

%% Markov chain stationary distribution

T = [.6 .1 .1;.3 .8 0;.1 .1 .9]; %transition matrix
p = [.2;.3;.5]; %stationary distribution

disp('Trasition matrix (T):'),disp(T)
disp('Stationary distributions (p):'),disp(p)
disp('T*p:'),disp(T*p)

n = 10000; %number of steps to run
burn = 1000; %initial steps to discard
space = 10; %spacing of samples to save

sample = zeros((n-burn)/space,1);
m_true = randi(3); %random starting state
for i=1:n
    m_true = find(rand<cumsum(T(:,m_true)),1); %sample according to xth column of T
    if i>burn && mod(i,space)==0
        sample((i-burn)/space) = m_true; %save this sample
    end
end

p = [mean(sample==1) mean(sample==2) mean(sample==3)]; %proportion for each state
disp(['Simulated proportions: ' num2str(p)]) %display proportions
disp(['Standard errors: ' num2str(sqrt(p.*(1-p)*space/(n-burn)))]) %standard errors assuming independence


