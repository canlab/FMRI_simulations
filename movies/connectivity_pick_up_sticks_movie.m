create_figure;
h = addbrain('hires');
set(h, 'FaceAlpha', .05, 'FaceColor', [.1 0 .7]);
axis off;
view(180, 0);
camzoom(.2);

mov = movie_tools('still',[],1);

%% zoom in and rotate

az = linspace(180, 0, 30);
el = linspace(0, 90, 30);

for i = 1:65
    
    mov(end+1) = getframe(gcf);
    
    if i > 35
        view(az(i-35), el(i-35));
    end
    
    camzoom(1.025)
    
    
end

%% rotate
%mov = movie_tools('rotate',0,90,mov);

%% brain vox

img = fmri_data(which('gray_matter_mask.img'));
n = length(img.dat);

%%
k = 300;

wh1 = randperm(n); wh1 = wh1(1:k);
xyz1 = img.volInfo.xyzlist(wh1, :);
xyz1 = voxel2mm(xyz1', img.volInfo.mat);

clear hh

for i = 1:k
    
    mycolor = [.5 .5 1] + .1*rand(1, 3);
    mycolor(mycolor > 1) = 1;
    
    hh(i) = plot3(xyz1(1, i), xyz1(2, i), xyz1(3, i), 'Color', mycolor, 'Marker', 's', 'LineWidth', 2);
    
    if i < 35 || ~mod(i, 10)
        mov(end+1) = getframe(gcf);
    end
    
end

delete(hh)

% pick up sticks connections
k = 500;

for i = 1:k
    
    wh1 = randperm(n); wh1 = wh1(1);
    wh2 = randperm(n); wh2 = wh2(1);
    
    xyz1 = img.volInfo.xyzlist(wh1, :);
    xyz2 = img.volInfo.xyzlist(wh2, :);
    
    xyz1 = voxel2mm(xyz1', img.volInfo.mat);
    xyz2 = voxel2mm(xyz2', img.volInfo.mat);
    
    mycolor = [.5 .5 1] + .1*rand(1, 3);
    mycolor(mycolor > 1) = 1;
    
    plot3([xyz1(1) xyz2(1)], [xyz1(2) xyz2(2)], [xyz1(3) xyz2(3)], 'Color', mycolor, 'LineWidth', 2);
    
    if i < 50 || ~mod(i, 10)
        mov(end+1) = getframe(gcf);
    end
    
end

%%
vid = VideoWriter('pick_up_sticks_brain.avi');
open(vid)
for i = 1:length(mov), writeVideo(vid, mov(i)); end
close(vid)