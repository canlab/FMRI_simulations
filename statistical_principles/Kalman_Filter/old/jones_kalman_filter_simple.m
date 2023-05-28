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

% estimate mean m_hat, conditional on model parameters
% -------------------------------------------------------------------------

% the 'oracle' Kalman filter knows the true parameter values sh and se
sh_hat = sh;  % estimated true drift variance
se_hat = se;  % estimated observation noise variance

m_hat = zeros(n+1,1);                    % fitted (estimated) sequence of true means; zero for first trial
s_hat = zeros(n+1,1);                    % fitted (estimated) sequence of true variances; sh for first trial
s_hat(1) = sh_hat;

for i = 1:n
    
    m_hat(i+1) = (m_hat(i) * se_hat + obs_values(i) * s_hat(i)) / (se_hat + s_hat(i));  % precision-weighted mean
    s_hat(i+1) = se_hat * s_hat(i) / (se_hat + s_hat(i)) + sh_hat;
    
end

% plot
figure(4), clf, subplot(1, 2, 1); set(gca, 'FontSize', 16); hold on
plot(m_true,'k', 'LineWidth', 2)
plot(obs_values,'bo:', 'LineWidth', .5, 'MarkerFaceColor', [.5 .5 1])
plot(m_hat,'b', 'LineWidth', 2)

legend({'True latent mean' 'Observed' 'Estimated mean'});
b = fill([1:n+1,n+1:-1:1], [m_hat-sqrt(s_hat);flipud(m_hat+sqrt(s_hat))],[.8 .8 1], 'linestyle','none');
alpha(b,.5)
axis tight

title('Oracle Kalman filter')

%% Now estimate parameters

% If we do not know the true variance parameters sh and se, we need to
% estimate them: 
ssq = @(x) sum(x .^ 2); %  sums of squares

% Objective function to minimize: Diff between observed and smoothed fits
err_fun = @(se_hat_sh_hat) ssq(obs_values -  est_kalman_simple(obs_values, se_hat_sh_hat(1), se_hat_sh_hat(2)));

b_start = std(obs_values) * [.7 .3]; % Naive guess at parameters

b_hat = fminsearch(err_fun, b_start); % find the best parameters, b_hat
                                    % this may not be a parameterization
                                    % that returns very efficient
                                    % (high-power for inference) estimates, though!

% generate fits
% This function returns fits given parameter estimates - the "forward model"
[m_hat, s_hat] = est_kalman_simple(obs_values, b_hat(1), b_hat(2));

% Print true and estimated parameters
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


