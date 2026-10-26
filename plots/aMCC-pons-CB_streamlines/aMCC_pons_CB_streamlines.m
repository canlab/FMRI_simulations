% aMCC_pons_CB_streamlines.m
%
% Streamline plot of a cortico-ponto-cerebellar pathway:
%   aMCC (anterior midcingulate cortex) -> ventral pons -> cerebellum
%
% Masks come from the CANlab 2024 atlas (load_atlas / select_atlas_subset).
% Streamlines are drawn with nmdsfig_tools('connect3d', ...).
% The cortex is rendered as a medial view of the hires right hemisphere
% surface (addbrain 'hires right', with its cerebellum removed), the SUIT
% cerebellum (addbrain 'cerebellum hires'), and a semi-transparent brainstem
% (addbrain 'brainstem'). The earlier version, which used the cerebellum of
% the hires right surface, is in aMCC_pons_CB_streamlines_hiresright_cblm_backup.m
%
% Regions are painted onto the existing surfaces with CANlab getVertexColors
% (vertices within paint_mm of a region voxel take the region color; existing
% vertex colors are kept, so regions accumulate). An alternative method
% (smoothed masks sampled at vertices by trilinear interpolation) is kept,
% commented out, below. The smooth-isosurface version of this figure is
% aMCC_pons_CB_streamlines_smooth_iso.m
%
% Regions (CANlab 2024 / Glasser HCP-MMP labels):
%   aMCC          : Ctx_a24pr_R                             (right hemisphere)
%   Ventral pons  : BStem_Shen_Pons_Lv, _Rrv, _Rcv, restricted to y > -20 mm
%                   (anterior/basis pontis portion of the ventral parcels)
%   Cerebellum    : Cblm_VI_L, Cblm_Vermis_VI               (dorsal cerebellum,
%                   lobule VI; left side, facing the viewer and contralateral
%                   to the aMCC, as for crossed pontocerebellar fibers)
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
% cb_atl = select_atlas_subset(atl, {'Cblm_VI_R' 'Cblm_Vermis_VI'}, 'exact', 'flatten');  % backup: right lobule VI, on the hires right cerebellum

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
gray_ctx  = [.86 .86 .88];   % cortex underlay
gray_bs   = [.80 .80 .84];   % brainstem underlay

%% Figure and surfaces
fh = create_figure('aMCC_pons_CB_streamlines');
set(fh, 'Color', 'w', 'Position', [100 100 1200 950]);

ctx_h = addbrain('hires right');        % hires right hemi, with cerebellum
set(ctx_h(1), 'FaceColor', gray_ctx, 'FaceAlpha', 1);
remove_cerebellum(ctx_h(1), atl);       % cortex only; cerebellum is the SUIT surface below

ctx_h(2) = addbrain('brainstem');
set(ctx_h(2), 'FaceColor', gray_bs, 'FaceAlpha', .42);  % semi-transparent brainstem

ctx_h(3) = addbrain('cerebellum hires');  % SUIT cerebellum, brainstem removed
set(ctx_h(3), 'FaceColor', gray_ctx, 'FaceAlpha', 1);
hold on

%% Paint regions on the existing surfaces (CANlab getVertexColors)
% Vertices within paint_mm of a region voxel take the region color.
% A truecolor underlay is set first; getVertexColors keeps existing colors.
paint_mm = 2.5;
set(ctx_h(1), 'FaceVertexCData', repmat(gray_ctx, size(ctx_h(1).Vertices, 1), 1), 'FaceColor', 'interp');
set(ctx_h(2), 'FaceVertexCData', repmat(gray_bs,  size(ctx_h(2).Vertices, 1), 1), 'FaceColor', 'interp');
set(ctx_h(3), 'FaceVertexCData', repmat(gray_ctx, size(ctx_h(3).Vertices, 1), 1), 'FaceColor', 'interp');

getVertexColors(amcc_r.XYZmm', ctx_h(1), col_amcc, gray_ctx, paint_mm);
getVertexColors(cb_r.XYZmm',   ctx_h(3), col_cb,   gray_ctx, paint_mm);
% getVertexColors(cb_r.XYZmm', ctx_h(1), col_cb,   gray_ctx, paint_mm);  % backup: hires right cerebellum
getVertexColors(pons_r.XYZmm', ctx_h(2), col_pons, gray_bs,  paint_mm);

% Painted brainstem vertices opaque, the rest semi-transparent
painted = any(abs(ctx_h(2).FaceVertexCData - gray_bs) > 1e-6, 2);
set(ctx_h(2), 'FaceVertexAlphaData', .42 + .58 * painted, 'FaceAlpha', 'interp', 'AlphaDataMapping', 'none');

% Alternative: smoothed masks sampled at vertices (trilinear), sub-voxel edges
% -------------------------------------------------------------------------
% region_colors = [col_amcc; col_pons; col_cb];
% smooth_maps = region_smooth_maps({amcc_r pons_r cb_r}, atl, 3);   % 3 mm FWHM
% vidx_ctx = sample_regions_on_vertices(smooth_maps, ctx_h(1), .35);
% vidx_bs  = sample_regions_on_vertices(smooth_maps, ctx_h(2), .35);
% color_vertices(ctx_h(1), vidx_ctx, region_colors, gray_ctx, 1, 1);
% color_vertices(ctx_h(2), vidx_bs,  region_colors, gray_bs, .42, 1);

%% Streamlines
rng(2024);   % reproducible streamline jitter

% connect3d jitters each streamline by +/- .15 * streamlineshift mm.
% Endpoints: centroid of each region's painted vertices, with x moved just in
% front of the painted surface (camera at -x) so lines are not hidden by it
amcc_xyz = painted_endpoint(ctx_h(1), col_amcc, 3);
pons_xyz = painted_endpoint(ctx_h(2), col_pons, 3);
cb_xyz   = painted_endpoint(ctx_h(3), col_cb, 3);
% cb_xyz = painted_endpoint(ctx_h(1), col_cb, 3);  % backup: hires right cerebellum

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
print(fh, fullfile(outdir, 'aMCC_pons_CB_streamlines.png'), '-dpng', '-r300');
savefig(fh, fullfile(outdir, 'aMCC_pons_CB_streamlines.fig'));

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

function remove_cerebellum(surf_h, atl)
% Delete faces whose vertices all have a cerebellar (Cblm_*) nearest atlas
% label, then keep the largest connected piece (drops leftover fragments)
iscb = contains(atl.labels, 'Cblm');
a = replace_empty(atl);
xyz = a.volInfo.mat * [a.volInfo.xyzlist'; ones(1, size(a.volInfo.xyzlist, 1))];
inatl = a.dat > 0;
[~, nn] = pdist2(xyz(1:3, inatl)', surf_h.Vertices, 'euclidean', 'Smallest', 1);
lab = a.dat(inatl);
vcb = iscb(lab(nn))';
f = surf_h.Faces;
f = f(~all(vcb(f), 2), :);
G = graph([f(:, 1); f(:, 2); f(:, 3)], [f(:, 2); f(:, 3); f(:, 1)], [], size(surf_h.Vertices, 1));
cc = conncomp(simplify(G));
big = mode(cc(unique(f(:))));
set(surf_h, 'Faces', f(all(cc(f) == big, 2), :));
end

function xyz = painted_endpoint(surf_h, color, xoffset)
% Centroid of vertices painted in color; x set just toward the viewer
% (camera at -x) from the nearest painted vertices
v = get(surf_h, 'Vertices');
c = get(surf_h, 'FaceVertexCData');
wh = all(abs(c - color) < 1e-6, 2);
xyz = mean(v(wh, :), 1);
xyz(1) = prctile(v(wh, 1), 5) - xoffset;
end

% Alternative-method helpers (see commented block above)
% -------------------------------------------------------------------------
%{
function smooth_maps = region_smooth_maps(regions, atl, fwhm)
% One Gaussian-smoothed (fwhm, mm) 0-1 map per region, in atlas space
k = numel(regions);
smooth_maps = fmri_data(atl, 'noverbose');
smooth_maps.dat = zeros(size(atl.dat, 1), k);
for i = 1:k
    m = region2fmri_data(regions{i}, smooth_maps);
    m.dat = double(m.dat ~= 0);
    m = resample_space(preprocess(m, 'smooth', fwhm), atl);
    smooth_maps.dat(:, i) = m.dat;
end
end

function vidx = sample_regions_on_vertices(smooth_maps, surf_h, thr)
% Trilinear interpolation of each smoothed map at the surface vertices;
% vertex gets the region with the highest value above thr (0 = none)
v = get(surf_h, 'Vertices');
vol = reconstruct_image(smooth_maps);                      % x by y by z by k
vox = [v ones(size(v, 1), 1)] / smooth_maps.volInfo.mat';  % mm -> voxel coords
vals = zeros(size(v, 1), size(vol, 4));
for i = 1:size(vol, 4)
    % interp3 takes (cols, rows, slices) = (dim 2, dim 1, dim 3)
    vals(:, i) = interp3(vol(:, :, :, i), vox(:, 2), vox(:, 1), vox(:, 3), 'linear', 0);
end
[mx, vidx] = max(vals, [], 2);
vidx(mx <= thr) = 0;
end

function color_vertices(surf_h, vidx, region_colors, base_color, base_alpha, region_alpha)
% Truecolor per-vertex coloring: base color where vidx == 0, region k color
% where vidx == k; painted vertices get their own opacity
nv = numel(vidx);
rgb = repmat(base_color, nv, 1);
alpha = repmat(base_alpha, nv, 1);
for k = 1:size(region_colors, 1)
    rgb(vidx == k, :) = repmat(region_colors(k, :), sum(vidx == k), 1);
    alpha(vidx == k) = region_alpha;
end
set(surf_h, 'FaceVertexCData', rgb, 'FaceColor', 'interp', 'EdgeColor', 'none');
if base_alpha < 1
    set(surf_h, 'FaceVertexAlphaData', alpha, 'FaceAlpha', 'interp', 'AlphaDataMapping', 'none');
end
end
%}
