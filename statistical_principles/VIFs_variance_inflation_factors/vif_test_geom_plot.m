%% -------------------------------------------
% Example with 4 conditions
%% -------------------------------------------

n_per_cond = 20;
ncond = 4;
n = n_per_cond * ncond;

cond = repelem(1:ncond,n_per_cond)';

% one-hot indicators
D = zeros(n,ncond);
for k=1:ncond
    D(:,k) = (cond==k);
end

intercept = ones(n,1);

%% 1. Dummy coding (rank deficient)

X_dummy = [intercept D];

%% 2. Mean-centered dummies

Dc = D - mean(D);
X_centered = [intercept Dc];

%% 3. Effect coding (full rank)

C = zeros(n,ncond-1);

for k=1:ncond-1
    C(:,k) = (cond==k) - (cond==ncond);
end

X_effect = [intercept C];

%% -------------------------------------------
% Compare column spaces via SVD
%% -------------------------------------------

[Ud,~,~] = svd(X_dummy,'econ');
[Uc,~,~] = svd(X_centered,'econ');
[Ue,~,~] = svd(X_effect,'econ');

% take first two basis vectors for visualization
B_dummy = Ud(:,1:2);
B_centered = Uc(:,1:2);
B_effect = Ue(:,1:2);

figure
subplot(1,3,1)
plot(B_dummy(:,1),B_dummy(:,2),'.')
title('Dummy coding')

subplot(1,3,2)
plot(B_centered(:,1),B_centered(:,2),'.')
title('Mean-centered dummies')

subplot(1,3,3)
plot(B_effect(:,1),B_effect(:,2),'.')
title('Effect coding')