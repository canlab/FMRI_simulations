% plot individual variability
tmp = cat(3, SPLINE.subj_data_matrices{1:6});
spline_mech = mean(tmp, 3);

ds2 = mahal(spline_mech, spline_mech);
wh = ds2 < median(ds2);

create_figure('individuals'); 
plot(time_in_sec, spline_mech(wh, :)', 'Color', [.65 .65 .65]);
hold on; plot(time_in_sec, mean(spline_mech(wh, :)), 'Color', [.2 .2 .7], 'LineWidth', 3);
xlabel('Time in sec');
ylabel('BOLD response');
set(gca, 'FontSize', 22);
axis tight


%%
% plot individual variability - FIR

tmp = cat(3, FIR.subj_data_matrices{1:6});
fir_mech = mean(tmp, 3);

ds2 = mahal(fir_mech, fir_mech);
wh = ds2 < median(ds2);

create_figure('individuals'); 
plot(time_in_sec(1:54), fir_mech(wh, :)', 'Color', [.65 .65 .65]);
hold on; plot(time_in_sec(1:54), mean(fir_mech(wh, :)), 'Color', [.2 .2 .7], 'LineWidth', 3);
xlabel('Time in sec');
ylabel('BOLD response');
set(gca, 'FontSize', 22);
axis tight
