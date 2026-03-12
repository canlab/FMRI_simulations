%% Example design with 4 conditions
n_per_cond = 10;
ncond = 4;
n = n_per_cond * ncond;

% condition labels
cond = repelem(1:ncond, n_per_cond)';

%% ---------------------------------------------------
% 1. One-hot dummy coding + intercept
%% ---------------------------------------------------

D = zeros(n,ncond);

for k = 1:ncond
    D(:,k) = (cond == k);
end

intercept_vec = ones(n,1);

X_dummy = [intercept_vec D];

disp('Dummy-coded design:')
disp(X_dummy(1:8,:))

% Note: intercept = sum of dummy columns -> rank deficiency


%% ---------------------------------------------------
% 2. Mean-centered regressors (orthogonal to intercept)
%% ---------------------------------------------------

D_centered = D - mean(D);

X_centered = [intercept_vec D_centered];

disp('Check orthogonality to intercept:')
disp(intercept_vec' * D_centered)   % should be ~0

disp('Check column sums:')
disp(sum(D_centered))           % should be zero


%% ---------------------------------------------------
% 3. Effects coding (sum-to-zero contrasts)
%% ---------------------------------------------------

% Use K-1 regressors
C = zeros(n,ncond-1);

for k = 1:(ncond-1)
    C(:,k) = (cond==k) - (cond==ncond);
end

X_effect = [intercept_vec C];

disp('Effects-coded design:')
disp(X_effect(1:8,:))

disp('Check column sums:')
disp(sum(C))     % should be zero