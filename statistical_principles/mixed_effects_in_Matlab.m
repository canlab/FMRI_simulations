% Matlab random effects coefficients hypothesis tests with random effects:
% https://www.mathworks.com/help/stats/linearmixedmodel.coeftest.html
% 
% https://www.mathworks.com/help/stats/linearmixedmodel.randomeffects.html?s_tid=doc_ta

% I think the way to model random effects of subject in Matlab, and test
% significance of fixed effects of condition across subjects, is to use fitlme, 
% and model random intercept for subject (1|Subject)
%  And also Subject:Condition (1|Subject:Condition).  Then use randomEffects 
% method to get estimates for random effects (estimates for each combination 
% of Subject:Condition), and use coefTest to test the contrast consisting of 
% the average Condition (or contrast across conditions) replicated across levels 
% of Subject.  Also probably want to use dfmethod = Sattherthwaite to properly 
% estimate degrees of freedom.
%  