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
myslicez = 10;


mask = fmri_data(which('SPM8_colin27T1_cortical_ribbon.img'));
overlay = which('spm2_single_subj_T1_scalped.img');

%orthviews(mask, 'overlay', which('spm2_single_subj_T1.img'))

%% Simulated data

signalimage = fmri_data(which('canonical_ventricles.img'));

[buck, bucknames] = load_image_set('bucknerlab');
signalimage.dat = signalimage.dat + sum(buck.dat(:, [5 7]), 2);

[obj, true_obj, noise_obj] = sim_data(fmri_data, 'n', N, 'true_region_mask', signalimage, 'd', 1);

% True
mt = mean(true_obj);

% Observed
t = ttest(obj, pthr, 'unc');

%% True map

montage(mean(true_obj), 'compact2', 'color', [1 .9 0]);

saveas(gcf, fullfile(figsavedir, 'lie3_true_map.png'))

%% orthviews for selective slicing

t = threshold(t, .0001, 'unc');
figure; montage(t)

saveas(gcf, fullfile(figsavedir, 'lie3b_selective_slice.png'))

%% Figure

create_figure('slices', nr, nc);

o3 = fmridisplay('overlay', overlay);

for i = 1:2
      
    subplot(nr, nc, i)
    o3 = montage(o3, 'axial', 'slice_range', [myslicez myslicez], 'onerow', 'existing_axes', gca);
    camzoom(1.6)
    
end

o3 = addblobs(o3, region(t), 'splitcolor', 'wh_montages', 1, 'cmaprange', [-5 5]);

tm = apply_mask(t, mask);

o3 = addblobs(o3, region(tm), 'splitcolor', 'wh_montages', 2, 'cmaprange', [-5 5]);


%% Save


cd('/Users/torwager/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
figsavedir = fullfile(pwd, 'figures');
mkdir(figsavedir)
saveas(gcf, fullfile(figsavedir, 'lie3_masking.svg'))
saveas(gcf, fullfile(figsavedir, 'lie3_masking.png'))