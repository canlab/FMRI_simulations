% X : n x p design matrix containing a constant column
% ic : index of the intercept column in X

[n,p] = size(X);

ic = intercept(X, 'which');

%-------------------------------------------------------
% (1) VIF_intercept via regression using glmfit
%-------------------------------------------------------

y = X(:,ic);                        % intercept column (all ones)
Xother = X(:,setdiff(1:p,ic));      % other predictors

% [b,~,stats] = glmfit(Xother, y, 'normal', 'Constant', 'off');  
% 
% R2_reg = 1 - stats.deviance / sum((y - mean(y)).^2);
% VIF_intercept_reg = 1 / (1 - R2_reg);

[b,~,~] = glmfit(Xother, y, 'normal', 'Constant', 'off');

yhat = Xother * b;

SSE = sum((y - yhat).^2);
SST = sum((y - mean(y)).^2); 

R2_reg = 1 - SSE/SST;

VIF_intercept_reg = 1/(1 - R2_reg);

%-------------------------------------------------------
% (2) Algebraic computation using projection formula
%-------------------------------------------------------

Xc = Xother;

R2_alg = (y' * Xc * ((Xc' * Xc) \ (Xc' * y))) / (y' * y);

VIF_intercept_alg = 1 / (1 - R2_alg);

%-------------------------------------------------------
% Display results
%-------------------------------------------------------

fprintf('Intercept VIF (glmfit regression) : %.6f\n', VIF_intercept_reg);
fprintf('Intercept VIF (algebraic formula) : %.6f\n', VIF_intercept_alg);
