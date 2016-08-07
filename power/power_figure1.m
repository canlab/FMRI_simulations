create_figure('Power');

dvals = [.5:.1:.8];

colors = custom_colors([.7 .5 .2], [1 .6 .2], length(dvals));


% axis limits
set(gca, 'XLim', [0 200]);
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
        text(ncrit(2) - 10, .07, sprintf('N = %3.0f', 2*ncrit(2)), 'FontSize', 18);
    end
    
end

set(gca, 'FontSize', 28);

title('Power: FDR q < .05 whole-brain');
