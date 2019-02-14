%Nichols and Hayasaka 2003:  
%t(19) needs to be 6.5 for low smoothness (high-res, also Bonf threshold), 
% 6 for medium smoothness (6 mm), 5.5 for standard 3T smoothness (8 mm)
% Estimated from simulation figures - approximate ballpark estimates only.
% actual results are data-dependent

%% Parameters

N = 20;
pthr = .05; % (1 - tcdf(5.5, N)) ./ 2; % typical corrected threshold, use for sim 2
nr = 1;
nc = 2;
myslicez = 10;

%% Simulated data

signalimage = fmri_data(which('canonical_ventricles.img'));

[buck, bucknames] = load_image_set('bucknerlab');
signalimage.dat = signalimage.dat + sum(buck.dat(:, [5 7]), 2);

[obj, true_obj, noise_obj] = sim_data(fmri_data, 'n', N, 'true_region_mask', signalimage);

% True
mt = mean(true_obj);

% Observed
t = ttest(obj, pthr, 'unc');


%% Figure

create_figure('slices', nr, nc);

o3 = fmridisplay;

for i = 1:2
      
    subplot(nr, nc, i)
    o3 = montage(o3, 'axial', 'slice_range', [myslicez myslicez], 'onerow', 'existing_axes', gca);
    camzoom(1.7)
    
end

o3 = addblobs(o3, region(mt), 'color', [1 .9 0], 'wh_montages', 1);

% determine threshold 
XYZ = mm2voxel([0 0 myslicez], mt.volInfo.mat); 
zslice = XYZ(3);
wh = t.volInfo.xyzlist(:, 3) == zslice;
sig_vox_slice = sum(t.sig(wh, 1))

t = threshold(t, .00005, 'unc');

o3 = addblobs(o3, region(t), 'splitcolor', 'wh_montages', 2, 'cmaprange', [-5 5]);


%% Save


cd('/Users/torwager/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
figsavedir = fullfile(pwd, 'figures');
mkdir(figsavedir)
saveas(gcf, fullfile(figsavedir, 'lie2_artifacts_to_signal.svg'))