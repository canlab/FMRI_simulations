%% Define spheres
% -------------------------------------------------------------------------

% left LGN approx, right LGN, left V1,  right V1

xyz = [ -17.7834  -26.8588   -0.0619
    16.3514  -26.4865   -0.0541
-6.6718  -92.6718   -0.0573
8.6486  -92.1583   -0.0541];


lgncl = sphere_roi_tool_2008([], 4, xyz(1:2, :));
v1cl = sphere_roi_tool_2008([], 6, xyz(3:4, :));

eyexyz = [-33.7 54.6 -41.2; 33.7 54.6 -41.2];  % left right

eyecl = sphere_roi_tool_2008([], 8, eyexyz);



%% Create figure
% -------------------------------------------------------------------------
colordef black

bcolor = [.3 .5 1];
ocolor = [1 .6 .3];

figure;
hold on;
%create_figure; 
p = addbrain('hires left'); lighting gouraud

p = [p addbrain('brainstem')];
set(p, 'FaceColor', [.5 .5 .5]);
t = addbrain('thalamus');
set(t, 'FaceColor', bcolor);

eyep = imageCluster('cluster', eyecl,'color',bcolor, 'alpha',.5, 'fwhm', 1.2, 'heightthresh', .3);

axis vis3d

set(eyep, 'FaceAlpha', 0);

v1p = imageCluster('cluster', v1cl,'color',bcolor, 'alpha',.5, 'fwhm', 1.2, 'heightthresh', .3);

set(v1p, 'FaceAlpha', 0);

lgnp = imageCluster('cluster', lgncl,'color',bcolor, 'alpha',.5, 'fwhm', 1.2, 'heightthresh', .3);

set(lgnp, 'FaceAlpha', 0);

ahan = addbrain('amygdala');
set(ahan, 'FaceColor', ocolor, 'FaceAlpha', 0);

amyxyz = [-19.4 -6.5 -22.9; 19.4 -6.5 -22.9];

pulvxyz = [-10.3041  -22.4048   13.9839; 10.3041  -22.4048   13.9839];

% Movie
% -------------------------------------------------------------------------
mov = [];

mov = movie_tools('still',mov,1);

mov = movie_tools('transparent',.3,.15, p,mov, 1);

mov = movie_tools('rotate',120,0, mov,1, .3,.07, p); % with transparency

mov = movie_tools('transparent',0, .5, [eyep lgnp], mov, 1);


%mov = movie_tools('lines',startcoords,endcoords,mov,color,bendval,movlength,startt,endt,handles,targetaz,targetel);
st = eyexyz;
en = xyz([2 1], :);

mov = movie_tools('lines',st, en, mov, bcolor,[0 -.1 0],1,[],[],[],[],[]);

mov = movie_tools('transparent',0, .5, v1p, mov, 1);

st = xyz([1 2], :);
en = xyz([3 4], :);
mov = movie_tools('lines',st, en, mov, bcolor,[0 -.1 0],1,[],[],[],[],[]);

mov = movie_tools('transparent',0, .5, ahan, mov, 1);
hh = text(50, -40, -30, 'Amygdala', 'FontSize', 24, 'Color', ocolor);

st = eyexyz;
en = pulvxyz([2 1], :);

mov = movie_tools('lines',st, en, mov, ocolor,[0 -.1 0],1,[],[],[],[],[]);

st = pulvxyz;
en = amyxyz;

mov = movie_tools('lines',st, en, mov, ocolor,[0 -.1 0],1,[],[],[],[],[]);

% write
% -------------------------------------------------------------------------

vid = VideoWriter('V1pathways_black.avi');
open(vid)
for i = 1:length(mov), writeVideo(vid, mov(i)); end
close(vid)

  
