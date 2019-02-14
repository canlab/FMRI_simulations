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
face_obj = sim_data(fmri_data, 'n', N, 'd', 1, 'smoothness', 10, 'true_region_mask', true_mask);

% house obj has d = 0 in all regions
house_obj = sim_data(fmri_data, 'n', N, 'null', 'smoothness', 10, 'true_region_mask', true_mask);

% create Face - House difference images to select on
facevshouse = face_obj;
facevshouse.dat = face_obj.dat - house_obj.dat;

t = ttest(facevshouse);

t = threshold(t, .001, 'unc');

% create region and extract data
reg = region(t);

reg = reg(cat(1, reg.numVox) > 50);  % save largest only
reg_face = extract_data(reg, face_obj);
reg_house = extract_data(reg, house_obj);

montage(reg, 'regioncenters', 'colormap');

%% Save

cd('/Users/torwager/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
figsavedir = fullfile(pwd, 'figures');
saveas(gcf, fullfile(figsavedir, 'lie5_regions.png'))

%% Plot

wh = 5; % picked by hand - FFA area

create_figure('bars', 1, 2); 

barplot_columns([0.5 0.001], 'nofigure', 'noviolin', 'noind', 'colors', {[.5 .5 .7] [.4 .7 .2]}, 'names', {'Faces' 'Houses'}, 'nostars');
ylabel('True activity');
xlabel('');
set(gca, 'YLim', [-.5 1.2], 'FontSize', 24)

subplot(1, 2, 2)

barplot_columns([reg_face(wh).dat reg_house(wh).dat], 'nofigure', 'noviolin', 'noind', 'colors', {[.5 .5 .7] [.4 .7 .2]}, 'names', {'Faces' 'Houses'});
ylabel('Observed activity');
xlabel('');
set(gca, 'YLim', [-.5 1.2], 'FontSize', 24)


%% Save

cd('/Users/torwager/Documents/GitHub/FMRI_simulations/Principles_of_fMRI_statistical_lies')
saveas(gcf, fullfile(figsavedir, 'lie5_facehousebar.png'))

