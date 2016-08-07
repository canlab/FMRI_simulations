%%

%Nichols and Hayasaka 2003:  
%t(19) needs to be 6.5 for low smoothness (high-res, also Bonf threshold), 
% 6 for medium smoothness (6 mm), 5.5 for standard 3T smoothness (8 mm)
% Estimated from simulation figures - approximate ballpark estimates only.
% actual results are data-dependent

thr_bonf = (1 - tcdf(6.5, 19)) ./ 2
thr_6mm_rft = (1 - tcdf(6, 19)) ./ 2  % random field, two-tailed (/2)
thr_6mm_perm = (1 - tcdf(5.7, 19)) ./ 2  % random field, two-tailed (/2)
thr_8mm_rft = (1 - tcdf(5.65, 19)) ./ 2
thr_8mm_perm = (1 - tcdf(5.5, 19)) ./ 2

n_bonf = .025 / thr_bonf
n_perm = .025 / thr_6mm_perm
n_rft = .025 / thr_6mm_rft

n_20 = 20;

n_effective_comps = [n_20 n_bonf n_perm n_rft];

%%
create_figure('Power');

dvals = [.5 .8 1.1];

cvals = [1:10 15:5:100 110:10:300 350:50:1000 1000:100:12000 12500:500:exp(12)];

n = 34; % fixed sample size - detect medium effect without MC, n = 34
% one-sample power

colors = custom_colors([.7 .5 .2], [1 .6 .2], length(dvals));

% x = num comparisons
% y = power

% axis limits
set(gca, 'XLim', [0 12]); % log plot
xlabel('Log(Effective comparisons)');
ylabel('Power')

% crosshairs (n is determined in advance)

hh = plot_horizontal_line(.8);
set(hh, 'LineStyle', '--', 'Color', [.2 .2 .2])

obspow = NaN .* zeros(length(cvals), length(dvals));

for i = 1:length(dvals)
    
    for j = 1:length(cvals)
        
    [~, ~, obspow(j, i)] = power_calc(dvals(i), .025 ./ cvals(j), n);
    
    end
    
end

set(gca, 'FontSize', 28);

title('Power as a function of effective comparisons');

%% Draw lines

%cla
clear hh
for i = 1:length(dvals)
    
    hh(i) = plot(log(cvals), obspow(:, i), 'color', colors{i}, 'LineWidth', 3);
    
end

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

scn_export_papersetup(600);
saveas(gcf, 'power_figure3.png');
scn_export_papersetup(500);
saveas(gcf, 'power_figure3alt.png');


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
