% cerebellum_flatten_movie.m
%
% Follow-on to cerebellum_zoom_movie.m. Starts from that movie's last frame
% (opaque cerebellum, top-down view), then inflates and unfolds the
% cerebellum into the SUIT flat map, ending in the style of
% suit_plotflatmap / CANlab render_on_cerebellar_flatmap (gray SUIT.shape
% underlay, flat shading, fissure borders).
%
% Steps:
%   1. Cross-fade from the CANlab 'cerebellum hires' surface to the SUIT pial
%      surface (PIAL_SPM.coord.gii; the SUIT pial, inflated and flat surfaces
%      share vertices, so the rest is a vertex-wise morph)
%   2. Morph pial -> inflated (INFLATED.coord.gii)
%   3. Morph inflated -> flat (FLAT.coord.gii, CUT.topo.gii), while the color
%      turns to the SUIT.shape underlay and the lighting turns to flat shading
%   4. Fade in the fissure borders (fissures_flat.mat)
%
% Saves cerebellum_flatten_movie.mp4 (30 fps) in this folder.
% Requires CanlabCore and the SUIT toolbox (spm/toolbox/suit) on the path.

%% Output folder
outdir = fileparts(mfilename('fullpath'));
if isempty(outdir), outdir = pwd; end

%% SUIT flat map files
flat_dir = fullfile(fileparts(which('suit_plotflatmap')), 'flatmap');
if ~isfolder(flat_dir), error('Add the SUIT toolbox to the path (suit_plotflatmap)'); end

faces = double(getfield(gifti(fullfile(flat_dir, 'CUT.topo.gii')), 'faces'));
v_pial = double(getfield(gifti(fullfile(flat_dir, 'PIAL_SPM.coord.gii')), 'vertices'));
v_infl = double(getfield(gifti(fullfile(flat_dir, 'INFLATED.coord.gii')), 'vertices'));
v_flat = double(getfield(gifti(fullfile(flat_dir, 'FLAT.coord.gii')), 'vertices'));
shape  = double(getfield(gifti(fullfile(flat_dir, 'SUIT.shape.gii')), 'cdata'));
load(fullfile(flat_dir, 'fissures_flat.mat'), 'Border');

% Put inflated and flat surfaces at the pial centroid so the camera can stay put
c_pial = mean(v_pial, 1);
v_infl = v_infl - mean(v_infl, 1) + c_pial;
flat_shift = c_pial - mean(v_flat, 1);   % also applied to the fissure borders
v_flat = v_flat + flat_shift;

% Underlay colors as in suit_plotflatmap (gray colormap, scale [-1 .5])
undermap = gray(256);
k = min(max(ceil((shape(:, 1) + 1) / 1.5 * 256), 1), 256);
col_under = undermap(k, :);

%% Rebuild the end frame of cerebellum_zoom_movie.m
create_figure; addbrain('cerebellum hires'); h = ans; h = [h addbrain('surface right')];
delete(h(3))
h(3) = addbrain('brainstem');
set(h(3), 'FaceColor', [0.5 .5 .5]);

fh = gcf; ax = gca;
set(fh, 'Color', 'w', 'Position', [100 100 1000 800]);
axis(ax, 'image', 'off'); axis(ax, 'vis3d');
lighting(ax, 'gouraud'); material(ax, 'dull');

view(ax, 270, 0);                 % same camera setup as the zoom movie
d = norm(campos(ax) - camtarget(ax));
cb_v = h(1).Vertices;
target1 = (min(cb_v) + max(cb_v)) / 2;
r1 = .5 * max(max(cb_v(:, 1:2)) - min(cb_v(:, 1:2)));
va1 = 2 * atand(.85 * r1 / d);

delete(h(2:3)); h = h(1);
cb_color = get(h, 'FaceColor');
set(h, 'FaceAlpha', 1);

set(ax, 'CameraPositionMode', 'manual', 'CameraTargetMode', 'manual', ...
    'CameraViewAngleMode', 'manual', 'CameraUpVectorMode', 'manual');
set_camera(ax, 360, 90, target1, d, va1);
hl = camlight(ax, 'headlight');

% Camera end state: frame the flat map (top-down, anterior up as in suit_plotflatmap)
ext = max(v_flat(:, 1:2)) - min(v_flat(:, 1:2));     % [width height] of the flat map
r_flat = .5 * max(ext(2), ext(1) * 1024 / 1280);     % view angle spans the frame height (5:4 frame)
va_end = 2 * atand(1.06 * r_flat / d);

%% SUIT surface (starts invisible, in the cerebellum color) and fissure borders
hs = patch(ax, 'Faces', faces, 'Vertices', v_pial, 'FaceVertexCData', repmat(cb_color, size(v_pial, 1), 1), ...
    'FaceColor', 'interp', 'EdgeColor', 'none', 'FaceAlpha', 0, ...
    'AmbientStrength', .3, 'DiffuseStrength', .6, 'SpecularStrength', .1);

bxy = cell2mat(arrayfun(@(b) b.data(:, 1:2), Border(:), 'UniformOutput', false));
bxy = bxy + flat_shift(1:2);
hb = scatter3(ax, bxy(:, 1), bxy(:, 2), repmat(c_pial(3) + 1, size(bxy, 1), 1), 10, 'k', 'filled', ...
    'MarkerFaceAlpha', 0, 'MarkerEdgeColor', 'none');

%% Timeline (frames at 30 fps)
fps = 30;
movie_size = [1024 1280];         % [height width], multiples of 16 (MPEG-4 on macOS)
seg = struct('name', {'hold0', 'xfade', 'inflate', 'flatten', 'borders', 'hold1'}, ...
             'n',    { 6,       12,      36,        48,        12,        12});

vw = VideoWriter(fullfile(outdir, 'cerebellum_flatten_movie.mp4'), 'MPEG-4');
vw.FrameRate = fps;
vw.Quality = 95;
open(vw);

smooth01 = @(t) t.^2 .* (3 - 2 * t);
for si = 1:numel(seg)
    for j = 1:seg(si).n
        s = smooth01(j / seg(si).n);
        switch seg(si).name
            case 'xfade'
                set(h, 'FaceAlpha', 1 - s);
                set(hs, 'FaceAlpha', s);
                if j == seg(si).n, set(h, 'Visible', 'off'); end

            case 'inflate'
                set(hs, 'Vertices', (1 - s) * v_pial + s * v_infl, ...
                    'FaceVertexCData', (1 - s) * cb_color + s * (.5 * cb_color + .5 * col_under));
                set_camera(ax, 360, 90, target1 + s * (c_pial - target1), d, va1);

            case 'flatten'
                set(hs, 'Vertices', (1 - s) * v_infl + s * v_flat, ...
                    'FaceVertexCData', (1 - s) * (.5 * cb_color + .5 * col_under) + s * col_under, ...
                    'AmbientStrength', .3 + .7 * s, 'DiffuseStrength', .6 * (1 - s), 'SpecularStrength', .1 * (1 - s));
                set_camera(ax, 360, 90, c_pial, d, va1 + s * (va_end - va1));

            case 'borders'
                set(hb, 'MarkerFaceAlpha', s);
        end
        camlight(hl, 'headlight');
        drawnow;
        frame = getframe(fh);
        writeVideo(vw, imresize(frame.cdata, movie_size));
    end
end
close(vw);

%% ------------------------------------------------------------------------
function set_camera(ax, az, el, target, d, va)
% Camera at azimuth/elevation (degrees, as in view()) around target, distance d.
% The up vector is the elevation tangent, so the top-down view stays defined.
dir = [cosd(el) * sind(az), -cosd(el) * cosd(az), sind(el)];
up  = [-sind(el) * sind(az), sind(el) * cosd(az), cosd(el)];
set(ax, 'CameraTarget', target, 'CameraPosition', target + d * dir, ...
    'CameraUpVector', up, 'CameraViewAngle', va);
end
