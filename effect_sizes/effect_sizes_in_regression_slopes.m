% Coverting unstandardized regression slopes into effect sizes
% (standardized slopes)

% y = X*b (matrix notation). 
% If we standardize, we get y = X_std*b_std = X/sd(X) * b_std. 
% So X*b = X/sd(X)*b_std. 
% We%re interested in b_std, the effect size
% Rearranging X*b = X/sd(X)*b_std, we get:
% b_std = X*b / (X / sd(X)) = b * std(X)

% create a moderately related x and y on different scales (arbitrary slope
% and intercept)
y = 2 + randn(50, 1);
x = 4 + 0.75*y + randn(50, 1);

% design matrix
X = [x ones(size(x))];

% unstandardized slope b
b = pinv(X) * y;

% design matrix standardized
Xs = [((x - mean(x)) ./ std(x))  ones(size(x))];

% standardized slope b_std = effect size
b_std = pinv(Xs) * y;

% b(1) is slope
b, b_std

% estimated b_std without standardizing
b * std(x)

%% try it with 2 predictors
y = 2 + randn(50, 1);
x = 4 + 0.75*y + randn(50, 1);
x2 = 3 + 0.5*y + randn(50, 1);

% design matrix
X = [x x2 ones(size(x))];

% unstandardized slope b
b = pinv(X) * y;

% design matrix standardized
Xs = [((x - mean(x)) ./ std(x))  ((x2 - mean(x2)) ./ std(x2)) ones(size(x))];

% standardized slope b_std = effect size
b_std = pinv(Xs) * y;

% b(1) is slope
b, b_std

% estimated b_std without standardizing
b(1:2) .* std([x x2])'