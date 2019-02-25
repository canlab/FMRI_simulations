

% Confidence interval for effect size 
%
% Estimated effect sizes vary from sample to sample around the true long-run (or infinite sample) effect size.
% This means that P-values vary as well. We might observe a P-value of 0.01 in one group or study and a P-value
% of 0.30 in another. Does this mean that the effect in group 1 is stronger than in group 2?  Not necessarily.
% Because effect sizes vary randomly due to sampling error (noise), P-values also vary. 
% If we want to ask whether two effect sizes, or two P-values, are significantly different, we need to know the
% variance of the effect size, i.e., the variance of the signal divided by the noise. This depends on both the
% variance of the signal and the variance of the noise, or the variance of
% the variance estimate. Thus, the effect size (or P-value) will always be more variable than the estimate of 
% the effect magnitude, which is where most statistical testing stops. 
%
%

% Hedge LV, Olkin I. Statistical methods for meta-analysis. Orlando: Academic Press Inc; 2014. p. 86.
% Alternatives to P value: confidence interval and effect size
% Or: Confidence Intervals on Effect Size

% For Cohen's d, David C. Howell from the University of Vermont provides a
% method based on the noncentral t distribution.
% t  = d * sqrt(N)
% we want the critical value x where noncentral tcdf is 0.025 and 0.975 for 2-tailed CI
% or .05 .95 for 90% CI

%% Example: Take a P-value, and convert to effect size (d)
% Calculate how low the P-value would have to be to be significantly lower
% -------------------------------------------------------------------------
p = .01;
dfmodel = 1; % N = dfmodel + dfe
dfe = 29;  % N - 1 for one-sample test
tails = 2;

p2d = @(p, dfmodel, dfe, tails) abs(tinv(p ./ tails, dfe)) ./ sqrt(dfmodel + dfe);

d = p2d(p, dfmodel, dfe, tails)

[d_CI, P, P_CI] = effect_size_CI(d, dfmodel + dfe)

% sample size 1,000
% Same confidence interval for P-values!

d = p2d(p, 1, 1000, tails)
[d_CI, P, P_CI] = effect_size_CI(d, dfmodel + dfe)

%% How small would a P-value have to be to be significantly below P = 0.10?


dfmodel = 1; % N = dfmodel + dfe
dfe = 50;  % N - 1 for one-sample test
tails = 2;

p = .01;
P_CI = 1;

while P_CI(1) >= .10
    
    % shrink P-value
    p = p .* .9;
    
    d = p2d(p, dfmodel, dfe, tails);
    
    [d_CI, P, P_CI] = effect_size_CI(d, dfmodel + dfe);
    
end


%% More explnation and calculations for this example
% Note: The code below gives slightly different values from the function
% This should be further checked and tightened.
%
% t = tinv(p), so, unsigned (consider magnitude only):
% t = abs(tinv(p), dfe)     % for one-tailed P-value
% t = abs(tinv(p/2), dfe)   % for two-tailed P-value

% Formulas
p2t = @(p, dfe, tails) abs(tinv(p ./ tails, dfe));

p2d = @(p, dfmodel, dfe, tails) abs(tinv(p ./ tails, dfe)) ./ sqrt(dfmodel + dfe);

d2t = @(d, dfmodel, dfe) d .* sqrt(dfmodel+dfe);

d2p = @(d, dfmodel, dfe, tails) tails .* (1 - tcdf(d .* sqrt(dfmodel+dfe), dfe));

t = p2t(p, dfe, 1);
d = p2d(p, dfmodel, dfe, tails);

% Effect size for confidence interval
% See effect_size_CI

d_CI = effect_size_CI(d, dfmodel + dfe, dfe)

% we want critical value x where noncentral tcdf is 0.025 and 0.975 for 2-tailed CI
% Choose decreasing values of x, offset, until p value is high enough. t-x  is the lower bound. 

x = 0;
p = nctcdf(t, dfe, t);
while p <= 0.975
    x = x + 0.01;
    p = nctcdf(t, dfe, t - x);
end

% now convert back to d
d_CI = (t - x) / sqrt(dfmodel + dfe);

% Choose different values of x, offset, until p value is low enough. t+x  is the upper bound. 

x = 0;
p = nctcdf(t, dfe, t);
while p >= 0.025
    x = x + 0.01;
    p = nctcdf(t, dfe, t + x);
end

d_CI(2) = (t + x) / sqrt(dfmodel + dfe);

% Now convert d back to p
P_CI = d2p(d_CI, dfmodel, dfe, tails);

d_CI
P_CI

%%



obs_d = 0.65;

n = 17;
t = obs_d * sqrt(n)
x = [0:.1:t]; % we want critical value x where noncentral tcdf is 0.025 and 0.975 for 2-tailed CI
p = nctcdf(t, n-1, x);
wh = find(p < 0.975);
d_CI = x(wh(1)); % bounds on t (noncentrality parameter)

x = [t:.1:4*t]; % we want critical value x where noncentral tcdf is 0.025 and 0.975 for 2-tailed CI
p = nctcdf(t, n-1, x);
wh = find(p > 0.025);
d_CI(2) = x(wh(end));

d_CI = d_CI ./ sqrt(n); % convert back to units of d

% d_CI =
% 
%     0.1213    1.1593


