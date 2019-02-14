% Create simulated data with true and false regions

[obj, true_obj, noise_obj] = sim_data(fmri_data, 'n', 30, 'plot');
 
scn_export_papersetup(600);
% saveas(gcf, 'sim1_d=pt5_sig+noise_n30.png');


%% Threshold and display thresholded

t = ttest(obj, .001, 'unc');

% convert t to effect size
rootn = sqrt(size(obj.dat, 2));
t.dat = t.dat ./ rootn;

meantrue = mean(true_obj);
%% display
o2 = removeblobs(o2);

o2 = addblobs(o2, region(t), 'wh_montages', 3:4, 'splitcolor', 'cmaprange', [-12 12]);
o2 = addblobs(o2, region(meantrue), 'splitcolor', 'wh_montages', 5:6, 'cmaprange', [-12 12]);

%% Surface display

% True effect size
[mip, x, y, voldata] = pattern_surf_plot_mip(meantrue);

hh = findobj(gcf, 'Type', 'axes');
set(hh(1), 'CLim', [0 1])
set(hh(2), 'CLim', [0 1], 'ZLim', [0 1])
set(gcf, 'Tag', 'true', 'Name', 'true');

scn_export_papersetup(600);
saveas(gcf, 'sim1_true_effect_map.png');

%% Estimated effect 
t.dat(~t.sig) = 0;
[mip, x, y, voldata] = pattern_surf_plot_mip(t);

hh = findobj(gcf, 'Type', 'axes');
set(hh(1), 'CLim', [0 1])
set(hh(2), 'CLim', [0 1], 'ZLim', [0 1])
set(gcf, 'Tag', 'estimated', 'Name', 'estimated');

scn_export_papersetup(600);
saveas(gcf, 'sim1_est_effect_map.png');
%% Histogram of sig. regions in which d is over-estimated
wh_true = meantrue.dat > 0;
wh_sig = t.dat > 0;
wh_true_pos = wh_true & wh_sig;
wh_true_over = wh_true_pos & t.dat > meantrue.dat; sum(wh_true_over)
wh_true_under = wh_true_pos & t.dat < meantrue.dat; sum(wh_true_under)

create_figure('estimated effect sizes');
[h, x] = hist(t.dat(wh_true_pos));
han = bar(x, h);

han = bar(x, h, 'FaceColor', [.6 .6 .6]);
set(gca, 'XLim', [-.5 1.5]);
han2 = plot_vertical_line(.5); set(han2, 'LineStyle', ':', 'LineWidth', 2);

set(gca, 'FontSize', 32);
scn_export_papersetup(800);
saveas(gcf, 'sim1_est_effect_histogram.png');
set(gca, 'FontSize', 18);

%% Slab plot

%ovlname = which('keuken_2014_enhanced_for_underlay.img');

ovlname = 'keuken_2014_enhanced_for_underlay';

ycut_mm = -30;
coords = [0 ycut_mm 0];
coords = [0 0 20];

% figure;
% [D,Ds,hdr,p2,bestCoords] = tor_3d('whichcuts','z','coords', coords, 'topmm', 90, 'filename', ovlname, 'intensity_threshold', 90);

anat = fmri_data(which('keuken_2014_enhanced_for_underlay.img'));

figure; 
set(gcf, 'Tag', 'surface'); 
f1 = gcf;

p = isosurface(anat, 'thresh', 140, 'nosmooth', 'zlim', [-Inf 20]);
view(137, 26);
lightRestoreSingle
colormap gray; 
brighten(.6); 
set(p, 'FaceAlpha', 1);
drawnow

set(f1, 'Color', 'w');

%% TRUE EFFECT SIZES ON SLAB

[mip, x, y, voldata] = pattern_surf_plot_mip(meantrue, 'nosmooth');

figure(f1)

hold on;
% rescale to match color map we want (kludge)
han = surf(x, y, mip .* 70 + 20);

set(han, 'AlphaDataMapping', 'scaled', 'AlphaData', abs(mip) .^ .5, 'FaceColor', 'interp', 'FaceAlpha', 'interp', 'EdgeColor', 'interp');
set(han, 'EdgeColor', 'none');

% Set colormap
def = colormap('parula');
gray = colormap('gray');
cm = [def; gray];
colormap(cm);

view(147, 50);
axis off
drawnow

scn_export_papersetup(600);
% saveas(gcf, 'sim1_true_effect_size_slab.png');

%% ESTIMATED EFFECT SIZES ON SLAB

delete(han)

[mip, x, y, voldata] = pattern_surf_plot_mip(t, 'nosmooth');

figure(f1)

hold on;
han = surf(x, y, mip .* 70 + 20);

set(han, 'AlphaDataMapping', 'scaled', 'AlphaData', abs(mip) .^ .5, 'FaceColor', 'interp', 'FaceAlpha', 'interp', 'EdgeColor', 'interp');
%set(han, 'FaceColor', 'interp', 'EdgeColor', 'none');

set(han, 'EdgeColor', 'none');

% Set colormap
def = colormap('parula');
gray = colormap('gray');
cm = [def; gray];
colormap(cm);

view(147, 50);
axis off
drawnow

ch =  colorbar;
ticks = [0 .5 1] * 70 + 20;
set(ch, 'Ticks', ticks, 'TickLabels', [0 .5 1], 'FontSize', 18);

scn_export_papersetup(600);
saveas(gcf, 'sim1_obs_effect_size_slab.png');
