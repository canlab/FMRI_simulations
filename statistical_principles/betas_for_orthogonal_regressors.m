
% Including orthogonal covariates will not affect the regression slopes,
% but will affect the error variance.

x1 = [zeros(50, 1); ones(50, 1)];
x2 = [zeros(25, 1); ones(25, 1); zeros(25, 1); ones(25, 1)];

y = zeros(100, 1) + x1 + x2 + 5; % intercept

b = glmfit([x1 x2], y)

b = glmfit([x1], y)

% regressors are orthogonal; beta(x1) is the same whether fit concurrently
% with x2 or not.

%%

% Create random drift, zero-mean
rw = cumsum(randn(100, 1));
rw = smoothy(rw, 5);
rw = rw - mean(rw);

% Create block on-off design
x1 = repmat([zeros(10, 1); ones(10, 1)], 5, 1);

% Create y: sum of signal and noise, true x1 beta = 1, intercept = 5
y = zeros(100, 1) + x1 + rw + 5; % intercept

fprintf('Correlation of x1r and rw\n')
corr([rw x1])

create_figure('time series');
plot(y, 'k', 'LineWidth', 2);
plot(x1)
legend({'Observed (y)' 'X1'})

% Fit models.
% Regressors are correlated. The betas are different.

fprintf('Betas for x1 only\n')
b = glmfit([x1], y)

fprintf('Betas for x1 and rw\n')
b = glmfit([x1 rw], y)

% Create a new x1, x1r, orthogonalized with respect to rw (noise)

x1r = x1 - rw * pinv(rw) * x1;

fprintf('Correlation of x1r and rw\n')
corr([x1r rw])

% Create new y, using x1r, and re-fit

y = zeros(100, 1) + x1r + rw + 5; % intercept

plot(x1r)
legend({'Observed (y)' 'X1' 'X1-orth'})

% Regressors are uncorrelated. The betas are the same!!
fprintf('Betas for x1-orth (x1r) only\n')
b = glmfit([x1r], y)

fprintf('Betas for x1r and rw\n')
b = glmfit([x1r rw], y)
