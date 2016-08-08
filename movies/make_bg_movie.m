% Load objects
% ------------------------------------------------------------

[obj, netnames, imagenames] = load_image_set('pauli');
[obj_cortex] = load_image_set('pauli_cortex');
obj_cortex = threshold(obj_cortex, [90 Inf], 'raw-between');

% BG Names
% ------------------------------------------------------------
netnames = {'Cp' 'Pa' 'Ca' 'VS' 'PP'};
colors = {[.2 1 .2] [.3 1 1] [.3 .3 1] [1 .3 1] [1 .3 .3]};

f1 = create_figure('surf');

pp = addbrain('bg');
set(pp, 'FaceColor', [.5 .5 .5], 'FaceAlpha', .9);
lighting gouraud; %lightRestoreSingle; brighten(.3)

pp = [pp addbrain('brainstem')];


%%
ovlname = 'keuken_2014_enhanced_for_underlay';

ycut_mm = -30;
coords = [0 ycut_mm 0];
coords = [0 0 20];

anat = fmri_data(which('keuken_2014_enhanced_for_underlay.img'));

p = isosurface(anat, 'thresh', 140, 'nosmooth', 'zlim', [-Inf 20]);
delete(p)

%%
view(223, 20);
colormap gray;
brighten(.5);
set(p, 'FaceAlpha', 1);

hh = findobj(gcf, 'Type', 'Light')
delete(hh)
lightRestoreSingle;

drawnow

%% ASCENDING SLICE SEQUENCE
% -------------------------------------------------------------------------

cla
mov = movie_tools('still', [], .5);

zvals = [-60:5:80];

for i = 1:length(zvals)
    
    delete(p)
    
    p = isosurface(anat, 'thresh', 140, 'nosmooth', 'zlim', [-Inf zvals(i)]);
    
    set(gca, 'ZLim', [-60 80]);
    
    hh = findobj(gcf, 'Type', 'Light');
    delete(hh)
    lightRestoreSingle;
    
    drawnow
    
    mov(end+1) = getframe(f1);
    mov(end+1) = getframe(f1);
    
end

mov = movie_tools('transparent', .3, 1, p, mov, 1);

movascending = mov;

%% WRITE ASCENDING ONLY

vid = VideoWriter('Brain_Ascending_Slices.avi');
open(vid)
for i = 1:length(mov), writeVideo(vid, mov(i)); end
close(vid)

%% Prep for descending BG reveal
% run this and delete pl to start over
% view(223, 20);
% delete(pl);
% lightRestoreSingle
% axis off

pp = addbrain('bg');
lighting gouraud;
set(pp, 'FaceColor', [.5 .5 .5], 'FaceAlpha', 1);

delete(p)
pr = isosurface(anat, 'thresh', 140, 'nosmooth', 'xlim', [0 Inf]); drawnow
pl = isosurface(anat, 'thresh', 140, 'nosmooth', 'xlim', [-Inf 0]);

set(pr, 'FaceAlpha', 1);
set(pl, 'FaceAlpha', 1);

hh = findobj(gcf, 'Type', 'Light');
delete(hh)
lightRestoreSingle;

%% Descending BG reveal
% 74 frames to here

mov = movie_tools('still', mov, .5);

zvals = [80:-5:-60];

for i = 1:length(zvals)
    
    delete(pl)
    
    pl = isosurface(anat, 'thresh', 140, 'nosmooth', 'zlim', [-Inf zvals(i)], 'xlim', [-Inf 0]);
    
    set(pl, 'FaceAlpha', 1);
    
    set(gca, 'ZLim', [-60 80]);
    
    hh = findobj(gcf, 'Type', 'Light');
    delete(hh)
    lightRestoreSingle;
    
    drawnow
    
    mov(end+1) = getframe(f1);
    mov(end+1) = getframe(f1);
    
end

mov_with_reveal = mov;

%% WRITE ASCENDING + REVEAL

vid = VideoWriter('Brain_BG_reveal.avi');
open(vid)
for i = 1:length(mov), writeVideo(vid, mov(i)); end
close(vid)

%% Prep for colors

for i = 1:20
    
    camzoom(0.98);
    camdolly(-.03, 0, 0);
    drawnow
    
    mov = movie_tools('still', mov, .1);
    
end

for i = 1:10
    
    camdolly(-.03, 0, 0);
    drawnow
    
    mov = movie_tools('still', mov, .1);
    
end

ax2 = gca;

ax1 = axes('Position', [.02 .3 .45 .45]);

axes(ax1);
pl2 = isosurface(anat, 'thresh', 140, 'nosmooth', 'xlim', [-Inf 0]);


view(223, 20);
set(pl2, 'FaceAlpha', 1);

hh = findobj(gca, 'Type', 'Light');
delete(hh)
lightRestoreSingle;
axis off

camzoom(1.4)

mov = movie_tools('transparent', 0, 1, pl2, mov, 2);

mov_with_lat = mov;
%% WRITE ASCENDING + REVEAL + LAT

vid = VideoWriter('Brain_BG_reveal3.avi');
open(vid)
for i = 1:length(mov), writeVideo(vid, mov(i)); end
close(vid)

%% COLOR CHANGE
obj_cortex = threshold(obj_cortex, [98 Inf], 'raw-between');

mov = movie_tools('still', [], 1);

for i = [4 3 1 2 5]
    
    % striatal surface
    cluster_surf(region(get_wh_image(obj, i)), colors(i), [pr pp pl2], 3);
    
    mov = movie_tools('still', mov, 1.5);
end

% pr = addbrain('eraseblobs',pr);
% pl2 = addbrain('eraseblobs',pl2);
% pp = addbrain('eraseblobs',pp);

for i = [4 3 1 2 5]
    
    % striatal surface
    cluster_surf(region(get_wh_image(obj_cortex, i)), colors(i), [pr pp pl2], 3);
    
    mov = movie_tools('still', mov, 1.5);
end

%% WRITE COLOR CHANGE

vid = VideoWriter('Pauli_BG_5_loops_98.avi');
open(vid)
for i = 1:length(mov), writeVideo(vid, mov(i)); end
close(vid)
