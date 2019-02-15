o2 = canlab_results_fmridisplay([], 'multirow', 4);

%%
% Simulate data
% ---------------------------------------------------------------------

N = 10;

[obj, true_obj, noise_obj] = sim_data(fmri_data, 'n', N, 'd', 1, 'smoothness', 10);

% Threshold - extent-correction, primary p < .01
% ---------------------------------------------------------------------

obj.image_names = 'tmp_resid_imgs.nii';
obj.fullpath = fullfile(pwd, obj.image_names);
write(obj);

% Get extent threshold
[cl_ext_spm, fwhm] = cl_ext_spm_grf(.05, .01, obj.image_names, which('gray_matter_mask.img'));

t = ttest(obj, .01, 'unc');
t = threshold(t, .01, 'unc', 'k', cl_ext_spm);

% Montages
% ---------------------------------------------------------------------

o2 = removeblobs(o2);

o2 = addblobs(o2, region(mean(true_obj)), 'color', [1 .9 0], 'wh_montages', 1:2);
o2 = title_montage(o2, 2, 'True signal');

o2 = addblobs(o2, region(t), 'splitcolor', 'wh_montages', 3:4);
o2 = title_montage(o2, 4, 'Cluster extent corrected');

o2 = montage(region(t), o2, 'unique', 'wh_montages', 5:6);
o2 = title_montage(o2, 6, 'Unique clusters');


falsepositives = t.sig & ~obj.additional_info{2}.wh_true;
fp_obj = t;
fp_obj.sig = falsepositives;

o2 = montage(region(fp_obj), o2, 'color', [.3 .3 .3], 'wh_montages', 7:8);
o2 = montage(region(fp_obj), o2, 'color', [.1 .1 .1], 'outline', 'wh_montages', 7:8);

o2 = title_montage(o2, 8, 'False positive voxels');

% Print summary statistics

fpr = sum(falsepositives) / sum(t.sig);
ppv = 1 - fpr;
fprintf('The voxel-wise false positive rate, or false discovery rate, is %3.2f\nThe ppv is %3.2f, meaning that a significant voxel has an %3.0f%% chance of containing true signal.\n', fpr, ppv, 100*ppv);

% Example 1
% The voxel-wise false positive rate is 0.17
% The ppv is 0.83, meaning that a signifcant voxel has an  83% chance of containing true signal.

% Example 2
% The voxel-wise false positive rate is 0.24
% The ppv is 0.76, meaning that a significant voxel has an  76% chance of containing true signal.

%% Save

%cd('/Users/torwager/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
cd('/Users/tor/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
figsavedir = fullfile(pwd, 'figures');
saveas(gcf, fullfile(figsavedir, 'lie6_example2.png'))
