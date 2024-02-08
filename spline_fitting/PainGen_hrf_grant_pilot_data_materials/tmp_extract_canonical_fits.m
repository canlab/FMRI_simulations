Get and plot canonical HRF fits for all conditions
clear hrf_fits
for i = 1:n_conds
    hrf_fits{i} = cell2mat(FITS.hrf(i, :));
    hrf_fits{i} = hrf_fits{i}(wh_t, :)';
end


% apply contrast for heat vs. mech to cells
n_timepoints = length(time_in_sec);

wh_con = 7;
c = contrasts(:, wh_con);

hrf_fits_con = zeros(n_subj, n_timepoints);

% store averages for positive conditions and negative conditions
[hrf_fits_pos, hrf_fits_neg] = deal(zeros(n_subj, n_timepoints));

for i = 1:length(c)
    
    hrf_fits_con = hrf_fits_con + c(i) .* hrf_fits{i};
    
    if c(i) > 0
        hrf_fits_pos = hrf_fits_pos + c(i) .* hrf_fits{i};
    elseif c(i) < 0
        hrf_fits_neg = hrf_fits_neg + -c(i) .* hrf_fits{i};
    end
end

create_figure('canonical HRF fits')


mean_data{1} = lineplot_columns(hrf_fits_pos, 'color', colors{1}, 'x', time_in_sec, 'marker', 'none', 'w', 1, 'shade');

mean_data{2} = lineplot_columns(hrf_fits_neg, 'color', colors{1}, 'x', time_in_sec, 'marker', 'none', 'w', 1, 'shade');

hh = [mean_data{1}.line_han mean_data{2}.line_han];

% Line
lineh = plot_horizontal_line(0);
set(lineh, 'LineStyle', '--');

xlabel('Time in sec')
ylabel('BOLD response')

legend(hh, {'Mechanical stim' 'Heat stim'})
set(gca, 'FontSize', 22)

drawnow
snapnow