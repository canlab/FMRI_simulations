function out = intercept_vif(X)
% INTERCEPT_VIF  Compute variance inflation factor for intercept column
%
% out = intercept_vif(X)
%
% INPUT
%   X : n x p design matrix containing a constant column
%
% OUTPUT (struct)
%   out.ic                  index of intercept column
%   out.R2_regression       R^2 from auxiliary regression
%   out.R2_algebraic        R^2 from algebraic formula
%   out.VIF_regression      intercept VIF from regression
%   out.VIF_algebraic       intercept VIF from algebraic formula
%
% Notes:
%  - Uses uncentered R^2 because auxiliary regression has no intercept.
%  - Handles rank-deficient cases using pseudoinverse.

[n,p] = size(X);

%% --------------------------------------------------
% identify intercept column
%% --------------------------------------------------

ic = intercept(X,'which');

if isempty(ic)
    error('No intercept column detected in X.');
end

y = X(:,ic);
Xother = X(:,setdiff(1:p,ic));

%% --------------------------------------------------
% (1) Regression approach
%% --------------------------------------------------

% regression with no intercept
b = glmfit(Xother, y, 'normal', 'Constant', 'off');

yhat = Xother * b;

SSE = sum((y - yhat).^2);

% uncentered total SS (important)
SST0 = sum(y.^2);

if SST0 == 0
    R2_reg = NaN;
else
    R2_reg = 1 - SSE/SST0;
end

if abs(1 - R2_reg) < 1e-12
    VIF_reg = Inf;
else
    VIF_reg = 1/(1 - R2_reg);
end

%% --------------------------------------------------
% (2) Algebraic projection formula
%% --------------------------------------------------

% use pseudoinverse for robustness
XtX_inv = pinv(Xother' * Xother);

R2_alg = (y' * Xother * XtX_inv * Xother' * y) / (y' * y);

if abs(1 - R2_alg) < 1e-12
    VIF_alg = Inf;
else
    VIF_alg = 1/(1 - R2_alg);
end

%% --------------------------------------------------
% return results
%% --------------------------------------------------

out.ic = ic;

out.R2_regression = R2_reg;
out.R2_algebraic = R2_alg;

out.VIF_regression = VIF_reg;
out.VIF_algebraic = VIF_alg;

end