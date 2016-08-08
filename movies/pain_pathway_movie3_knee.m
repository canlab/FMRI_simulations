%% Prep
% clhands1 = sphere_roi_tool_2008([], 16, hands1);
% clfoots1 = sphere_roi_tool_2008([], 16, foots1);
% clmask = mask2clusters('ROI_Anatomy16_Area1_MNI.img');
% clhands1 = cluster_set_intersection(clhands1, clmask);
% clfoots1 = cluster_set_intersection(clfoots1, clmask);
% save S1_hand_foot_bingel2004_spmanatomy16 clhands1 clfoots1

% V = spm_vol(which('avg152T1.nii'));
% clusters2mask(clhands1, V);
% mask_image('clustermask.img', 'ROI_Anatomy16_Area1_MNI.img', 'HandS1_Bingel04.img');
% clhands1 = mask2clusters('HandS1_Bingel04.img');
%save S1_hand_foot_bingel2004_spmanatomy16 -append clhands1

% cl_vmthal = sphere_roi_tool_2008([], 6, [18 -20 2.4]);
% cl_vmthal(2) = sphere_roi_tool_2008([], 6, [-18 -20 2.4]);
% cl_mdthal(1) = sphere_roi_tool_2008([], 6, [-10 -5 2.4]);
% cl_mdthal(2) = sphere_roi_tool_2008([], 6, [10 -5 2.4]);
% save thal_VM-S1_JohBerg05 cl_vmthal

% cd('/Users/tor/Movies/Brain_Movies/Ted_Yanagahara_SpinoThalamic_Tract')
% img = 'Group30-seed-S1_target-VMP-BS.nii';
% [dat, volInfo, cl_R_spinothalamic_tract] = iimg_threshold(img, 'thr', 25);
% cluster_orthviews(cl_R_spinothalamic_tract, {[1 0 0]}, 'solid')
% save cl_R_spinothalamic_tract_tedY cl_R_spinothalamic_tract

% insula
% ains = sphere_roi_tool_2008([], 8, [-40 10 2]);
% imask = '/Volumes/SampsonAlpha/Users/tor/Documents/matlab_code/3DheadUtility/Beer_rois_from_AAL/aal_rois/MNI_Insula_L.img'
% clusters2mask(ains, V);
% mask_image('clustermask.img', imask, 'L_AINS_painmega2009_center.img');
% ains = mask2clusters('L_AINS_painmega2009_center.img');

% 
% % save all clusters: 
% save pain_path_2009_all_clusters *cl*
% save pain_path_2009_all_clusters -append cl* ains
%% first part
fh = create_figure('movie'); axis image; axis vis3d; axis off; 
ax = gca;

cax = axes('Position', [.05 .05 .15 .1]);
text(0, 0, 'Tor Wager, 2009', 'FontSize', 20);
axis off

axes(ax);

[D,Ds,hdr,headhandle,coords] = tor_3d('whichcuts','z', 'coords', [-Inf -Inf Inf], 'filename', 'T1_face_exemplar', 'intensity_threshold', 80); set(gcf, 'Color', 'w'); axis on
lightRestoreSingle, axis off, axis image
material dull
view(180, 0)
mov = movie_tools('still',[],.5);

ctx = addbrain('hires');
set(ctx,'FaceAlpha',1);
axis image; axis vis3d; axis off;
lighting gouraud
material dull
drawnow

% turn off head and rotate 90
mov = movie_tools('rotate', 90, 0,mov,3,1,0,headhandle);
set(headhandle, 'visible', 'off')

brainstem = addbrain('brainstem');
%set(brainstem,'Visible','off')
color = get(brainstem,'FaceColor');
brainstemtext = text(-20, -20,-55,'Brainstem','Color',color,'FontWeight','b','FontSize',36);
set(brainstemtext,'Visible','off');

cb = addbrain('cerebellum');
color = get(cb,'FaceColor');
cbtext = text(-50, -90,-70,'Cerebellum','Color',color,'FontWeight','b','FontSize',36);
set(cbtext,'Visible','on');


color = get(ctx,'FaceColor');
ctxtext = text(50, 50,65,'Cortex','Color',color,'FontWeight','b','FontSize',36);

% lighting
view(90,0);
lightRestoreSingle; 

% start movie; still frames for .5 s
mov = movie_tools('still',mov,.5);
set(cbtext,'Visible','off');
set(ctxtext,'Visible','off');

% start making cortex transparent
mov = movie_tools('transparent',1,.5,ctx,mov,1.5);

set(brainstemtext,'Visible','on');

% turn off cortex and rotate 90
mov = movie_tools('rotate',180,0,mov,3,.5,0,ctx);
delete(ctx); % simplify objects to save time

% turn off cerebellum
cbalpha = get(cb,'FaceAlpha');
mov = movie_tools('transparent',cbalpha,0,cb,mov,1);
delete(cb);

[az, el] = view;

camzoom(.7);

% add thalamus
thal = addbrain('thalamus');
set(thal,'FaceAlpha',0);

thaltext = text(-20, -20,0,'Thalamus','Color',[.7 .4 .4],'FontWeight','b','FontSize',36);

mov = movie_tools('transparent',0,.3,thal,mov,1);

% save pain_movie2_working_pt1 mov
% saveas(gcf,'pain_movie2_working_pt1','fig');

%% part 2

title('Input to the brain', 'FontSize', 32)

% add hand
c = imread('knee.png', 'png');
a2 = axes('Position', [.1 .1 .6 .2])
h = image(1:100, 1:100, c, 'parent', a2);
set(gca, 'XLim', [0 300])
hold on

axis off

% add spinal cord
c2 = imread('spinal_cord.png', 'png');
a3 = axes('Position', [.35 .08 .12 .12])
h = image(100:-1:1, 1:100, c2, 'parent', a3);
axes(a3)
axis off

axes(a2)

% draw line to sp cord lam 1
scoords = [60 40];
ecoords = [144 66];
out = nmdsfig_tools('connect2d',scoords, ecoords,'b', 2, .3);
delete(out.h)
n = length(out.xcoords);
for i = 1:n
    hh = plot(out.xcoords(1:i), out.ycoords(1:i), 'b', 'LineWidth', 2);
    drawnow
    mov(end+1) = getframe(gcf);
    delete(hh)
end
hh = plot(out.xcoords(1:i), out.ycoords(1:i), 'b', 'LineWidth', 2);   

% draw line to sp 2
scoords = [144 66];
ecoords = [174 97];
out = nmdsfig_tools('connect2d',scoords, ecoords,'b', 2, -.1);
n = length(out.xcoords);
delete(out.h)
for i = 1:n
    hh = plot(out.xcoords(1:i), out.ycoords(1:i), 'b', 'LineWidth', 2);
    drawnow
    mov(end+1) = getframe(gcf);
    delete(hh)
end
hh = plot(out.xcoords(1:i), out.ycoords(1:i), 'b', 'LineWidth', 2);   

% draw line to brainstem
scoords = [174 97];
ecoords = [224 0]; %[208 30];
out = nmdsfig_tools('connect2d',scoords, ecoords,'b', 2, .1);
n = length(out.xcoords);
delete(out.h)
for i = 1:n
    hh = plot(out.xcoords(1:i), out.ycoords(1:i), 'b', 'LineWidth', 2);
    drawnow
    mov(end+1) = getframe(gcf);
    delete(hh)
end
hh = plot(out.xcoords(1:i), out.ycoords(1:i), 'b', 'LineWidth', 2);   


% save pain_movie2_working_pt2 mov
% saveas(gcf,'pain_movie2_working_pt2','fig');


%% part 3

%delete(a2)
load pain_path_2009_all_clusters
axes(ax)

% add STTs
[outi, clstt] = imageCluster('cluster', cl_R_spinothalamic_tract, 'color', [.5 .5 1], 'alpha', .5);

cl_L_spinothalamic_tract = cl_R_spinothalamic_tract;
cl_L_spinothalamic_tract.XYZmm(1,:) = -cl_L_spinothalamic_tract.XYZmm(1,:) + 4;
[outi2, clstt2] = imageCluster('cluster', cl_L_spinothalamic_tract, 'color', [.5 .5 1], 'alpha', .5);

stttext = text(-30, -20,30,'Spinothalamic','Color',[.5 .5 1],'FontWeight','b','FontSize',36);
set(outi, 'Visible', 'off')
set(outi2, 'Visible', 'off')
set(stttext, 'Visible', 'off')
material dull

% add cortex
ctx = addbrain('hires');
set(ctx,'FaceAlpha',.04); drawnow

mov = movie_tools('transparent',0,.04,ctx,mov,1);


set(outi, 'Visible', 'on')
set(outi2, 'Visible', 'on')
set(stttext, 'Visible', 'on')
set([outi outi2], 'FaceAlpha', .05); drawnow
mov = movie_tools('transparent',0,.5,[outi outi2],mov,2);

delete(stttext)
delete(thaltext)
delete(brainstemtext)

% add VL thalamus, cortex and rotate
vmthalhan = imageCluster('cluster', cl_vmthal, 'color', [1 0 0], 'alpha', 1);
material dull

hiresr = addbrain('hires right');
view(180, 0); set(hiresr, 'FaceColor', [.5 .5 .5]);

set(hiresr, 'FaceAlpha', .05);
drawnow
mov = movie_tools('rotate',230,0,mov,4,0,1, [hiresr vmthalhan]); % with transparency


% line to VM thalamus
delete(a2)
delete(a3)
%vmtext = text(-90, -20,30,'VM Thalamus','Color',[1 0 0],'FontWeight','b','FontSize',24);
drawnow
mov = movie_tools('lines',clstt2.XYZmm(:,1)',cl_vmthal(2).mm_center, mov,'b', [0 -.1 0], 1, [],[],[],[],[]);


% line to S1
%htext = text(-90, -20,70,'S1 (hand)','Color',[1 0 0],'FontWeight','b','FontSize',24);

clhands1.Z = ones(1, size(clhands1.XYZmm, 2));
clhands1.XYZmm(1,:) = -clhands1.XYZmm(1,:) + 4; % left
clhands1.mm_center = mean(clhands1.XYZmm');

hands1han = imageCluster('cluster', clhands1, 'color', [1 0 0], 'alpha', 1); material dull
lightRestoreSingle;

set(hands1han, 'FaceAlpha', .05);
mov = movie_tools('transparent',.05,1,hands1han,mov,1);

mov = movie_tools('lines',cl_vmthal(2).mm_center,clhands1.mm_center, mov,'b', [0 -.1 0], 1, [],[],[],[],[]);

% save pain_movie2_working_pt3 mov
% saveas(gcf,'pain_movie2_working_pt3','fig');

clhands1.XYZmm(1,:) = -clhands1.XYZmm(1,:) - 4; % flip back right
clhands1.mm_center = mean(clhands1.XYZmm');
%% Part 4
% Add S2, Line to S2


cls2 = mask2clusters('ROI_Anatomy16_OP1_MNI.img');
cls2 = cls2(1); % left
[D,Ds,hdr,han_coronalpostslice,coords]  = tor_3d('whichcuts', 'coronal slice left', 'coords', cls2(1).mm_center - 8, 'topmm', 100);
view(235, 0)
colormap gray
set(han_coronalpostslice(1), 'FaceColor', [.5 .5 .5])

s2han = imageCluster('cluster', cls2, 'color', [1 0 0], 'alpha', 1); material dull

%delete(vmtext)
%s2text = text(-90, -40,20,'S2','Color',[1 0 0],'FontWeight','b','FontSize',24);

set(s2han, 'FaceAlpha', .3);
mov = movie_tools('lines',cl_vmthal(2).mm_center,cls2.mm_center, mov,'b', [0 .1 0], 1, .3,1,s2han,210,0);


% save pain_movie2_working_pt4 mov
% saveas(gcf,'pain_movie2_working_pt4','fig');

%% part 5

title('The feeling of suffering', 'FontSize', 32)

% add ACC

img = '/Users/tor/Documents/Tor_Documents/Grants/Challenge_Grant_Pain_Biomarkers/pain_matrix_mega_analysis/robust0001/rob_p_0001.img';
iimg_threshold(img, 'thr', .000001, 'threshtype', 'p', 'imgtype', 'p', 'outnames', 'pain_mtx_mega_thr.img');
painx = mask2clusters('pain_mtx_mega_thr.img');
painx(cat(1, painx.numVox) < 500) = [];
%cluster_orthviews(painx, {[1 0 1]}, 'solid')
acc = painx(end);
cluster_surf(acc, {[1 0 1]}, 2, hiresr);

acctext = text(40, 160,100,'Anterior Cingulate','Color',[1 0 1],'FontWeight','b','FontSize',24);
%delete(htext)

% add MD thal
% mdthalhan = imageCluster('cluster', cl_mdthal(1), 'color', [1 0 1], 'alpha', 1);
% material dull
% 
% set(mdthalhan, 'FaceAlpha', .05);
% mov = movie_tools('lines',clstt2.XYZmm(:,1)',cl_mdthal(1).mm_center, mov, 'b', [0 .1 0], 1, .05,1,mdthalhan,250,5);

% lines to ACC

%x = [cl_mdthal(1).mm_center; cls2.mm_center];
%y = [acc.mm_center; acc.mm_center];
x = [cls2.mm_center];
y = [acc.mm_center];
mov = movie_tools('lines',x, y, mov,'b', [0 .1 0], 4, [], [], [], 268, 10);


% Add anterior insula
% --------------------------
%ains = painx(3);

% [D,Ds,hdr,han_coronalantslice,coords]  = tor_3d('whichcuts', 'coronal slice left', 'coords', ains(1).mm_center, 'topmm', 100);
% set(han_coronalantslice(1), 'FaceColor', [.5 .5 .5])
% view(250, 5);
% set(han_coronalantslice, 'FaceAlpha', .05)
% 
% ainshan = imageCluster('cluster', ains(1), 'color', [1 0 1], 'alpha', 1);
% set(ainshan, 'FaceAlpha', .05); material dull;
% 
% ainstext = text(40, 140,-60,'Anterior Insula','Color',[1 0 1],'FontWeight','b','FontSize',24);
% 
% y = [ains.mm_center; ains.mm_center; ains.mm_center];
% x = [cl_mdthal(1).mm_center; cls2.mm_center];
% x = cat(1, [x; acc.mm_center]);
% drawnow
% mov = movie_tools('lines',x, y, mov,'b', [0 .1 0], 2, .05, 1, [han_coronalantslice ainshan], 230, 10);


%% part 6
% head appears briefly
set(headhandle, 'visible', 'on')
mov = movie_tools('transparent', 0, 1, headhandle, mov, 2);

mov = movie_tools('still', mov, 2);

%hh = findobj('Type', 'Line', 'Color', 'b');
%delete(hh)
delete(hands1han)
%delete(han_coronalantslice)
delete([outi outi2])

% head disappears
mov = movie_tools('transparent', 1, 0, headhandle, mov, 2);
set(headhandle, 'visible', 'off')

mov = movie_tools('still', mov, 10);

load('/Users/tor/Documents/Tor_Documents/PublishedProjects/inpress_SET_parts_1_and_2/Resil2_Speech_Task/SPEECH_TASK_RESULTS/analyses_november08/mediation_speech_brain_HRnocovs_hrmod/FDR_corrected_results/cl_a_b_overlap_covrem_data.mat')
vmpfc = cl_apos_bpos(1);
vmpfc.XYZmm(2,:) = vmpfc.XYZmm(2,:) + 7;
vmpfc.XYZmm(3,:) = vmpfc.XYZmm(3,:) - 3;
cluster_surf(vmpfc, {[1 .2 0]}, 3, hiresr);

vmtext = text(40, 100,-100,'VMPFC: Control of Emotions and Pain','Color',[1 .2 0],'FontWeight','b','FontSize',20);

mov = movie_tools('still', mov, 10);

% y = [vmpfc.mm_center; vmpfc.mm_center; vmpfc.mm_center; vmpfc.mm_center];
% x = cat(1, [x; ains.mm_center]);
y = [vmpfc.mm_center];
x =acc.mm_center;

%mov = movie_tools('lines',x, y, mov,'b', [0 .1 0], 2, 1, .5, ainshan, [], []);
mov = movie_tools('lines',x, y, mov,'b', [0 .1 0], 4, [], [], [], [], []);

% save pain_movie2_working_pt6 mov
% saveas(gcf,'pain_movie2_working_pt6','fig');

%% part 7
title('Effects on the body', 'FontSize', 32)

% fade out
mov = movie_tools('still', mov, 4);

hh = findobj('Type', 'Line', 'Color', 'b');
delete(hh)
%delete(s2text)

%mov = movie_tools('transparent',.5,0,[s2han ainshan vmthalhan han_coronalpostslice],mov,1);
mov = movie_tools('transparent',.5,0,[s2han  vmthalhan han_coronalpostslice],mov,4);


%% part 8

% add pag
load pag_cl

pagh = addbrain('pag');
set(pagh,'FaceAlpha',1, 'FaceColor', [1 .8 0]); material dull

color = get(pagh,'FaceColor');
%pagtext = text(40, 30,-80,'PAG: Central coordinator','Color',color,'FontWeight','b','FontSize',20);
pagtext = text(-20, -35,-0,'PAG','Color',color,'FontWeight','b','FontSize',24);
set(pagtext,'Visible','on');

% add hypothalamus
% hycl = mask2clusters('spm2_hythal.img');
% hycoords = hycl(1).mm_center;
% hy = addbrain('hy');
% set(hy,'FaceAlpha',1, 'FaceColor', [1 .8 0]); material dull
% color = get(hy,'FaceColor');
% hytext = text(40, 30,-95,'Hypothalamus: Hormones','Color',color,'FontWeight','b','FontSize',20);

delete(acctext)
%delete(ainstext)

% x = [cl_mdthal(1).mm_center; acc.mm_center; vmpfc.mm_center];
% x = [x; x];
% y = [pag.mm_center; hycl.mm_center];
% y = [y;y;y];

x = [acc.mm_center; vmpfc.mm_center];
y = [pag.mm_center];
y = [y;y];
%mov = movie_tools('lines',startcoords,endcoords,mov,color,bendval,movlength,startt,endt,handles,targetaz,targetel);
mov = movie_tools('lines',x,y,mov,'r',[0 -.1 0],4,[],[],[],[],[]);

delete(vmtext)

% add spinal cord
c2 = imread('spinal_cord.png', 'png');
a3 = axes('Position', [.55 .12 .12 .12])
h = image(100:-1:1, 1:100, c2, 'parent', a3);
axis off
axes(ax)

title('Descending pain control', 'FontSize', 32)

x = [pag.mm_center];
y = [0 -40 -90];

offtext = text(-20, -35,-20,'Pain OFF','Color',[1 .5 .5],'FontWeight','b','FontSize',24);
mov = movie_tools('lines',x,y,mov,'r',[0 -.1 0],4,[],[],[],[],[]);

ontext = text(-20, -35,-32,'Pain ON','Color','g','FontWeight','b','FontSize',24);
mov = movie_tools('lines',[x(1) x(2) - 5 x(3)],[y(1) y(2)-3 y(3)],mov,'g',[0 -.1 0],4,[],[],[],[],[]);

mov = movie_tools('still', mov, 4);


% % add heart
% c2 = imread('heart.png', 'png');
% a4 = axes('Position', [.5 .12 .12 .12])
% h = image(1:100, 1:100, c2, 'parent', a4);
% axes(a4); axis image
% axis off
% axes(ax)
% htext = text(40, -60,-90,'Heart and other organs','Color',[1 .8 0],'FontWeight','b','FontSize',20);
% 
% x = [pag.mm_center; hycl.mm_center];
% y = repmat([0 -42 -65], 2, 1);
% 
% delete([pagtext hytext vmtext])
% mov = movie_tools('lines',x,y,mov,'b',[0 -.1 0],2,[],[],[],268,0);
% 
% save pain_movie2_working_pt8 mov
% saveas(gcf,'pain_movie2_working_pt8','fig');
%%

movie2avi(mov, 'pain_pathways3.avi', 'fps', 8);

%%


