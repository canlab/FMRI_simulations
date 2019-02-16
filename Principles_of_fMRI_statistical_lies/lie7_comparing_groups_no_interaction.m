%Nichols and Hayasaka 2003:  
%t(19) needs to be 6.5 for low smoothness (high-res, also Bonf threshold), 
% 6 for medium smoothness (6 mm), 5.5 for standard 3T smoothness (8 mm)
% Estimated from simulation figures - approximate ballpark estimates only.
% actual results are data-dependent

%% Parameters

N = 20;
pthr = .005; % (1 - tcdf(5.5, N)) ./ 2; % typical corrected threshold, use for sim 2
nr = 1;
nc = 2;

true_mask = fmri_data(which('v4-topics-100_65_faces_face_facial_pFgA_z_FDR_0.01.nii.gz'));

%% Simulated data

% face obj has d = 1 in face regions
patient_obj = sim_data(fmri_data, 'n', N, 'd', 1, 'smoothness', 10, 'true_region_mask', true_mask);

% house obj has d = 0 in all regions
control_obj = sim_data(fmri_data, 'n', N, 'd', 1, 'smoothness', 10, 'true_region_mask', true_mask);

% The below is not really necessary, though, as there are NO TRUE
% differences
% 
% % create stacked Patient + Control images for regression
% patandcont = patient_obj;
% patandcont.dat = [patient_obj.dat control_obj.dat];
% patandcont.X = [ones(N, 1); -ones(N, 1)];
% 
% % Regression
% out = regress(patandcont); % test for differences

patient_t = ttest(patient_obj);
mask1 = fmri_data(which('gray_matter_mask.img'), 'noverbose');
patient_t = threshold(patient_t, .001, 'cluster_extent', patient_obj, 'mask', mask2);

control_t = ttest(control_obj);
mask1 = fmri_data(which('gray_matter_mask.img'), 'noverbose');
control_t = threshold(control_t, .001, 'cluster_extent', patient_obj, 'mask', mask2);

%% Save

cd('/Users/torwager/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
figsavedir = fullfile(pwd, 'figures');
saveas(gcf, fullfile(figsavedir, 'lie5_regions.png'))

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

o3 = addblobs(o3, region(patient_t), 'splitcolor', 'wh_montages', 2, 'cmaprange', [-5 5]);

o3 = addblobs(o3, region(control_t), 'splitcolor', 'wh_montages', 3, 'cmaprange', [-5 5]);


%% Save

cd('/Users/torwager/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
figsavedir = fullfile(pwd, 'figures');
saveas(gcf, fullfile(figsavedir, 'lie7_comparing_groups.png'))

