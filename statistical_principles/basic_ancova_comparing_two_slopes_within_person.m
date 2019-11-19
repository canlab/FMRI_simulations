% Testing a within-person moderator
% A common situation in neuroimaging is when you have brain-behavior
% correlations under two intervention conditions or states, where states
% are assessed within-person. 
% 
% For example, you might test whether social
% support (the state) changes the slope of the relationship between pain
% and brain activity. You also have data from a no-support control condition,
% and each person is tested in both states. How do you test this?
%
% You might be interested in several questions here, which are all somewhat
% different:
% 1. Does pain predict brain activity more strongly during social support
%    than control?
% 2. Do individual differences in pain [on vs. off support] predict brain [on vs. off support]
% 
% These are different questions. The second is more typical in
% neuroimaging, but the first is potentially often of greater interest.
%
%
% Choices for testing (1) above
% ----------------------------------------
% Slope vs. correlation
% We can test the first by comparing the slope of X1 -> y1 with X2 -> y2 
% where both models are estimated on the same individuals and errors are
% thus correlated. i.e., test slope(jk) = slope(hm)
%
% We can also test the correlations rather than slope values, r(jk) = r(hm)
% This is testing a signal to noise measure, and can be driven by differences in either
% signal or error variance between conditions.
%
% Data cases: shared variable vs. not
% In addition, sometimes we have the case where the same X predicts both y1 and y2
% and other times it is different. Steiger's correlation tests handle both
% 
% Example: pain under hand-holding -> brain under hand-holding
%   with   pain under control -> brain under control

% generate data

X1 = randn(50, 1);
y1 = X1 + randn(50, 1);
X2 = X1 + randn(50, 1); % another predictor that's correlated
y2 = .5 * X2 + randn(50, 1); % reduced slope response - a true difference

% fit models

px1 = pinv([X1 ones(size(X1))]);
px2 = pinv([X2 ones(size(X2))]);

b1 = px1 * y1;
b2 = px2 * y2;

b_diff = b1 - b2 % the difference of interest is b_diff(1)

% Plot the data

figure; plot(X1, y1, 'bo'); refline
hold on; plot(X2, y2, 'go'); refline
axis tight

% Comparing slopes vs. correlating difference scores
% --------------------------------------------------------------------
% is the comparison of slopes the same as running a single regression on contrast scores?
% no, they are different:

px3 = pinv([X1 - X2 ones(size(X1))]);
b_con = px3 * [y1 - y2]

% this is because using contrast scores does not test the difference in slopes. 
% thought experiment: Ps could have the exact same values on the predictor (X1 == X2)
% but different relationships with y2 (e.g. brain). The predictor (X)
% values for the contrast score regression are all exactly zero, so the
% correlation on contrast scores cannot even be tested. But there is a
% meaningful difference between the slopes.

% stats on the slope difference
% --------------------------------------------------------------------
n = size(X1, 1);
X = [X1; X2];               % Stacked predictors
X = [ones(2*n, 1) X];       % full matrix with intercept
y = [y1; y2];               % Stacked outcome
Z = ones(2*n, 1);           % Random effects
G = [(1:n)';(1:n)'];     % Grouping variable: Subject

lme = fitlmematrix(X,y,Z,G,'FixedEffectPredictors',...
{'Intercept','Predictor'},...
'RandomEffectPredictors',{{'Intercept','Predictor'}},...
'RandomEffectGroups',{'Subject'},'CovariancePattern','Isotropic')

% bootstrap differences in slope?
% mixed LME with correlated errors for the two conditions


% Comparing slopes vs. comparing correlations
% --------------------------------------------------------------------
% Steiger (1980) is a classic paper with results on comparing dependent
% correlations. The formula for Z-scores Z1* and Z2* (eqs. 12 and 13)
% work for the case 

out = correl_compare_dep([X1 y1], [X2 y2], 'alpha', .05); % , ['rank'],['table'])
fprintf('Compared dependent correlations: r1 = %3.2f vs. r2 = %3.2f, Z_diff = %3.2f, p = %3.4f\n', out.r1(1, 2), out.r2(1, 2), out.Z(1, 2), out.p(1, 2));

% see also: correl_compare_dep_search(seedself,seedother,self,other,'alpha',.005,'mask',mask,'rank');
 
