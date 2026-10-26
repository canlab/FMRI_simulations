% aMCC_pons_CB_streamlines_smooth_iso.m
%
% Smooth-isosurface version of aMCC_pons_CB_streamlines.m.
% Streamline plot of a cortico-ponto-cerebellar pathway:
%   aMCC (anterior midcingulate cortex) -> ventral pons -> cerebellum
%
% Regions are drawn as very smooth, volume-preserving isosurfaces with the
% CANlab region isosurface method's 'smooth' option (Gaussian smoothing +
% cubic upsampling before isosurface extraction at the volume-preserving
% level + Taubin mesh smoothing + exact volume rescaling).
%
% Regions (CANlab 2024 / Glasser HCP-MMP labels):
%   aMCC          : Ctx_a24pr_R                             (right hemisphere)
%   Ventral pons  : BStem_Shen_Pons_Lv, _Rrv, _Rcv, restricted to y > -20 mm
%                   (anterior/basis pontis portion of the ventral parcels)
%   Cerebellum    : Cblm_VI_L, Cblm_Vermis_VI               (dorsal cerebellum,
%                   lobule VI; left side, in front of the right hemisphere
%                   surface in this view, and contralateral to the aMCC, as for
%                   crossed pontocerebellar fibers)
%
% Requires CanlabCore and Neuroimaging_Pattern_Masks on the MATLAB path.

%% Output folder
outdir = fileparts(mfilename('fullpath'));
if isempty(outdir), outdir = pwd; end

%% Load atlas and build region masks
atl = load_atlas('canlab2024');

amcc_atl = select_atlas_subset(atl, {'Ctx_a24pr_R'}, 'exact', 'flatten');
pons_atl = select_atlas_subset(atl, {'BStem_Shen_Pons_Lv' 'BStem_Shen_Pons_Rrv' 'BStem_Shen_Pons_Rcv'}, 'exact', 'flatten');
cb_atl   = select_atlas_subset(atl, {'Cblm_VI_L' 'Cblm_Vermis_VI'}, 'exact', 'flatten');

pons_ycut = -20;     % keep ventral-pons voxels anterior to this y (mm): basis pontis

% Convert to contiguous-blob region objects; keep the largest blob of each
amcc_r = largest_blob(region(fmri_data(amcc_atl)));
pons_r = largest_blob(region(mask_y_greater_than(fmri_data(pons_atl), pons_ycut)));
cb_r   = largest_blob(region(fmri_data(cb_atl)));

%% Colors: a red/orange family
col_amcc  = [1 .25 .05];     % red-orange
col_pons  = [1 .45 .05];     % orange
col_cb    = [.95 .15 .05];   % red
col_line1 = [1 .30 0];       % aMCC -> pons streamlines
col_line2 = [1 .45 0];       % pons -> cerebellum streamlines

%% Figure and surfaces
fh = create_figure('aMCC_pons_CB_streamlines_smooth_iso');
set(fh, 'Color', 'w', 'Position', [100 100 1200 950]);

ctx_h = addbrain('hires right');        % hires right hemi, with cerebellum
set(ctx_h(1), 'FaceColor', [.86 .86 .88], 'FaceAlpha', 1);

ctx_h(2) = addbrain('brainstem');
set(ctx_h(2), 'FaceColor', [.80 .80 .84], 'FaceAlpha', .42);  % semi-transparent brainstem
hold on

%% Smooth, volume-preserving region isosurfaces (CANlab region/isosurface 'smooth')
iso_opts = {'nomatchleftright', 'smooth'};
h_amcc = isosurface(amcc_r, 'colors', {col_amcc}, iso_opts{:});
h_pons = isosurface(pons_r, 'colors', {col_pons}, iso_opts{:});
h_cb   = isosurface(cb_r,   'colors', {col_cb},   iso_opts{:});

% The pons lies just inside the brainstem surface (SPM2 template surface vs.
% MNI152NLin2009cAsym atlas): open a more transparent window in the brainstem
% over the pons so the pons color is not washed out
d = pdist2(pons_r.XYZmm', ctx_h(2).Vertices, 'euclidean', 'Smallest', 1)';
set(ctx_h(2), 'FaceVertexAlphaData', .42 - .3 * (d < 6), 'FaceAlpha', 'interp', 'AlphaDataMapping', 'none');

%% Streamlines
rng(2024);   % reproducible streamline jitter

% connect3d jitters each streamline by +/- .15 * streamlineshift mm.
% Endpoints: region centers, with x moved toward the viewer (camera at -x)
% so the lines run in front of the medial wall instead of inside the cortex
amcc_xyz = amcc_r.mm_center; amcc_xyz(1) = -4;
pons_xyz = pons_r.mm_center; pons_xyz(1) = -6;
cb_xyz   = cb_r.mm_center;

out1 = nmdsfig_tools('connect3d', amcc_xyz, pons_xyz, 'color', col_line1, ...
    'thickness', 1.5, 'bendpercent', [0 -.6 .1], 'nstreamlines', 42, 'streamlineshift', 30);

out2 = nmdsfig_tools('connect3d', pons_xyz, cb_xyz, 'color', col_line2, ...
    'thickness', 1.75, 'bendpercent', [0 .3 -.35], 'nstreamlines', 42, 'streamlineshift', 25);

%% View and lighting: medial view of the right hemisphere (camera at -x)
view(255, 12);       % slightly oblique, from front-left and above
axis image; axis off;
lighting gouraud; material dull;
lightRestoreSingle(gca);
camzoom(1.35);

%% Save
print(fh, fullfile(outdir, 'aMCC_pons_CB_streamlines_smooth_iso.png'), '-dpng', '-r300');
savefig(fh, fullfile(outdir, 'aMCC_pons_CB_streamlines_smooth_iso.fig'));

%% ------------------------------------------------------------------------
function r = largest_blob(r)
% Keep the region (contiguous cluster) with the most voxels
nvox = arrayfun(@(x) size(x.XYZ, 2), r);
[~, wh] = max(nvox);
r = r(wh);
end

function m = mask_y_greater_than(m, ycut)
% Zero voxels with y (mm) <= ycut
m = replace_empty(m);
xyz = m.volInfo.mat * [m.volInfo.xyzlist'; ones(1, size(m.volInfo.xyzlist, 1))];
m.dat(xyz(2, :)' <= ycut, :) = 0;
end
