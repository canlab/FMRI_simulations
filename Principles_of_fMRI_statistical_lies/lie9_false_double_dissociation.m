%Nichols and Hayasaka 2003:  
%t(19) needs to be 6.5 for low smoothness (high-res, also Bonf threshold), 
% 6 for medium smoothness (6 mm), 5.5 for standard 3T smoothness (8 mm)
% Estimated from simulation figures - approximate ballpark estimates only.
% actual results are data-dependent

%% Parameters

N = 20;
pthr = .001; % (1 - tcdf(5.5, N)) ./ 2; % typical corrected threshold, use for sim 2
nr = 1;
nc = 2;

true_mask = fmri_data(which('v4-topics-100_56_events_memory_autobiographical_pFgA_z_FDR_0.01.nii.gz'));

%% Simulated data

% face obj has d = 1 in face regions
social_obj = sim_data(fmri_data, 'n', N, 'd', .75, 'smoothness', 8, 'true_region_mask', true_mask);

% house obj has d = 0 in all regions
nonsocial_obj = sim_data(fmri_data, 'n', N, 'd', .75, 'smoothness', 8, 'true_region_mask', true_mask);

% The below is not really necessary, though, as there are NO TRUE
% differences
% 
% % create stacked social + nonsocial images for regression
% patandcont = social_obj;
% patandcont.dat = [social_obj.dat nonsocial_obj.dat];
% patandcont.X = [ones(N, 1); -ones(N, 1)];
% 
% % Regression
% out = regress(patandcont); % test for differences

social_t = ttest(social_obj);
mask1 = fmri_data(which('gray_matter_mask.img'), 'noverbose');
social_t = threshold(social_t, pthr, 'cluster_extent', social_obj, 'mask', mask2);

nonsocial_t = ttest(nonsocial_obj);
mask1 = fmri_data(which('gray_matter_mask.img'), 'noverbose');
nonsocial_t = threshold(nonsocial_t, pthr, 'cluster_extent', social_obj, 'mask', mask2);


%% Plot

nr = 1;
nc = 3;

create_figure('slices', nr, nc);

myslicez = -11;

o3 = fmridisplay;

for i = 1:nc
      
    subplot(nr, nc, i)
    o3 = montage(o3, 'axial', 'slice_range', [myslicez myslicez], 'onerow', 'existing_axes', gca);
    camzoom(1.5)
    
end

o3 = addblobs(o3, region(true_mask), 'color', [1 .9 0], 'wh_montages', 1);

o3 = addblobs(o3, region(social_t), 'splitcolor', 'wh_montages', 2, 'cmaprange', [-5 5]);

o3 = addblobs(o3, region(nonsocial_t), 'splitcolor', 'wh_montages', 3, 'cmaprange', [-5 5]);

%% Save

cd('/Users/torwager/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
figsavedir = fullfile(pwd, 'figures');
saveas(gcf, fullfile(figsavedir, 'lie9_regions.png'))

%% Plot spurious "double dissociation"

r1 = region(social_t);
r2 = region(nonsocial_t);

% hand-pick regions

% montage(r1, 'regioncenters');
% montage(r2, 'regioncenters');

r1 = r1(1);
r2 = r2(3);

% montage([r1 r2], 'regioncenters')

r1s = extract_data(r1, social_obj);
r1n = extract_data(r1, nonsocial_obj);

r2s = extract_data(r2, social_obj);
r2n = extract_data(r2, nonsocial_obj);

%% bar plot

s = seaborn_colors;

barplot_columns(x, 'noviolin', 'x', [1 2 4 5], 'colors', {s{5} s{17} s{5} s{17}}, 'noind', 'nostars');
set(gca, 'FontSize', 24, 'XTickLabel', '');
xlabel('');
ylabel('Activity');

set(gca, 'YLim', [.4 1.2])

%% Save

cd('/Users/torwager/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
figsavedir = fullfile(pwd, 'figures');
saveas(gcf, fullfile(figsavedir, 'lie9_barplots.png'))

