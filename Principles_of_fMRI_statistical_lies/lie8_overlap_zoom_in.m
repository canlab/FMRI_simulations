o2 = canlab_results_fmridisplay([], 'multirow', 3);

%% Get 'true' pain and rejection maps
% ---------------------------------------------------------------------

% Load PLS signatures from Kragel et al. 2018
  [obj, names] = load_image_set('pain_cog_emo');
  obj = get_wh_image(obj, [8 24]);
  names = names([8 24]);
  
  
thr = 2.32873180721072e-05; % 75th percentile

obj = threshold(obj, [thr Inf], 'raw-between');

% binarize
obj.dat(obj.dat > 0) = 1;
  
overlapping_vox = sum(all(obj.dat, 2));

vox_per_task = double(sum(obj.dat));

fprintf('%3.0f%% of pain-related voxels and %3.0f of emotion-related voxels\n', 100*overlapping_vox ./ vox_per_task);
% 8% for both

% intersection object

obj_intersect = obj;
obj_intersect.dat = single(all(obj.dat, 2));


%% Montages
% ---------------------------------------------------------------------

o2 = removeblobs(o2);

obj1 = get_wh_image(obj, 1);
obj2 = get_wh_image(obj, 2);

color1 = [1 .7 0];
color2 = [.2 .5 1];
color3 = [.3 1 .3]; % (color1 + color2) ./ 2;

o2 = addblobs(o2, region(obj1), 'color', color1, 'wh_montages', 1:2, 'trans');
o2 = addblobs(o2, region(obj2), 'color', color2, 'wh_montages', 3:4, 'trans');
o2 = addblobs(o2, region(obj_intersect), 'color', color3, 'wh_montages', 5:6, 'trans');
o2 = addblobs(o2, region(obj_intersect), 'color', color3 ./ 2, 'wh_montages', 5:6, 'outline');

o2 = title_montage(o2, 2, 'Pain');
o2 = title_montage(o2, 4, 'Emotion');
o2 = title_montage(o2, 6, 'Overlap');

%% Save 
cd('/Users/torwager/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
%cd('/Users/tor/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
figsavedir = fullfile(pwd, 'figures');
saveas(gcf, fullfile(figsavedir, 'lie8_all_slices.png'))

%% The biased view -- overlap-focus

r = region(obj_intersect);
r(cat(1, r.numVox) < 100)  = [];

montage(r, 'saggital', 'color', color3)

%% Save
cd('/Users/torwager/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
%cd('/Users/tor/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
figsavedir = fullfile(pwd, 'figures');
saveas(gcf, fullfile(figsavedir, 'lie8_overlap.png'))

%% Get magnitude of weights in region

% Back to original weights/images values
[obj, names] = load_image_set('pain_cog_emo');
obj = get_wh_image(obj, [8 24]);

r = extract_data(r, obj);
r = autolabel_regions_using_atlas(r); % add names; makes easier to find area of interest
%%
create_figure('bars', 1, 2);

%barplot_colored(repmat((10000 * r(4).dat)', 2, 1), 'colors', {color1 color2})

barplot_colored(10000 * r(4).all_data', 'colors', {color1 color2})
set(gca, 'XTick', 1:2, 'XLim', [.5 2.5], 'XTickLabel', {'Pain' 'Emotion'}, 'FontSize', 24)
title('Medial PFC')

subplot(1, 2, 2);
barplot_colored(10000 * r(1).all_data', 'colors', {color1 color2})
set(gca, 'XTick', 1:2, 'XLim', [.5 2.5], 'XTickLabel', {'Pain' 'Emotion'}, 'FontSize', 24)
title('Cerebellum')

%% Save
cd('/Users/torwager/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
%cd('/Users/tor/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
figsavedir = fullfile(pwd, 'figures');
saveas(gcf, fullfile(figsavedir, 'lie8_bars_in_regions.png'))

%% Overlap as a function of threshold

[obj, names] = load_image_set('pain_cog_emo');
obj = get_wh_image(obj, [8 24]);
names = names([8 24]);

desc = descriptives(obj)

% percentiles above median, because below median contains deactivation areas
% so we look at overlap in positive effects, to simplify
wh = desc.prctiles >= 50;
x = desc.prctiles(wh); 

thr = desc.prctile_vals(wh);

clear percent_overlap

for i = 1:length(x)
    
    obj_thr = threshold(obj, [thr(i) Inf], 'raw-between');
    
    % binarize
    obj_thr.dat(obj_thr.dat > 0) = 1;
    obj_thr.dat(obj_thr.dat <= 0) = 0;
    
    overlapping_vox = sum(all(obj_thr.dat, 2));
    
    vox_per_task = double(sum(obj_thr.dat));
    
    percent_overlap(i, :) = 100*overlapping_vox ./ vox_per_task;
    
end

create_figure('overlap');
set(gca, 'FontSize', 18);

color1 = [1 .7 0];
color2 = [.2 .5 1];

plot(x, percent_overlap(:, 1), 'o-', 'color', color1 ./ 2, 'MarkerFaceColor', color1);
plot(x, percent_overlap(:, 2), 'o-', 'color', color2 ./ 2, 'MarkerFaceColor', color2);

ylabel('Overlapping voxels (% shared)');
xlabel('Threshold (percentile)');

%% Save
cd('/Users/torwager/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
%cd('/Users/tor/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
figsavedir = fullfile(pwd, 'figures');
saveas(gcf, fullfile(figsavedir, 'lie8_overlap_by_threshold.png'))
