% Variance of the intercept, and how it is affected by covarying
% (non-centered) variables

%% A simple design matrix
X = ones(10, 1)

% The variance of beta = sigma^2 * inv(X'*X)
% So smaller inv(X'*X) is better.
inv(X'*X)

%% Now create an orthogonal 2nd regressor, using effects coding [1 -1]

X = ones(10, 1); X(:, 2) = [-ones(5, 1); ones(5, 1)];

X'*X
% They are orthogonal because the cross-product is 0

inv(X'*X)

% The variance of the intercept is unchanged, because the regressor is
% mean-zero

%% Now create a 2nd regressor that is not orthogonal to intercept, because it is not mean-zero

X = ones(10, 1); X(:, 2) = [zeros(5, 1); ones(5, 1)];

X'*X

inv(X'*X)

% Now the variance of the intercept regressor is twice what it was
% originally, for the same number of data points (10). 
% This is independent of what ever the noise level sigma is, and is a
% multiplier of sigma, so we don't actually need any data to know how bad
% the variance inflation is.

% This is what inv(X'*X) would have been if the columns were orthogonal

1 ./ sum(X .* X)

% So this is related to the variance inflation, 
% the ratio of the variance multiplier for X / what it would have been for
% orthogonal predictors
% The diagonals are the vifs for each predictor

vifs = diag(inv(X'*X) .* sum(X .* X))


%% Now try it with a more complex design matrix with 4 predictors

X = ones(10, 1); 
X(:, 2) = [zeros(5, 1); ones(5, 1)];

X(:, 3) = [1:10]';
X(:, 4) = [-5:4]'.^2;

vifs = diag(inv(X'*X) .* sum(X .* X))

% This is not the same as the variance inflation factors...
getvif(X)

% But it is the same as the variance inflation factors
% If the regressors are centered.
% This is related to the fact that the variance of regressors is unaffected
% by centering, but the variance of the intercept IS affected.
% It reflects the variance of the mean response when all predictors are
% zero, and thus depends on the centering and scaling of the predictors,
% which affect its basis of support.

X(:, 2:4) = scale(X(:, 2:4), 1);

vifs = diag(inv(X'*X) .* sum(X .* X))
getvif(X)

%% Now try a simulation

[b_ionly, b_regs, b_centregs] = deal(zeros(1000, 1));

for i = 1:1000
    
    y = rand(10, 1); % outcome
    
    X = ones(10, 1); % intercept only
    
    b_ionly(i, 1) = pinv(X) * y;
    
    X(:, 2:4) = rand(10, 3); % add regressors
    
    bb =  pinv(X) * y;
    
    b_regs(i, 1) = bb(1);
    
    X(:, 2:4) = scale(X(:, 2:4), 1); % centered regressors
    
    bb =  pinv(X) * y;
    
    b_centregs(i, 1) = bb(1);

end

b = [b_ionly b_regs b_centregs];

figure;
lines = hist(b, 50);

% 3rd line is exactly same as first, so add a bit to viz
lines(:, 3) = lines(:, 3) + 2;

plot(lines, 'LineWidth', 3)
legend({'Int only' 'Int+Regs' 'Int+Centered Regs'});

% Take-home: With non-centered regressors, the variance of the beta 
% for the intercept is MUCH greater!

