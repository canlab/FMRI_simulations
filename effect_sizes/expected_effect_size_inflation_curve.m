clear maxdist


n_vox = [1:30 50 100 200:100:1000]; % 1500 2000 2500 3000 3500];
n_vox = [n_vox round(exp(8:12))];  

% Get maxdist, 10,000 samples from the distribution of max Z values across v voxels 
for v = 1:length(n_vox), x = randn(10000, n_vox(v)); maxdist(:, v) = max(x, [], 2); end

z = mean(maxdist);  % Expected max Z (average max Z-score) across i voxels
p = 1 - normcdf(z);

clear d d_inf

n_vals = [10 20 30 100];   % sample sizes

for i = 1:length(n_vals)
    
    n = n_vals(i);     % sample size
    
    t = tinv(1 - p, n);    % t-score for this sample size
    d = t ./ sqrt(n);      % Expected Cohen's d inflation for this sample size
    
    d_inf(:, i) = d';      % Expected inflation
    
end

%%
create_figure;
plot(log(n_vox), d_inf, 'LineWidth', 3);
legend({'n = 10' 'n = 20' 'n = 30' 'n = 100'});

set(gca, 'YLim', [-.2 2.5], 'FontSize', 32, 'XLim', [-.1 12]);
hh = plot_horizontal_line(0); set(hh, 'LineStyle', '--');
xlabel('Log number of tests performed');
ylabel('Effect size inflation (d)');

%% Add lines for num effective comps

%Nichols and Hayasaka 2003:  
%t(19) needs to be 6.5 for low smoothness (high-res, also Bonf threshold), 
% 6 for medium smoothness (6 mm), 5.5 for standard 3T smoothness (8 mm)
% Estimated from simulation figures - approximate ballpark estimates only.
% actual results are data-dependent

thr_bonf = (1 - tcdf(6.5, 19)) ./ 2;
thr_6mm_rft = (1 - tcdf(6, 19)) ./ 2;  % random field, two-tailed (/2)
thr_6mm_perm = (1 - tcdf(5.7, 19)) ./ 2;  % random field, two-tailed (/2)
thr_8mm_rft = (1 - tcdf(5.65, 19)) ./ 2;
thr_8mm_perm = (1 - tcdf(5.5, 19)) ./ 2;

n_bonf = .025 / thr_bonf
n_perm = .025 / thr_6mm_perm
n_rft = .025 / thr_6mm_rft

n_20 = 20;

n_effective_comps = [1 n_20 n_bonf n_perm];
textlabels = {'Single test' '20 ROIs' 'Bonf' 'Perm'};

for j = 1:length(n_effective_comps)
    
    myx = log([n_effective_comps(j) n_effective_comps(j)]);
    plot(myx, [0 2.5], 'Color', [.3 .3 .3], 'LineWidth', 1, 'LineStyle', '--');
    text(log(n_effective_comps(j)), -.1, sprintf('%s', textlabels{j}), 'FontSize', 24, 'Color', [.2 .2 .2]);

end

%%

scn_export_papersetup(600);
saveas(gcf, 'sim2_est_effect_size_inflation.png');


