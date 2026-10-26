% cerebellum_zoom_movie.m
%
% ~2 s movie: starts with the left side of the brain facing the camera,
% rotates to a top-down view while zooming in on the cerebellum. At the same
% time the cerebellum becomes opaque and the cortex and brainstem fade out,
% ending with only the opaque cerebellum visible.
%
% Objects: SUIT cerebellum (addbrain 'cerebellum hires'), right cortical
% surface (addbrain 'surface right'), and brainstem (addbrain 'brainstem').
%
% Saves cerebellum_zoom_movie.mp4 (30 fps) in this folder.
% Requires CanlabCore on the MATLAB path.

%% Output folder
outdir = fileparts(mfilename('fullpath'));
if isempty(outdir), outdir = pwd; end

%% Objects (user's starting code)
create_figure; addbrain('cerebellum hires'); h = ans; h = [h addbrain('surface right')];
delete(h(3))
h(3) = addbrain('brainstem');
set(h(3), 'FaceColor', [0.5 .5 .5]);

fh = gcf; ax = gca;
set(fh, 'Color', 'w', 'Position', [100 100 1000 800]);
axis(ax, 'image', 'off'); axis(ax, 'vis3d');
lighting(ax, 'gouraud'); material(ax, 'dull');

%% Movie parameters
fps = 30;
movie_size = [1024 1280];         % [height width], multiples of 16; matches the 5:4 figure
nhold_start = 6;                  % static frames at start and end
nmove = 48;                       % transition frames
nhold_end = 6;

az = [270 360];                   % left side facing camera -> top-down (anterior up)
el = [0 90];
alpha_cb  = [.3 1];               % cerebellum fades in
alpha_ctx = [.3 0];               % cortex and brainstem fade out
alpha_bs  = [.3 0];

% Camera: start framing the whole brain, end framing the cerebellum
view(ax, az(1), el(1));
target0 = camtarget(ax);
va0 = camva(ax);
d = norm(campos(ax) - target0);   % fixed camera distance; zoom by view angle

cb_v = h(1).Vertices;
target1 = (min(cb_v) + max(cb_v)) / 2;
r1 = .5 * max(max(cb_v(:, 1:2)) - min(cb_v(:, 1:2)));  % half-extent in the top-down view
va1 = 2 * atand(.85 * r1 / d);

set(ax, 'CameraPositionMode', 'manual', 'CameraTargetMode', 'manual', ...
    'CameraViewAngleMode', 'manual', 'CameraUpVectorMode', 'manual');
hl = camlight(ax, 'headlight');

%% Render frames
vw = VideoWriter(fullfile(outdir, 'cerebellum_zoom_movie.mp4'), 'MPEG-4');
vw.FrameRate = fps;
vw.Quality = 95;
open(vw);

t = [zeros(1, nhold_start), linspace(0, 1, nmove), ones(1, nhold_end)];
for k = 1:numel(t)
    s = t(k)^2 * (3 - 2 * t(k));          % ease in/out (smoothstep)
    lerp = @(x) x(1) + s * (x(2) - x(1));

    set_camera(ax, lerp(az), lerp(el), target0 + s * (target1 - target0), d, lerp([va0 va1]));
    camlight(hl, 'headlight');

    set(h(1), 'FaceAlpha', lerp(alpha_cb));
    set(h(2), 'FaceAlpha', lerp(alpha_ctx));
    set(h(3), 'FaceAlpha', lerp(alpha_bs));
    set(h(2:3), 'Visible', s < 1);        % last frames: cerebellum only

    drawnow;
    frame = getframe(fh);
    % MPEG-4 on macOS needs frame sizes in multiples of 16 (otherwise rows shear)
    writeVideo(vw, imresize(frame.cdata, movie_size));
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
