%% Calculate power needed for FWER correction using permutation test
% With average effective comparisons based on Nichols and Hayasaka

%Nichols and Hayasaka 2003:  
%t(19) needs to be 6.5 for low smoothness (high-res, also Bonf threshold), 
% 6 for medium smoothness (6 mm), 5.5 for standard 3T smoothness (8 mm)
% Estimated from simulation figures - approximate ballpark estimates only.
% actual results are data-dependent

thr_bonf = (1 - tcdf(6.5, 19)) ./ 2;
thr_6mm_rft = (1 - tcdf(6, 19)) ./ 2;  % random field, two-tailed (/2)
thr_6mm_perm = (1 - tcdf(5.7, 19)) ./ 2;  % random field, two-tailed (/2)
thr_8mm_rft = (1 - tcdf(5.65, 19)) ./ 2;
thr_8mm_perm = (1 - tcdf(5.5, 19)) ./ 2;

n_bonf = .025 / thr_bonf;
n_perm = .025 / thr_6mm_perm;
n_rft = .025 / thr_6mm_rft;

% This is the n you would have to Bonferroni correct by to yield corrected
% results on average with SnPM
n_effective_comps = n_perm;  %[n_20 n_bonf n_perm n_rft];

%% Calculate N needed for each effect size

dvals = [.15:.01:1.2];

rvals = [.1:.01:.95];

n = 100; % fixed references sample size - for observed power, not used here

% x = num comparisons
% y = power

% axis limits
set(gca, 'XLim', [0 max(dvals)]); % log plot
xlabel('Effect size (d)');
ylabel('N needed')

% crosshairs (n is determined in advance)

hh = plot_horizontal_line(.8);
set(hh, 'LineStyle', '--', 'Color', [.2 .2 .2])

obspow = NaN .* zeros(length(cvals), length(dvals));

clear n_needed n_needed_r

for i = 1:length(dvals)
    
    n_needed(i, :) = power_calc(dvals(i), .025 ./ n_effective_comps, n);

end

for i = 1:length(rvals)
    
    n_needed_r(i, :) = power_calc(rvals(i), .025 ./ n_effective_comps, n, 'r');
    
end

% First column of n_needed is one-sample test, 2nd is two-sample test

%% Create plot, draw vertical lines

nvals = [30 50 100 200 500 600 1000];
mymax = 100;
textoffset = 90;

colors = custom_colors([.7 .5 .2], [1 .6 .2], length(nvals));

create_figure('Power', 1, 2);

plot(dvals, n_needed(:, 1), 'Color', [.3 .3 .3], 'LineWidth', 5);

set(gca, 'FontSize', 20);
title('SnPM FWER correction, one sample');
ylabel('Number needed');
xlabel('Effect size (d)');


clear hh
for i = 1:length(nvals)
    
    wh = find(n_needed(:, 1) < nvals(i));
    min_d_detectable_power80(i) = dvals(wh(1)); 
    
    textlabels{i} = sprintf('N = %3.0f\nd = %3.2f', nvals(i), min_d_detectable_power80(i));
    
    plot([min_d_detectable_power80(i) min_d_detectable_power80(i)], [0 nvals(i)], 'Color', colors{i}, 'LineWidth', 3);
    text(min_d_detectable_power80(i), nvals(i)+textoffset, textlabels{i}, 'FontSize', 18, 'Color', [.2 .2 .2]);
        
end

subplot(1, 2, 2)

plot(rvals, n_needed_r(:, 1), 'Color', [.3 .3 .3], 'LineWidth', 5);

set(gca, 'FontSize', 20);
title('SnPM FWER correction, correlation');
ylabel('Number needed');
xlabel('Correlation (r)');

clear hh
for i = 1:length(nvals)
    
    wh = find(n_needed_r(:, 1) < nvals(i));
    min_r_detectable_power80(i) = rvals(wh(1)); 
    
    textlabels{i} = sprintf('N = %3.0f\nr = %3.2f', nvals(i), min_r_detectable_power80(i));
    
    plot([min_r_detectable_power80(i) min_r_detectable_power80(i)], [0 nvals(i)], 'Color', colors{i}, 'LineWidth', 3);
    text(min_r_detectable_power80(i), nvals(i)+textoffset, textlabels{i}, 'FontSize', 18, 'Color', [.2 .2 .2]);
        
end

%%
scn_export_papersetup(600);
saveas(gcf, 'power_figure4.png');
scn_export_papersetup(500);
saveas(gcf, 'power_figure4alt.png');


%%
legend(hh, {'d = 0.5' 'd = 0.8' 'd = 1.1'});

textlabels = {'20 ROIs' 'Bonf' 'Perm' 'RFT'};

plot(log([1 1]), [0 .05], 'Color', [.5 .5 .5], 'LineWidth', 5);
text(log(1), .07, '1 test', 'FontSize', 18, 'Color', [.2 .2 .2]);

for j = 1:length(n_effective_comps)
    
    myx = log([n_effective_comps(j) n_effective_comps(j)]);
    plot(myx, [0 .05], 'Color', [.5 .5 .5], 'LineWidth', 5);
    text(log(n_effective_comps(j)), .07, sprintf('%s', textlabels{j}), 'FontSize', 18, 'Color', [.2 .2 .2]);

%     myy = cvals(
%     plot(myx, [0 .8], 'color', colors{i}, 'LineWidth', 1, 'LineStyle', ':');
end
    
%%

%% SIMPLER VERSION - d = 0.5

cla
legend off
title('Power to detect moderate effect size');

clear hh
for i = 1:1
    
    hh(i) = plot(log(cvals), obspow(:, i), 'color', colors{i}, 'LineWidth', 3);
    
end

textlabels = {'20 ROIs' 'Bonf' 'Perm' 'RFT'};

plot(log([1 1]), [0 .8], 'Color', [.5 .5 .5], 'LineStyle', ':', 'LineWidth', 2);
text(log(1), .07, '1 test', 'FontSize', 18, 'Color', [.2 .2 .2]);

for j = 1:length(n_effective_comps)
    
    myx = log([n_effective_comps(j) n_effective_comps(j)]);
    plot(myx, [0 .8], 'Color', [.5 .5 .5], 'LineStyle', ':', 'LineWidth', 2);

    text(log(n_effective_comps(j)), .07, sprintf('%s', textlabels{j}), 'FontSize', 18, 'Color', [.2 .2 .2]);

%     myy = cvals(
%     plot(myx, [0 .8], 'color', colors{i}, 'LineWidth', 1, 'LineStyle', ':');
end
    
%%

scn_export_papersetup(600);
saveas(gcf, 'power_figure3B.png');
scn_export_papersetup(500);
saveas(gcf, 'power_figure3Balt.png');


%% what is power with SNPM correction (perm)?

wh = find(cvals >= n_perm); wh = wh(1);
obspow(wh, :)

% small     large     massive
% 0.0125    0.2767    0.8709
