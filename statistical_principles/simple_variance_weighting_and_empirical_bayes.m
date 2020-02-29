% Estimate variance components and weights in a simple way

%% No true diffs among means

within_var = 1;
X = randn(50, 20); % 50 obs, 20 subjects
m = nanmean(X);             % Within-subject mean estimate
v = nanvar(X);              % Within-subject variance estimate
tot_var = var(m);           % Estimated variance of mean across subjects, within + between

df_within = (size(X, 1) - 1) .* ones(1, 20); % dfe for each subject

est_var_within = v ./ df_within; % Estimated variance of individual subject means

est_mean_var_within = mean(est_var_within);         % Expected variance of subject means
                                                    % Note: variances sum, but we are interested in
                                                    % variance of mean, not sum
                           

est_var_between = max(0, tot_var - est_mean_var_within); % Naive estimate for between-subjects variance

w = 1 ./ (est_var_between + est_var_within);        % Individual subject weights
w = w ./ sum(w);

%% Individual diffs in means
% Above, we simulated a case where the true variance in the means was zero 
% Now, add some true variance:

true_btwn_var = 1;
true_btwn = sqrt(true_btwn_var) .* randn(20, 1);
B = diag(true_btwn)
b_obs = ones(50, 20) * B;

X = b_obs + rand(50, 20);   % 50 obs, 20 subjects

[w, est_var_within, est_var_between] = get_within_between_var_and_weights(X)





function [w, est_var_within, est_var_between] = get_within_between_var_and_weights(X)

m = nanmean(X);             % Within-subject mean estimate
v = nanvar(X);              % Within-subject variance estimate
tot_var = var(m);           % Estimated variance of mean across subjects, within + between

df_within = (size(X, 1) - 1) .* ones(1, 20); % dfe for each subject

est_var_within = v ./ df_within; % Estimated variance of individual subject means

est_mean_var_within = mean(est_var_within);         % Expected variance of subject means
                                                    % Note: variances sum, but we are interested in
                                                    % variance of mean, not sum
                           

est_var_between = max(0, tot_var - est_mean_var_within); % Naive estimate for between-subjects variance

w = 1 ./ (est_var_between + est_var_within);        % Individual subject weights
w = w ./ sum(w);

end
