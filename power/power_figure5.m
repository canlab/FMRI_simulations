%% Power as a function of effect size (x) and sample size (y) with SnPM whole-brain correction

%% RFT estimated thresholds

%Nichols and Hayasaka 2003:  
%t(19) needs to be 6.5 for low smoothness (high-res, also Bonf threshold), 
% 6 for medium smoothness (6 mm), 5.5 for standard 3T smoothness (8 mm)
% Estimated from simulation figures - approximate ballpark estimates only.
% actual results are data-dependent

% thr_bonf = (1 - tcdf(6.5, 19)) ./ 2
% thr_6mm_rft = (1 - tcdf(6, 19)) ./ 2  % random field, two-tailed (/2)
% thr_6mm_perm = (1 - tcdf(5.7, 19)) ./ 2  % random field, two-tailed (/2)
% thr_8mm_rft = (1 - tcdf(5.65, 19)) ./ 2
thr_8mm_perm = (1 - tcdf(5.5, 19)) ./ 2; % P-value threshold for SnPM FWER


%%

create_figure('Power');

dvals = [.5:.1:.8];

colors = custom_colors([.7 .5 .2], [1 .6 .2], length(dvals));


% axis limits
set(gca, 'XLim', [0 300]);

ylabel('Power')

% crosshairs (n is determined in advance)

hh = plot_horizontal_line(.8);
set(hh, 'LineStyle', '--', 'Color', [.2 .2 .2])

for i = 1:length(dvals)
    
    % estimated sample FDR corrected q  < .05 = p < .002 based on pain
    % results: actual results may vary
    
    
    [ncrit,pow,obspow] = power_calc(dvals(i), thr_8mm_perm, 20, 'd', colors{i}, 0, 2);
    
    wh = 1;  % 1 or 2 for 1-group or two-group
    
    if dvals(i) == .5 || dvals(i) == .8
        plot([ncrit(wh) ncrit(wh)], [0 .05], 'color', colors{i}, 'LineWidth', 3);
        plot([ncrit(wh) ncrit(wh)], [.15 .8], 'color', colors{i}, 'LineWidth', 1, 'LineStyle', ':');
        text(ncrit(wh) - 10, .07, sprintf('d = %3.2f\nN = %3.0f', dvals(i), wh*ncrit(wh)), 'FontSize', 18);
    end
    
end

set(gca, 'FontSize', 28);

switch wh
    case 1
        xlabel('Sample size (N)');
    case 2
        xlabel('Sample size (N) per group');
end

title('Power: SnPM FWER p < .05 whole-brain');

scn_export_papersetup(600);
saveas(gcf, 'power_figure5_onegroup.png');

%%
create_figure('Power');

dvals = [.5:.1:.8];

colors = custom_colors([.7 .5 .2], [1 .6 .2], length(dvals));


% axis limits
set(gca, 'XLim', [0 300]);

ylabel('Power')

% crosshairs (n is determined in advance)

hh = plot_horizontal_line(.8);
set(hh, 'LineStyle', '--', 'Color', [.2 .2 .2])

for i = 1:length(dvals)
    
    % estimated sample FDR corrected q  < .05 = p < .002 based on pain
    % results: actual results may vary
    
    
    [ncrit,pow,obspow] = power_calc(dvals(i), thr_8mm_perm, 20, 'd', colors{i}, 0, 2);
    
    wh = 2;  % 1 or 2 for 1-group or two-group
    
    if dvals(i) == .5 || dvals(i) == .8
        plot([ncrit(wh) ncrit(wh)], [0 .05], 'color', colors{i}, 'LineWidth', 3);
        plot([ncrit(wh) ncrit(wh)], [.15 .8], 'color', colors{i}, 'LineWidth', 1, 'LineStyle', ':');
        text(ncrit(wh) - 10, .07, sprintf('d = %3.2f\nN = %3.0f', dvals(i), wh*ncrit(wh)), 'FontSize', 18);
    end
    
end

set(gca, 'FontSize', 28);

switch wh
    case 1
        xlabel('Sample size (N)');
    case 2
        xlabel('Sample size (N) per group');
end

title('Power: SnPM FWER p < .05 whole-brain');

scn_export_papersetup(600);
saveas(gcf, 'power_figure5_2group.png');
