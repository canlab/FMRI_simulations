%% first part
tor_fig; axis image; axis vis3d; axis off; 

brainstem = addbrain('brainstem');
%set(brainstem,'Visible','off')
color = get(brainstem,'FaceColor');
brainstemtext = text(-20, -20,-55,'Brainstem','Color',color,'FontWeight','b','FontSize',36);
set(brainstemtext,'Visible','off');

cb = addbrain('cerebellum');
color = get(cb,'FaceColor');
cbtext = text(-50, -90,-70,'Cerebellum','Color',color,'FontWeight','b','FontSize',36);
set(cbtext,'Visible','on');

ctx = addbrain('hires');
color = get(ctx,'FaceColor');
set(ctx,'FaceAlpha',1);
ctxtext = text(50, 50,65,'Cortex','Color',color,'FontWeight','b','FontSize',36);

% lighting
view(90,0);
axis image; axis vis3d; axis off;
lightRestoreSingle(gca); lighting gouraud
material dull
drawnow

% start movie; still frames for .5 s
mov = movie_tools('still',[],.5);
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


%% part 2 setup
% % % mov = [];
% % % tor_fig; axis image; axis vis3d; axis off; 
% % % brainstem = addbrain('brainstem');
% % % %set(brainstem,'Visible','off')
% % % color = get(brainstem,'FaceColor');
% % % brainstemtext = text(-20, -20,-55,'Brainstem','Color',color,'FontWeight','b','FontSize',36);
% % % set(brainstemtext,'Visible','on');
% % % view(180,0); 
% % % axis auto
% % % axis image; axis vis3d; axis off;
% % % lightRestoreSingle(gca); lighting gouraud
% % % material dull
% % % drawnow
% % % camzoom(.8)
% % % camzoom(.8)

%% part 2

camzoom(.7);

% add thalamus
thal = addbrain('thalamus');
set(thal,'FaceAlpha',0);
mov = movie_tools('transparent',0,.3,thal,mov,.5);

% add line to CM, and DM add thal
load thal_brainstem_approx_working

x = [0 -40 -72; 0 -40 -72]; y = [CM.mm_center; MD.mm_center];
cm = addbrain('cm');
set(cm,'FaceAlpha',0);
md = addbrain('md');
set(md,'FaceAlpha',0);
han = [cm md];

%mov = movie_tools('lines',startcoords,endcoords,mov,color,bendval,movlength,startt,endt,handles,targetaz,targetel);
mov = movie_tools('lines',x,y,mov,'b',[0 -.1 0],2,0,.8,han,90,10);


% add pag
load pag_cl
x = [0 -40 -72]; y = pag.mm_center;

pagh = addbrain('pag');
set(thal,'FaceAlpha',.2);
color = get(pagh,'FaceColor');
pagtext = text(y(1), y(2)-30,y(3),'PAG','Color',color,'FontWeight','b','FontSize',36);
set(pagtext,'Visible','on');

%mov = movie_tools('lines',startcoords,endcoords,mov,color,bendval,movlength,startt,endt,handles,targetaz,targetel);
mov = movie_tools('lines',x,y,mov,'b',[0 -.1 0],2,.2,1,pagh,[],[]);


% add pbn
load pbn_cl
x = [0 -40 -72; 0 -40 -72]; y = cat(1,pbn.mm_center);

pbnh = addbrain('pbn');
set(pbnh,'FaceAlpha',.2);
color = get(pbnh,'FaceColor');
pbntext = text(y(1,1), y(1,2)-50,y(3),'PBN/LC','Color',color,'FontWeight','b','FontSize',36);
set(pbntext,'Visible','on');

%mov = movie_tools('lines',startcoords,endcoords,mov,color,bendval,movlength,startt,endt,handles,targetaz,targetel);
mov = movie_tools('lines',x,y,mov,'b',[0 -.1 0],2,.2,1,pbnh,[],[]);

% % % mov = close(mov);

%% part 3
pagtext = findobj('String','PAG');
pbntext = findobj('String','PBN/LC')
brainstemtext = findobj('String','Brainstem');

% % % mov = [];
%mov = movie_tools('zoom',.7,mov,1);

hycl = mask2clusters('spm2_hythal.img');
hycoords = hycl(1).mm_center;
hy = addbrain('hy');
color = get(hy,'FaceColor');
set(hy,'FaceAlpha',0);
mov = movie_tools('transparent',0,1,hy,mov,.4);
hytext = text(hycoords(1), hycoords(2),hycoords(3),'Hy','Color',color,'FontWeight','b','FontSize',36);

set(pagtext,'Visible','off');
set(pbntext,'Visible','off');
delete(brainstemtext);

naccl = mask2clusters('spm2_nac.img');
naccoords = cat(1,naccl.mm_center);
nac = addbrain('nac');
set(nac,'FaceAlpha',0);
mov = movie_tools('transparent',0,1,nac,mov,.4);
color = get(nac,'FaceColor');
hytext = text(naccoords(1), naccoords(2),naccoords(3)-20,'NAC','Color',color,'FontWeight','b','FontSize',36);

caucl = mask2clusters('spm2_caudate.img');
caucoords = caucl(1).mm_center;
cau = addbrain('caudate');
set(cau,'FaceAlpha',0);
mov = movie_tools('transparent',0,.5,cau,mov,.4);
color = get(cau,'FaceColor');
hytext = text(caucoords(1), caucoords(2)+30,caucoords(3),'Cau','Color',color,'FontWeight','b','FontSize',36);

pagcoords = pag.mm_center;  % five outputs from each of three senders
cmcoords = cat(1,CM.mm_center);
cauxyxtmp = caucl(1).XYZmm(:,caucl(1).XYZmm(3,:) < 10 & caucl(1).XYZmm(2,:) > 0) ;
cauxyztmp = caucl(1).XYZmm(:,caucl(1).XYZmm(3,:) < 10 & caucl(1).XYZmm(2,:) > 0) ;
caucoords = cauxyztmp(:,324)'; 
caucoords = [caucoords; caucoords];
caucoords(1) = -caucoords(1);

% five outputs from each of three senders
x = [repmat(pagcoords,5,1); repmat(cmcoords(1,:),5,1); repmat(cmcoords(2,:),5,1)];
y = repmat([hycoords; naccoords; caucoords],3,1);
mov = movie_tools('lines',x,y,mov,'b',[0 .2 0],1,[],[],[],126,18);

hytext = findobj('String','Hy');
nactext = findobj('String','NAC');
cautext = findobj('String','Cau');
set(hytext,'Visible','off');
set(nactext,'Visible','off');
set(cautext,'Visible','off');

mov = movie_tools('still',mov,2);
ctx = addbrain();
set(ctx,'FaceAlpha',.15);
load placebo_clusters2
s1coords = cl(60).mm_center;
s1h = imageCluster('cluster',cl(60),'color',[0 0 1],'alpha',1);

s2coords = cl(37).mm_center;
s2h = imageCluster('cluster',cl(37),'color',[0 .5 1],'alpha',1);
material dull; lighting gouraud
camzoom(1.7)


mdcoords = cat(1,MD.mm_center);
x = [mdcoords; mdcoords];
y = [s1coords; s1coords; s2coords; s2coords];
mov = movie_tools('lines',x,y,mov,'b',[.3 .2 0],1,0,1,[s1h s2h],110,32);


color = get(s1h,'FaceColor');
s1text = text(s1coords(1)-20, s1coords(2)-40,s1coords(3),'SI','Color',color,'FontWeight','b','FontSize',36);
color = get(s2h,'FaceColor');
s2text = text(s2coords(1)-20, s2coords(2)-40,s2coords(3),'SII','Color',color,'FontWeight','b','FontSize',36);

%mov = close(mov);

%%% part 4
inscl = cl(5);
wh = find(inscl.XYZmm(2,:) < 0); whos wh
inscl.XYZmm(:,wh) = [];
inscl.Z(wh) = [];
inscl.XYZ(:,wh) = [];
inscl.numVox = size(inscl.XYZmm,2);

inscoords = inscl.mm_center;
insh = imageCluster('cluster',inscl,'color',[1 0 0],'alpha',0);
material dull; lighting gouraud

pbncoords = cat(1,pbn.mm_center);
x = [pbncoords; pagcoords; s1coords; s2coords; mdcoords];
y = repmat(inscoords,7,1);
mov = movie_tools('lines',x,y,mov,'b',[.3 .2 0],1,0,1,[insh],90,0);

color = get(insh,'FaceColor');
instext = text(inscoords(1)+20, inscoords(2)+20,inscoords(3),'aINS','Color',color,'FontWeight','b','FontSize',36);
mov = movie_tools('still',mov,1);

mov = close(mov);

%% 


