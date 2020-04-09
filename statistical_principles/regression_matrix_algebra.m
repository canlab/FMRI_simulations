% test

%% Simulate a standard multiple regression model and solve several ways
% ----------------------------------------------------------------------

y = randn(100, 1);
X = randn(100, 5);
X(:, end+1) = 1;

% Standard regression equation with matrix inverse
b1 = inv(X'*X) * X' * y;

% Pseudoinverse
b2 = pinv(X) * y;

% Matrix left division formulation
b3 = X'*X \ X' * y;

% Matrix right division formulation

b4 = ((X' * y)' / (X' * X))';

b5 = X\y;

disp('These are all identical when the matrix X''*X is full-rank (well conditioned)')
disp('And regressors are therefore independent, model is identified')
[b1 b2 b3 b4 b5]


% help slash
%  Matrix division.
%   \   Backslash or left division.
%       A\B is the matrix division of A into B, which is roughly the
%       same as INV(A)*B , except it is computed in a different way.
%       If A is an N-by-N matrix and B is a column vector with N
%       components, or a matrix with several such columns, then
%       X = A\B is the solution to the equation A*X = B. A warning
%       message is printed if A is badly scaled or nearly 
%       singular.  A\EYE(SIZE(A)) produces the inverse of A.
%  
%       If A is an M-by-N matrix with M < or > N and B is a column
%       vector with M components, or a matrix with several such columns,
%       then X = A\B is the solution in the least squares sense to the
%       under- or overdetermined system of equations A*X = B. The
%       effective rank, K, of A is determined from the QR decomposition
%       with pivoting. A solution X is computed which has at most K
%       nonzero components per column. If K < N this will usually not
%       be the same solution as PINV(A)*B.  A\EYE(SIZE(A)) produces a
%       generalized inverse of A.

%   /   Slash or right division.
%       B/A is the matrix division of A into B, which is roughly the
%       same as B*INV(A) , except it is computed in a different way.
%       More precisely, B/A = (A'\B')'. See \.
 
% There may be a typo here (Matlab 2018)?
%  B/A is the matrix division of A into B is the same as A\B?
% A\B should be division

% See:
% https://tutorial45.com/matrix-division-matlab/

% For AX = B
% left-multiply both sides by inv(A)
% inv(A)*X = inv(A)*B
% X = inv(A)*B
% X = A\B

%% For PLS
% Notation as in Wold 2001
% Y is matrix of outcomes, T is latent scores on X
%
% For PLS, we want
% YV = T
% where Y is obs x voxels region Y, V is Y-weights, T is obs x k components X-scores
% that is: Y-voxels * Y-pattern weights (V) yields latent scores related to X (T)
% so the solution is:
% V = Y\T
%
% From PLS equations, by analogy with W (X-weights), v could be:
% v = Y't / t't
% or
% V = Y'T / T'T
% so, is this equivalent to Y\T above? :
% B/A = (A'\B')'
% % write Y\T as forward (right) division:
% V = (T' / Y')'
% This is not the same as  V = Y'T / T'T
%
% What is  V = Y'T / T'T doing?
% Regressing Y on X gives betas b = X'*X \ X' * y;
% So this is A\B, with A = X'*X and B = X'*y
%
% Write V = Y'T / T'T as a \ (left-divide) equation:
% B/A = (A'\B')'
% so:
%  Y'T / T'T = ( (T'T)' \ (Y'T)' )'
%
% This is of the form A = X'*X and B = X'*y
% b4 = ((X' * y)' / (X'*X))';
% V is a series of weights or betas...
% So it is a regression...
% ...but predictors (X) are T! 
%
% Would be like:
% ( (X'*X)' \ (Y'*X)' )'
%
% So V = Y'T / T'T is using T as a set of predictors (?)
% It is num Y-cols x num T-cols
% 

% T'T is symmetric, so:
%  Y'T / T'T = ( (T'T) \ (Y'T)' )'

% B = Y't
% A = t't
% B/A = (t't)' \ (Y't)')'
% t't is symmetric, so:
% B/A = (t't \ (Y't)')'
% B/A = (t't \ (t'Y))'
% B/A = (t'Y)' \ t't)

T = rand(100, 2);
Y = rand(100, 30);
V = Y\T;             % 30 x 2 matrix with 2 pattern weights across Y voxels

% write as forward (right) division:
V2 = (T' / Y')';

% these are the same:
[V V2]

% Now try the version inspired by W in PLS:
% But this uses T as predictors of Y...not the other way around
V3 = Y'*T / (T'*T);

V4 = ( (T'*T)' \ (Y'*T)' )';

% these are the same:
[V3 V4]

% They are all the same size, Y-voxels x T-components.

% Does Y*V = T ?
tmp = [Y * V T];
figure; plot(tmp(:, 1), tmp(:, 3), 'ko');
figure; plot(tmp(:, 2), tmp(:, 4), 'ko');

tmp = [Y * V3 T];
figure; plot(tmp(:, 1), tmp(:, 3), 'ko');
figure; plot(tmp(:, 2), tmp(:, 4), 'ko');

% V is a series of weights or betas...
V5 = (T' * Y / (Y'*Y))';

% Re-do and check for differences
V = Y\T;             % 30 x 2 matrix with 2 pattern weights across Y voxels
V5 = (T' * Y / (Y'*Y))';
any(abs(V - V5) > 0.00000001)

% in sum...PLS patterns for Y
% --------------------------------------------------------------------------
T = rand(100, 2);
Y = rand(100, 30);

% V is a series of weights or betas, mapping Y voxels onto latent
% components of X (T) -- which, through PLS, have been optimized to covary with
% latent components of Y (U). Each column of V is a pattern across Y voxels
% such that YV is as close to T as possible using the columns of Y. 
% The first column of V is a pattern map projecting onto the first column
% of T (component 1), the second col. of V maps to the second col. of V
% (component 2), etc. 
% 
% The solution to YV = T + E (E = error)
% a 30 x 2 matrix with 2 pattern weights across Y voxels
% The same as regressing T (outcomes) on Y (predictors)
V = Y\T;         % This formulation is preferred - most stable
% The same as regression betas mapping Y (predictors) to T (outcomes):
V_rep = ( T' * Y / (Y' * Y) )';
any(abs(V - V_rep) > 0.00000001)
% Show again using another, more familiar form for regression:
V_rep2 = inv(Y'*Y)*Y'*T;
any(abs(V - V_rep2) > 0.00000001)

% This will be stable only if there are more observations than Y voxels!
% If not, we need to use kernel-form regression, or pinv() to stabilize the
% regression. So pinv offers a more general solution.
V_rep3 = pinv(Y) * T;
any(abs(V - V_rep3) > 0.00000001)

% So, at the end of the day, our latent patterns should be:
% W = pinv(X) * U;
% V = pinv(Y) * T;

%% Relationship with Eigenvectors:
% X = A\B is the solution to the equation A*X = B.

% Eigenvectors find w such that:
% A*v = lambda*v
% to be continued...

%% Simulate a non-identified multiple regression model and solve several ways
% ----------------------------------------------------------------------

y = randn(100, 1);
X = randn(100, 5);
X(:, 4) = .5 * X(:, 2) + .5 * X(:, 3);
X(:, end+1) = 1;

disp('Standard regression equation with matrix inverse')
b1 = inv(X'*X) * X' * y;

disp('Pseudoinverse')
b2 = pinv(X) * y;

disp('Matrix division formulation')
b3 = X'*X \ X' * y;

b4 = X\y;

disp('When regressors 2, 3, and 4 are linearly dependent, all models')
disp('give different parameter estimates for these 3 non-identified parameters')
disp('But the same estimates for parameters that are identified.')
[b1 b2 b3 b4]

disp('Only the pseudoinverse gives a stable solution')

%% Simulate a well-conditioned multivariate X, multivariate Y case
% ----------------------------------------------------------------------

Y = randn(100, 2);
X = randn(100, 5);
X(:, end+1) = 1;

% Standard regression equation with matrix inverse
b1 = inv(X'*X) * X' * Y;

% Pseudoinverse
b2 = pinv(X) * Y;

% Matrix division formulation
b3 = X'*X \ X' * Y;

b1_1 = inv(X'*X) * X' * Y(:, 1);

disp('Param estimates all identical when the matrix X''*X is full-rank (well conditioned)')
disp('Here, each model has 2 columns of parameter estimates:')
[b1 b2 b3]

disp('And identical when estimating columns of Y separately or in the same model')
[b1(:, 1) b1_1]

disp('Regression projects each column of Y onto the model space spanned by the columns of X')

%% Calculation Speed

Y = randn(100, 2);
X = randn(100, 5);
X(:, end+1) = 1;

disp('Standard regression equation with matrix inverse')
tic, for i = 1:10000, b1 = inv(X'*X) * X' * Y; end, toc

disp('Pseudoinverse')
tic, for i = 1:10000, b2 = pinv(X) * Y; end, toc

disp('Matrix division formulation')
tic, for i = 1:10000, b3 = X'*X \ X' * Y; end, toc

disp('Speed may vary with size of matrices.')

%% Matrix rotation interpretation

% There is a matrix rotation interpretation as well.
% R*v is a rotation where the vector v is rotated (and dilated, sheared)
% by the matrix R.

% y-hat = X*b = Hat matrix (H) * y
% So the hat matrix H defines the rotation of y
% H is idempotent (length 1) so it rotates.

y = randn(100, 1);
X = randn(100, 5);
X(:, end+1) = 1;

H =  X * (X'*X \ X');

% H is the hat matrix because it produces the fitted values (y-hats).
% H is also called the influence matrix.

norm(H)


%% Kernel-form regression and pseudoinverse


