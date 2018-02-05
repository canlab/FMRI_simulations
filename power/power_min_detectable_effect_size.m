
% Find minimum detectable effect size with 80% power for a given target N
% and p threshold

%% One-sample or two-sample t-test, typical FDR-correction (ballpark) 
% ----------------------------------------------------------------
pthr = .002; % typical FDR-corrected
target_n = 100;
dvals = [.1:.01:1.2];

clear ncrit

for i = 1:length(dvals)
    n_i = power_calc(dvals(i), pthr, 100, 'd');
    ncrit(i, :) = n_i;  % two columns, one for each group
end

wh = (ncrit <= target_n);
d_one_group = min(dvals(wh(:, 1)));
d_two_group = min(dvals(wh(:, 2)));

fprintf('With N = %3.0f and p < %3.6f, for tests of group-average activation, we have 80%% power to detect effects of d = %3.2f or larger.\n', target_n, pthr, d_one_group);

fprintf('With N = %3.0f balanced across two groups and p < %3.6f, we have 80%% power to detect group differences of d = %3.2f or larger.\n', target_n, pthr, d_two_group);


%% Correlation, typical FDR-correction (ballpark) 
% ----------------------------------------------------------------
pthr = .002; % typical FDR-corrected
target_n = 100;
rvals = [.1:.01:.99];

clear ncrit

for i = 1:length(rvals)
    n_i = power_calc(rvals(i), pthr, 100, 'r');
    ncrit(i, :) = n_i;  % two columns, one for each group
end

wh = (ncrit <= target_n);
r_one_group = min(dvals(wh(:, 1)));

fprintf('With N = %3.0f and p < %3.6f, we have 80%% power to detect a correlation of r = %3.2f or larger.\n', target_n, pthr, r_one_group);

%% One-sample or two-sample t-test, typical FDR-correction (ballpark) 
% ----------------------------------------------------------------
pthr = .002; % typical FDR-corrected
target_n = 60;
dvals = [.1:.01:1.2];

clear ncrit

for i = 1:length(dvals)
    n_i = power_calc(dvals(i), pthr, 100, 'd');
    ncrit(i, :) = n_i;  % two columns, one for each group
end

wh = (ncrit <= target_n);
d_one_group = min(dvals(wh(:, 1)));
d_two_group = min(dvals(wh(:, 2)));

fprintf('With N = %3.0f and p < %3.6f, for tests of group-average activation, we have 80%% power to detect effects of d = %3.2f or larger.\n', target_n, pthr, d_one_group);

fprintf('With N = %3.0f balanced across two groups and p < %3.6f, we have 80%% power to detect group differences of d = %3.2f or larger.\n', target_n, pthr, d_two_group);


%% One-sample or two-sample t-test, 7-network version 
% ----------------------------------------------------------------
pthr = .05 / 7;
target_n = 60;
dvals = [.1:.01:1.2];

clear ncrit

for i = 1:length(dvals)
    n_i = power_calc(dvals(i), pthr, 100, 'd');
    ncrit(i, :) = n_i;  % two columns, one for each group
end

wh = (ncrit <= target_n);
d_one_group = min(dvals(wh(:, 1)));
d_two_group = min(dvals(wh(:, 2)));

fprintf('With N = %3.0f and p < %3.6f, for tests of group-average activation, we have 80%% power to detect effects of d = %3.2f or larger.\n', target_n, pthr, d_one_group);

fprintf('With N = %3.0f balanced across two groups and p < %3.6f, we have 80%% power to detect group differences of d = %3.2f or larger.\n', target_n, pthr, d_two_group);

%% Correlation,7-network version 
% ----------------------------------------------------------------
pthr = .05 / 7;
target_n = 100;
rvals = [.1:.01:.99];

clear ncrit

for i = 1:length(rvals)
    n_i = power_calc(rvals(i), pthr, 100, 'r');
    ncrit(i, :) = n_i;  % two columns, one for each group
end

wh = (ncrit <= target_n);
r_one_group = min(dvals(wh(:, 1)));

fprintf('With N = %3.0f and p < %3.6f, we have 80%% power to detect a correlation of r = %3.2f or larger.\n', target_n, pthr, r_one_group);


