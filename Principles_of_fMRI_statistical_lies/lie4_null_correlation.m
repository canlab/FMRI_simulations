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

% vector to matrix correlation formula - anonymous function. 
% a is an N x 1 vector, b is an N x k matrix
% corr_matrix = @(a, b) ((a-mean(a))' * (b-mean(b)) ./ (length(a) - 1))' ./ (std(a)*std(b)');
% This is stored in obj below, created by sim_data

%% Simulated data

[obj, true_obj, noise_obj] = sim_data(fmri_data, 'n', N, 'null', 'smoothness', 10);

% Display true signal - which is blank. No results
% montage(mean(true_obj), 'compact2');

% display info
obj.additional_info{1}
obj.additional_info{2}

% Observed correlations - object

corr_matrix = obj.additional_info{1}.corr_matrix; % Function handle to get vector-with-matrix correlation
r = corr_matrix(obj.Y, obj.dat');

r_obj = mean(obj);
r_obj.dat = r;

% T and P-values

r2t = @(r, n) r .* sqrt((n - 2) ./ (1 - r.^2));
t2p = @(t, n) 2 .* (1 - tcdf(abs(t), n - 2));

t = r2t(r, N);
p = t2p(t, N);

r_obj = statistic_image('volInfo', obj.volInfo, 'p', p, 'dat', r, 'type', 'r');

r_obj = threshold(r_obj, .005, 'unc');

% create region and extract data
reg = region(r_obj);
reg = extract_data(reg, obj);

% find largest-correlation positive cluster
rr = corr_matrix(obj.Y, cat(2, reg.dat)); % correlations for each
[rr, wh] = max(rr);

create_figure('scatter', 1, 2); 

o2 = fmridisplay;
o2 = montage(o2, 'axial', 'wh_slice', reg(wh).mm_center, 'onerow', 'existing_axes', gca);
% o2 = addblobs(o2, reg(wh));
o2 = addblobs(o2, reg);     % add all

subplot(1, 2, 2);
set(gca, 'FontSize', 24)
plot(obj.Y, reg(wh).dat, 'o', 'Color', [0 0 .5], 'MarkerFaceColor', 'b'); 
refline
text(1, 1, sprintf('r = %3.2f', rr), 'FontSize', 24);
xlabel('Behavior');
ylabel('Brain activity');

%% Save

cd('/Users/torwager/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
figsavedir = fullfile(pwd, 'figures');
% mkdir(figsavedir)
saveas(gcf, fullfile(figsavedir, 'lie4_example2.png'))

%% Distribution

N_vals = [10 20 40 100];
niter = 50;

[rmax, n_above_50, n_above_70] = deal(zeros(niter, length(N_vals)));

tmp_obj = fmri_data;
true_obj = load_image_set('bucknerlab');    % irrelevant for null, but saves time in loading
true_obj = get_wh_image(true_obj, 6);       % 'Frontoparietal'
true_obj = resample_space(true_obj, tmp_obj);
    
for i = 1:length(N_vals)
    
    N = N_vals(i);
    
    for j = 1:niter
        
        obj = sim_data(tmp_obj, 'n', N, 'null', 'smoothness', 10, 'true_region_mask', true_obj);
        
        rmax(j, i) = max(obj.additional_info{2}.r_obs);
        
        n_above_50(j, i) = sum(obj.additional_info{2}.r_obs > .5);
        
        n_above_70(j, i) = sum(obj.additional_info{2}.r_obs > .7);
        
    end
    
end

% save(fullfile(figsavedir, 'lie4_sim_data.mat'), 'N_vals', 'rmax', 'n_above*')

%% Graphs

create_figure('line plots', 2, 1)

barplot_columns(rmax, 'nofigure', 'line', 'x', N_vals, 'colors', [.7 .2 .2], 'nostars')
set(gca, 'XTick', N_vals, 'XLim', [5 105], 'FontSize', 24);
ylabel('Max correlation');
xlabel('Sample size');

subplot(2, 1, 2)

barplot_columns(n_above_50, 'nofigure', 'line', 'x', N_vals, 'colors', [.2 .7 .2], 'nostars', 'noviolin', 'noind')
barplot_columns(n_above_70, 'nofigure', 'line', 'x', N_vals, 'colors', [.3 .5 .3], 'nostars', 'noviolin', 'noind')
set(gca, 'XTick', N_vals, 'XLim', [5 105], 'FontSize', 24);
ylabel('Number of voxels');
xlabel('Sample size');


%% Save 
cd('/Users/torwager/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
figsavedir = fullfile(pwd, 'figures');
% mkdir(figsavedir)
saveas(gcf, fullfile(figsavedir, 'lie4_False_Positive_Correlations.svg'))


