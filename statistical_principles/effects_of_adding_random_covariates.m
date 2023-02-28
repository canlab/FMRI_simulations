% Adding random covariates that are not meaningful may decrease power.
% It reduces the DF, but also can affect efficiency as the number of
% covariates grows relative to the number of observations in ways not strictly accounted for by DF.

% Including orthogonal covariates will not affect the regression slopes,
% but will affect the error variance.

n = 100;        % n observations
sigma = 5;      % noise sigma
k = 0;         % num of random nuisance covariates
niter = 1000;

rng('shuffle')

% Create experimental effects of interest

x1 = [zeros(n/2, 1); ones(n/2, 1)];
x2 = [zeros(n/4, 1); ones(n/4, 1); zeros(n/4, 1); ones(n/4, 1)]; % orthogonal effect, with true b = 0, for false positives

% Iterate - random noise
[t_vals, p_vals, sig_vals, sig_falsepos_vals, b_vals, intercept_vals] = deal(zeros(niter, 1));

for i = 1:niter

    % true signal - with noise
    y = sigma .* randn(n, 1) + (1 * x1) + (0 * x2) + 10; % 10 = intercept (arbitrary value)

    K = randn(n, k);  % random covariates

    [b, dev, stat] = glmfit([x1 x2 K], y);  % intercept added first

    is_sig = stat.p(2) < 0.05; % effect of interest

    t_vals(i) = stat.t(2);
    p_vals(i) = stat.p(2);
    sig_vals(i) = is_sig;
    b_vals(i) = b(2);
    intercept_vals(i) = b(1);

    sig_falsepos_vals(i) = stat.p(3) < 0.05;

end

% Summarize
pow_sim = sum(sig_vals) ./ niter
fpr_sim = sum(sig_falsepos_vals) ./ niter
t_sim = mean(t_vals);
ste_b_sim = std(b_vals)  % standard error of beta across iterations
ste_i_sim = std(intercept_vals) % standard error of intercept

create_figure('summary', 1, 3);
hist(t_vals, 100)
title('T values');

subplot(1, 3, 2);
hist(p_vals, 100);
title('p values');

subplot(1, 3, 3);
hist(b_vals, 100);
title('beta-hat values');

%% Now explore effects of number of random covariates
% Put the whole sim, with iterations, in a sub-function

n_vals = 4*[13:3:82];             % must be divisible by 4 here in this sim
k_vals = [0 1 2 5 10 15 20 30 40 50];
niter = 1000;

[pow, fpr, t, ste_b, ste_i] = deal(zeros(length(n_vals), length(k_vals)));

for n = 1:length(n_vals)

    for k = 1:length(k_vals)

        [pow(n, k), fpr(n, k), t(n, k), ste_b(n, k), ste_i(n, k)] = sim_power_fpr(n_vals(n), k_vals(k), sigma, niter);

        fprintf('.')
    end
    fprintf('|')
end
fprintf('Done!\n')

%%
k_names = cellstr(num2str(k_vals'))';

colors = seaborn_colors(length(k_vals));

create_figure('Power_FPR', 1, 2)
h = plot(n_vals, pow);
for i = 1:length(h), set(h(i), 'Color', colors{i}, 'LineWidth', 2); end
legend(k_names, 'Location', 'southeast')
xlabel('Sample size')
ylabel('Power')
title('Power | n and num nuisance covariates (k)')


subplot(1, 2, 2);
h = plot(n_vals, fpr);
for i = 1:length(h), set(h(i), 'Color', colors{i}, 'LineWidth', 2); end
legend(k_names)
xlabel('Sample size')
ylabel('False pos rate (FPR)')
title('FPR | n and num nuisance covariates (k)')
set(gca, 'YLim', [0 0.2]);
plot_horizontal_line(0.05);

%%

create_figure('power_fpr2', 1, 2);
barplot_columns(pow, 'noviolins', 'dolines', 'names', k_names, 'colors', seaborn_colors(length(k_vals)), 'nofigure');
xlabel('Num nuisance covariates')
ylabel('Power')
title('Power | num nuisance covariates (k)')

subplot(1, 2, 2)
barplot_columns(fpr, 'noviolins', 'dolines', 'names', k_names, 'colors', seaborn_colors(length(k_vals)), 'nofigure');
xlabel('Num nuisance covariates')
ylabel('Power')
title('Power | num nuisance covariates (k)')
set(gca, 'YLim', [0 0.2]);
plot_horizontal_line(0.05);

%%
create_figure('Standard errors', 1, 2)
h = plot(n_vals, ste_b);
for i = 1:length(h), set(h(i), 'Color', colors{i}, 'LineWidth', 2); end
legend(k_names, 'Location', 'northeast')
xlabel('Sample size')
ylabel('ste(b)')
title('ste of beta | n and num nuisance covariates (k)')

k_names = cellstr(num2str(k_vals'))';

subplot(1, 2, 2);
h = plot(n_vals, ste_i);
for i = 1:length(h), set(h(i), 'Color', colors{i}, 'LineWidth', 2); end
legend(k_names)
xlabel('Sample size')
ylabel('ste(intercept)')
title('ste of intercept | n and num nuisance covariates (k)')


%%

function [pow, fpr, t, ste_b, ste_i] = sim_power_fpr(n, k, sigma, niter)

% Create experimental effects of interest

x1 = [zeros(n/2, 1); ones(n/2, 1)];
x2 = [zeros(n/4, 1); ones(n/4, 1); zeros(n/4, 1); ones(n/4, 1)]; % orthogonal effect, with true b = 0, for false positives

% Iterate - random noise
[t_vals, p_vals, sig_vals, sig_falsepos_vals, b_vals, intercept_vals] = deal(zeros(niter, 1));

rng('shuffle')

for i = 1:niter

    % true signal - with noise
    y = sigma .* randn(n, 1) + (1 * x1) + (0 * x2) + 10; % 10 = intercept (arbitrary value)

    K = randn(n, k);  % random covariates

    [b, dev, stat] = glmfit([x1 x2 K], y);  % intercept added first

    is_sig = stat.p(2) < 0.05; % effect of interest

    t_vals(i) = stat.t(2);
    p_vals(i) = stat.p(2);
    sig_vals(i) = is_sig;
    b_vals(i) = b(2);
    intercept_vals(i) = b(1);

    sig_falsepos_vals(i) = stat.p(3) < 0.05;

end

% Summarize
pow = sum(sig_vals) ./ niter;
fpr = sum(sig_falsepos_vals) ./ niter;
t = mean(t_vals);
ste_b = std(b_vals);  % standard error of beta across iterations
ste_i = std(intercept_vals); % standard error of intercept

end % subfunction


