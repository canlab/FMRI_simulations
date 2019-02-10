%Nichols and Hayasaka 2003:  
%t(19) needs to be 6.5 for low smoothness (high-res, also Bonf threshold), 
% 6 for medium smoothness (6 mm), 5.5 for standard 3T smoothness (8 mm)
% Estimated from simulation figures - approximate ballpark estimates only.
% actual results are data-dependent

N = 30;

pthr = (1 - tcdf(5.5, N)) ./ 2 % typical corrected threshold

pthr = .001; % use this one for sim 1

%% Simulated data

[obj, true_obj, noise_obj] = sim_data(fmri_data, 'n', N, 'plot');

mt = mean(true_obj);

% Counts
istrue = mt.dat > 100*eps; % true pos vox
ntrue = sum(istrue); % num true

% Preliminary figure of true signal 

t = ttest(obj, pthr, 'unc');

% convert t to effect size
rootn = sqrt(size(obj.dat, 2));
t.dat = t.dat ./ rootn;

o2 = canlab_results_fmridisplay([], 'multirow', 1);
o2 = addblobs(o2, region(t), 'splitcolor', 'wh_montages', 1:2, 'cmaprange', [-2 2]);
o2 = addblobs(o2, region(mt), 'color', [0 0 0], 'wh_montages', 1:2, 'outline');

%%
create_figure('slices', 5, 5);

o3 = fmridisplay;

for i = 1:5*5
      
    subplot(5, 5, i)
    o3 = montage(o3, 'axial', 'slice_range', [40 40], 'onerow', 'existing_axes', gca);
    
end

o3 = addblobs(o3, region(mt), 'color', [0 0 0], 'wh_montages', 1:5*5, 'outline');
o3 = addblobs(o3, region(mt), 'color', [.5 .5 1], 'wh_montages', 1:5*5, 'trans');

for i = 1:5*5
      
    subplot(5, 5, i)
    camzoom(1.8)
    
end

clear tp fp spec r
is_sig_matrix = zeros(size(istrue, 1), 5*5);

for i = 1:5*5
      
    subplot(5, 5, i)
    
    obj = sim_data(fmri_data, 'n', N);
    t = ttest(obj, pthr, 'unc');
    rootn = sqrt(size(obj.dat, 2));
    t.dat = t.dat ./ rootn;

    r{i} = region(t);  % save these
    o3 = addblobs(o3, r{i}, 'splitcolor', 'wh_montages', i, 'cmaprange', [-2 2]);
    
    % statistics on this sample
    
    tp(i, 1) = sum(t.sig & istrue) / ntrue; % hit rate
    fp(i, 1) = sum(t.sig & ~istrue) / sum(~istrue); % false alarm rate
    spec(i, 1) = 1 - fp(i); % specificity

    % for calculating overlap
    is_sig_matrix(:, i) = t.sig;
    
end

obs_power = sum(is_sig_matrix) ./ ntrue;
[min(obs_power) max(obs_power)] 

% P < .001, N = 30 : power = 17 - 28%

% max number of samples replicating a voxel
num_samples_sig = sum(is_sig_matrix');
max(num_samples_sig)  % 13

% mean number of samples replicating a true voxel
num_samples_sig = sum(is_sig_matrix(istrue, :)');
mean(num_samples_sig)  % 5

% At P < .001 and N = 30, with an effect size of d = 0.5 in 19,532 voxels,
% the average true-positive voxel is significant in only 5/25 or 20% of studies.
% No voxel in the brain is identified by more than 13/25 or about 50% of studies.

%% Save

% cd('/Users/torwager/Documents/GitHub/FMRI_simulations/power')
figsavedir = fullfile(pwd, 'figures');
mkdir(figsavedir)
saveas(gcf, fullfile(figsavedir, 'power_fpr_maps1_p001_n30.svg'))


%% do it without the blue 'true' blobs

o3 = removeblobs(o3);

for i = 1:5*5
      
    subplot(5, 5, i)
    
    o3 = addblobs(o3, r{i}, 'splitcolor', 'wh_montages', i, 'cmaprange', [-2 2]);
    
end

%% Save

saveas(gcf, fullfile(figsavedir, 'power_fpr_maps1_p001_n30_notrueregions.svg'))

