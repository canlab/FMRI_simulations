%% first part
tor_fig; axis image; axis vis3d; axis off; 

brainstem = addbrain('brainstem');

ctx = addbrain();
set(ctx,'FaceAlpha',1);


% lighting
view(115,20);
axis image; axis vis3d; axis off;
lightRestoreSingle(gca); lighting gouraud
material dull
drawnow

% start movie; still frames for .5 s
mov = movie_tools('still',[],.5);


% turn off cortex and rotate 90
%mov = movie_tools('rotate',180,0,mov,3,.5,0,ctx);

 

%%
load placebo_clusters2
vlpfc = cl(2);

for i = 0:.1:.5
    cluster_surf(vlpfc,3,{[.5+i .5-i .5-i]},ctx);
    mov = movie_tools('still',[],.3);
end

%% 
% add pag
load pag_cl

pagloc = pag.mm_center;
bottomloc = [0 -40 -72]; 

pagh = addbrain('pag');

%% add rACC

% start making cortex transparent
mov = movie_tools('transparent',1,.5,ctx,mov,1.5);

left = addbrain('left');
set(left,'FaceColor',[.5 .5 .5],'FaceAlpha',1);

racc = cl(17);
racc.XYZmm(3,:) = racc.XYZmm(3,:) - 8;  % adjust for look of SPM2 surface brain vs. spm99 orth
cluster_surf(racc,5,{[1 0 0]},left);

%  make cortex more transparent
mov = movie_tools('transparent',.5,.2,ctx,mov,1.5);

%% draw lines to rACC, then down

vlpfch = imageCluster('cluster',vlpfc,'color',[1 0 0],'alpha',1);
set(vlpfch,'FaceAlpha',0); material dull

raccloc = racc.mm_center;
raccloc(1) = raccloc(1) - 4;
raccloc(3) = raccloc(3) - 5;
x = [raccloc; vlpfc.mm_center];
y = [pagloc; pagloc];

%mov = movie_tools('lines',startcoords,endcoords,mov,color,bendval,movlength,startt,endt,handles,targetaz,targetel);
mov = movie_tools('lines',x,y,mov,'b',[.2 -.1 0],3,0,.4,vlpfch,90,0);

x = pagloc;
y = bottomloc;

%mov = movie_tools('lines',startcoords,endcoords,mov,color,bendval,movlength,startt,endt,handles,targetaz,targetel);
mov = movie_tools('lines',x,y,mov,'b',[0 -.1 0],3,.15,.02,ctx,50,37);



%%
mov = close(mov);
