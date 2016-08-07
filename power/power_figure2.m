create_figure('Power');

dvals = [.5];

colors = custom_colors([.7 .5 .2], [1 .6 .2], length(dvals));


% axis limits
set(gca, 'XLim', [0 320]);
xlabel('N per group');
ylabel('Power')

% crosshairs (n is determined in advance)

hh = plot_horizontal_line(.8);
set(hh, 'LineStyle', '--', 'Color', [.2 .2 .2])

for i = 1:length(dvals)
    
    % estimated sample FDR corrected q  < .05 = p < .002 based on pain
    % results: actual results may vary
    
    
    [ncrit,pow,obspow] = power_calc(dvals(i), .002, 20, 'd', colors{i}, 0, 2);
    
    
    if dvals(i) == .5 || dvals(i) == .8
        plot([ncrit(2) ncrit(2)], [0 .05], 'color', colors{i}, 'LineWidth', 3);
        plot([ncrit(2) ncrit(2)], [.15 .8], 'color', colors{i}, 'LineWidth', 1, 'LineStyle', ':');
        text(ncrit(2) - 10, .07, sprintf('N = %3.0f', 2*ncrit(2)), 'FontSize', 18, 'Color', colors{i});
    end
    
end

set(gca, 'FontSize', 28);

title('Power: Comparing whole-brain methods');

%% RFT estimated thresholds

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

all_thr = [thr_6mm_perm  thr_bonf thr_6mm_rft ];
colors = {[.2 .7 .2] [.7 0 .3] , [.3 .3 1]};

% all_thr = [thr_6mm_perm thr_8mm_perm thr_bonf thr_6mm_rft thr_8mm_rft];
% 
% colors = custom_colors([.2 .7 .5], [.2 1 .6], 2);  % perm
% colors = [colors; {[.7 .3 0]}];  % bonf
% colors = [colors; custom_colors([.7 .2 .5], [1 .2 .6], 2)];  % RFT


%%
for i = 1:length(all_thr)
    
    % estimated sample FDR corrected q  < .05 = p < .002 based on pain
    % results: actual results may vary
    
    
    [ncrit,pow,obspow] = power_calc(dvals(1), all_thr(i), 20, 'd', colors{i}, 0, 2);
    
    
    if dvals(1) == .5 
        plot([ncrit(2) ncrit(2)], [0 .05], 'color', colors{i}, 'LineWidth', 3);
        plot([ncrit(2) ncrit(2)], [.15 .8], 'color', colors{i}, 'LineWidth', 1, 'LineStyle', ':');
        text(ncrit(2) - 10, .07, sprintf('N = %3.0f', 2*ncrit(2)), 'FontSize', 18, 'Color', colors{i});
    end
    
end


%%

scn_export_papersetup(600);
saveas(gcf, 'power_figure2.png');
scn_export_papersetup(500);
saveas(gcf, 'power_figure2alt.png');


