% aMCC_pons_CB_streamlines.m
%
% Streamline plot of a cortico-ponto-cerebellar pathway:
%   aMCC (anterior midcingulate cortex) -> ventral pons -> cerebellum
%
% Masks come from the CANlab 2024 atlas (load_atlas / select_atlas_subset).
% Streamlines are drawn with nmdsfig_tools('connect3d', ...).
% The cortex is rendered as a medial view of the HCP pial surface
% (addbrain 'surface right') with a semi-transparent brainstem/cerebellum.
%
% Regions (CANlab 2024 / Glasser HCP-MMP labels):
%   aMCC          : Ctx_a24pr_R, Ctx_a32pr_R, Ctx_p32pr_R   (right hemisphere)
%   Ventral pons  : BStem_Shen_Pons_Lv, _Rrv, _Rcv          (bilateral)
%   Cerebellum    : Cblm_CrusI_L, Cblm_CrusII_L             (left; corticopontine
%                   fibers are ipsilateral, pontocerebellar fibers cross)
%
% Requires CanlabCore and Neuroimaging_Pattern_Masks on the MATLAB path.

%% Output folder
outdir = fileparts(mfilename('fullpath'));
if isempty(outdir), outdir = pwd; end

%% Load atlas and build region masks
atl = load_atlas('canlab2024');

amcc_atl = select_atlas_subset(atl, {'Ctx_a24pr_R' 'Ctx_a32pr_R' 'Ctx_p32pr_R'}, 'exact', 'flatten');
pons_atl = select_atlas_subset(atl, {'BStem_Shen_Pons_Lv' 'BStem_Shen_Pons_Rrv' 'BStem_Shen_Pons_Rcv'}, 'exact', 'flatten');
cb_atl   = select_atlas_subset(atl, {'Cblm_CrusI_L' 'Cblm_CrusII_L'}, 'exact', 'flatten');

% Convert to contiguous-blob region objects; keep the largest blob of each
amcc_r = largest_blob(region(fmri_data(amcc_atl)));
pons_r = largest_blob(region(fmri_data(pons_atl)));
cb_r   = largest_blob(region(fmri_data(cb_atl)));

%% Colors: a red/orange family
col_amcc  = [1 .25 .05];     % red-orange
col_pons  = [1 .45 .05];     % orange
col_cb    = [.95 .15 .05];   % red
col_line1 = [1 .30 0];       % aMCC -> pons streamlines
col_line2 = [1 .45 0];       % pons -> cerebellum streamlines

%% Figure and surfaces
fh = create_figure('aMCC_pons_CB_streamlines');
set(fh, 'Color', 'w', 'Position', [100 100 1200 950]);

ctx_h = addbrain('hires right');        % HCP pial right hemi + SUIT brainstem/cerebellum
set(ctx_h(1), 'FaceColor', [.86 .86 .88], 'FaceAlpha', 1);

ctx_h(2) = addbrain('brainstem');
set(ctx_h(2), 'FaceColor', [.80 .80 .84], 'FaceAlpha', .42);  % semi-transparent brainstem/cblm
hold on

%% Region isosurfaces
iso_opts = {'nomatchleftright'};
h_amcc = isosurface(amcc_r, 'colors', {col_amcc}, iso_opts{:});
h_pons = isosurface(pons_r, 'colors', {col_pons}, iso_opts{:});
h_cb   = isosurface(cb_r,   'colors', {col_cb},   iso_opts{:});
region_h = [h_amcc(:); h_pons(:); h_cb(:)];
set(region_h, 'FaceAlpha', 1, 'EdgeColor', 'none');

%% Streamlines
rng(2024);   % reproducible streamline jitter

% connect3d jitters each streamline by +/- .15 * streamlineshift mm.
% Endpoints: region centers, with x moved toward the viewer (camera at -x)
% so the lines run in front of the medial wall instead of inside the cortex
amcc_xyz = amcc_r.mm_center; amcc_xyz(1) = -4;
pons_xyz = pons_r.mm_center; pons_xyz(1) = -6;
cb_xyz   = cb_r.mm_center;

out1 = nmdsfig_tools('connect3d', amcc_xyz, pons_xyz, 'color', col_line1, ...
    'thickness', 1.5, 'bendpercent', [0 -.6 .1], 'nstreamlines', 60, 'streamlineshift', 30);

out2 = nmdsfig_tools('connect3d', pons_xyz, cb_xyz, 'color', col_line2, ...
    'thickness', 1.75, 'bendpercent', [0 .3 -.35], 'nstreamlines', 60, 'streamlineshift', 25);

%% View and lighting: medial view of the right hemisphere (camera at -x)
view(255, 12);       % slightly oblique, from front-left and above
axis image; axis off;
lighting gouraud; material dull;
lightRestoreSingle(gca);
set(region_h, 'AmbientStrength', .35, 'DiffuseStrength', .55, ...
    'SpecularStrength', .25, 'SpecularExponent', 10);

%% Save
print(fh, fullfile(outdir, 'aMCC_pons_CB_streamlines.png'), '-dpng', '-r300');
savefig(fh, fullfile(outdir, 'aMCC_pons_CB_streamlines.fig'));

%% ------------------------------------------------------------------------
function r = largest_blob(r)
% Keep the region (contiguous cluster) with the most voxels
nvox = arrayfun(@(x) size(x.XYZ, 2), r);
[~, wh] = max(nvox);
r = r(wh);
end
