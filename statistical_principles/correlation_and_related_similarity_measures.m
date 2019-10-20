
% r = cov(a, b) / (std(a)*std(b))

a = randn(20, 1); b = randn(20, 1);
cv = cov(a, b);                     % covariance


r = cv(1, 2) ./ prod(diag(cv) .^ .5)

% cov = E[(a-abar) * (b-bbar)] / (N - 1)

cv2 = (a-mean(a))' * (b-mean(b)) / (length(a) - 1); % covariance

% Compare
[cv(1, 2) cv2]

% Relationship between dot product, correlation, and cosine similarity
% ----------------------------------------------------------


%% efficient calculation if a is a vector and b is a matrix
% ----------------------------------------------------------
% some versions of matlab do this with the corr() function, but others do
% not, causing problems.

% Simulate data
a = randn(20, 1); b = randn(20, 10);

% Inefficient: loop
clear r p; 
for i = 1:10
    [r(i, 1) p(i, 1)] = corr(a, b(:, i));  % Correlation of a with each column of b
end

s1 = std(a);
s2 = std(b)';       % column vector 

act = (a-mean(a))'; % a centered, transposed
bc = b-mean(b);     % b centered, column-wise

df = length(a) - 1;      % df, N - 1

cv = (act * bc ./ df)';  % cov between a and b 

rr = cv ./ (s1*s2); % Correlation of a with each column of b

% formula - create an anonymous function. 
% a is an N x 1 vector, b is an N x k matrix
corr_matrix = @(a, b) ((a-mean(a))' * (b-mean(b)) ./ (length(a) - 1))' ./ (std(a)*std(b)'); % Correlation of a with each column of b

% This version takes and N x p matrix a and an N x v matrix b and returns
% a p x v matrix of correlations across the pairs. 
corr_matrix = @(a, b) ((a-mean(a))' * (b-mean(b)) ./ (size(a, 1) - 1)) ./ (std(b)' * std(a))'; % Correlation of a with each column of b


rr2 = corr_matrix(a, b);

% compare loop to vector to formula
[r rr rr2]

% T and P-values

r2t = @(r, n) r .* sqrt((n - 2) ./ (1 - r.^2));

t2p = @(t, n) 2 .* (1 - tcdf(abs(t), n - 2));

t = r2t(r, length(a));
pp = t2p(t, length(a));

% compare matlab to formula above
[p pp] % p-values for our new formula vs. matlab's output



