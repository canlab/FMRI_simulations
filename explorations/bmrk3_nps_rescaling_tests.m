dat = load_image_set('bmrk3');
[group_metrics individual_metrics values gwcsf gwcsfmean gwcsfl2norm] = qc_metrics_second_level(dat);

nps = apply_nps(dat);
pain = dat.Y;

%%
X = [values gwcsfl2norm];
names = {'Gray' 'White' 'CSF' 'Grayl2norm' 'WhiteL2norm' 'CSFl2norm'};


plot_correlation_matrix([X nps{1} pain], 'names', [names {'nps' 'pain'}]);

[w, pcascores, latent] = pca(gwcsfl2norm); % l2 norms are highly correlated across tissue compartments: extract first common component
pcascores = pcascores(:, 1);            

X2 = [values pcascores(:, 1)];
names2 = {'Gray' 'White' 'CSF' 'Imgl2norm'};

plot_correlation_matrix([X2 nps{1} pain], 'names', [names2 {'nps' 'pain'}]);

%%
disp(' ')
disp('Predicting NPS from large-scale image metrics');

[b dev stat] = glmfit(X2, nps{1});
glm_table(stat, names2, b);

disp(' ')
disp('Predicting pain from large-scale image metrics');

[b dev stat] = glmfit(X2, pain);
glm_table(stat, names2, b);


% Both NPS and pain are related to higher Imgl2norm and more activation in
% CSF compartment (though effect is much weaker for pain)
%
% NPS, but not pain, is related to average CSF compartment activity
% Suggests that regressing mean gray matter out of NPS scores may improve
% NPS->pain relationship
%

%%
disp(' ')
disp('Predicting pain from NPS alone');

[b dev stat] = glmfit(nps{1}, pain);
glm_table(stat, {'NPS'}, b);

disp(' ')
disp('Predicting pain from NPS and gray matter alone');

[b dev stat] = glmfit([nps{1} X2(:, 1)], pain);
glm_table(stat, {'NPS' 'Gray mean'}, b);

disp(' ')
disp('Predicting pain from NPS and all large-scale imaging metrics');

[b dev stat] = glmfit([nps{1} X2], pain);
glm_table(stat, [{'NPS'} names2], b);

disp(' ')
disp('Remove non-sig predictors (step down)')
disp('Predicting pain from NPS and l2norm');

[b dev stat] = glmfit([nps{1} pcascores(:, 1)], pain);
glm_table(stat, [{'NPS'} names2([4])], b);


create_figure('fits', 1, 3)
plot(nps{1}, pain, 'ko'); xlabel('nps'); ylabel('pain'); refline
subplot(1, 3, 2)
plot(pcascores(:, 1), pain, 'ko'); xlabel('imgl2norm'); ylabel('pain'); refline
subplot(1, 3, 3)
fit = [nps{1} pcascores(:, 1)] * b(2:3) + b(1);
plot(fit, pain, 'ko'); xlabel('predicted'); ylabel('pain');


% NPS and l2norm are both independently related to pain, though they are
% related to one another.
% A joint model is more predictive!  
% Relationships are nonlinear, however, and there are outliers in this bmrk3 dataset (see below)

% Alternatives:
% NPS could fit at the low end, and signal become more distributed (l2norm)
% at high end -> try segmented piecewise models
% nonlinear (e.g., polynomial) regression
% * no, what's actually happening here is that 0-100 pain is non-painful,
% and 100-200 is painful. So we need to consider this and look at painful
% range. 
% 
%% Normalized NPS:  NPS / l2norm

disp('Getting average l2 norm (positive-valued for normalization');
meanl2norm = mean(gwcsfl2norm, 2);
corr([meanl2norm, pcascores])

normnps = nps{1} ./ (1 + meanl2norm);  % add 1 to avoid scaling issues with values < 1, or this will be a nonmonotonic transformation.

disp(' ')
disp('Predicting pain from normalized NPS alone');

[b dev stat] = glmfit(normnps, pain);
glm_table(stat, {'NPS'}, b);

figure; plotmatrix([nps{1}, normnps, nps{1}./meanl2norm meanl2norm pain]);

% Normalizing NPS doesn't help a ton. 
% Also: relationships are nonlinear, such that l2norm increases mainly at
% the high end of pain. This could be related to global transmitter
% activity or head movement for the most painful trials.

%% Spatial regression NPS: remove gray, white CSF spatially

%% Prep masks
% Load, resample to data space, and threshold

masks = {'gray_matter_mask_sparse.img' 'canonical_white_matter.img' 'canonical_ventricles.img'};
for i = 1:3, masks{i} = which(masks{i}); end
maskobj = fmri_data(masks);

maskobj = resample_space(maskobj, dat);
maskobj.dat = single(maskobj.dat > 0.5);
orthviews(maskobj);

npsobj = resample_space(npsobj, dat);
orthviews(npsobj);

% Replace empty (full voxel list)
dat = replace_empty(dat);

spatialX = double([ones(size(npsobj.dat)) npsobj.dat maskobj.dat ]); % careful: something really weird happens with single format, use double!!
spatialX_names = {'intercept' 'npsbeta' 'gray' 'white' 'csf'};

% Maps are uncorrelated
corr(spatialX)

plot_correlation_matrix(spatialX, 'names', spatialX_names);

pX = pinv(double(spatialX));

%% Estimate pattern mask as regression slope

pexp = (pX * dat.dat)';  % pattern response values (with intercept)

figure; plotmatrix([pexp nps{1} pain]);

plot_correlation_matrix([pexp nps{1} pain], 'names', [spatialX_names {'nps' 'pain'}]);

% NPS and npsbeta activation betas are nearly perfectly correlated in BMRK3
% This makes sense given that regressors are nearly perfectly orthogonal

disp(' ')
disp('Predicting pain from NPSbeta alone');
npsbeta = pexp(:, 2);
[b dev stat] = glmfit(npsbeta, pain);
glm_table(stat, {'NPSbeta'}, b);


disp(' ')
disp('Predicting pain from NPSbeta and all large-scale imaging metrics, except intercept beta');

[b dev stat] = glmfit(pexp(:, 2:end), pain);
glm_table(stat, spatialX_names(2:end), b);

% Plot fits for original NPS and NPSbeta 
figure; plot(npsbeta, pain, 'bo', 'LineWidth', 2);
hold on; plot(nps{1}, pain, 'ro', 'LineWidth', 2);
xlabel('NPS'); ylabel('pain');
legend({'spatial NPSbeta' 'Original NPS'});

% doesn't seem to help a ton, but it may actually if we look more carefully
% at pain-range scores (bmrk3 only)

wh = pain > 100;
disp('NPS original correlation with pain in painful range, across all obj (including inter-subject variability)')
corr(nps{1}(wh), pain(wh))

disp('NPS spatial beta correlation with pain in painful range')
corr(npsbeta(wh), pain(wh))

% Plot fits for original NPS and NPSbeta 
figure; plot(npsbeta(wh), pain(wh), 'bo', 'LineWidth', 2); 
hold on; plot(nps{1}(wh), pain(wh), 'ro', 'LineWidth', 2);
xlabel('NPS'); ylabel('pain');
legend({'spatial NPSbeta' 'Original NPS'});
refline


%% Alternative: standardize variables (including Y, dat images) and estimate
% partial correlations
% may not help much though, as l2norm does track pain?

