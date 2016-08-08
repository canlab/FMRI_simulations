create_figure('brain'); han = addbrain('limbic');
set(han, 'FaceColor', [.5 .5 .5], 'FaceAlpha', .5);
%view(120, 10)
view(90, 0)
lightRestoreSingle

%%
mov = [];
mov = movie_tools('still', mov, .5);
mov = movie_tools('rotate',120,10, mov);


%%
wh = findobj(han, 'Tag', 'hippocampus');

texthan = text(0, 0, -40, sprintf('Hippocampus\nDeclarative memory'), 'FontSize', 32, 'Color', 'r');
set(wh, 'FaceAlpha', .8);
mov = movie_tools('color', [.5 .5 .5], [1 0 0], wh, mov, 1);
mov = movie_tools('color', [1 0 0], [.65 .5 .5], wh, mov, 1);

set(wh, 'FaceAlpha', .5, 'FaceColor', [.65 .5 .5]);
delete(texthan)

%%
wh = findobj(han, 'Tag', 'amygdala');

texthan = text(80, -75, -50, sprintf('Amygdala\nThreat association'), 'FontSize', 32, 'Color', 'b');
set(wh, 'FaceAlpha', .8);
mov = movie_tools('color', [.5 .5 .5], [0 0 1], wh, mov, 1);
mov = movie_tools('color', [0 0 1], [.5 .5 .65], wh, mov, 1);

set(wh, 'FaceAlpha', .5, 'FaceColor', [.5 .5 .65]);
delete(texthan)

%%
wh = findobj(han, 'Tag', 'nacc');
wh = [wh findobj(han, 'Tag', 'putamen')];
wh = [wh findobj(han, 'Tag', 'GPe')];
wh = [wh findobj(han, 'Tag', 'GPi')];

oncolor = [0 1 0];
offcolor = [.5 .65 .5];

texthan = text(80, -75, 70, sprintf('Ventral striatum\nReinforcement learning'), 'FontSize', 32, 'Color', .5*oncolor+.5*offcolor);
set(wh, 'FaceAlpha', .8);
mov = movie_tools('color', [.5 .5 .5], oncolor, wh, mov, 1);
mov = movie_tools('color', oncolor, offcolor, wh, mov, 1);

set(wh, 'FaceAlpha', .5, 'FaceColor', offcolor);
delete(texthan)

%%
wh = findobj(han, 'Tag', 'caudate');
wh = [wh findobj(han, 'Tag', 'putamen')];

oncolor = [0 1 1];
offcolor = [.5 .65 .65];

texthan = text(80, -75, 70, sprintf('Dorsal striatum\nHabit learning'), 'FontSize', 32, 'Color', .5*oncolor+.5*offcolor);
set(wh, 'FaceAlpha', .8);
mov = movie_tools('color', [.5 .5 .5], oncolor, wh, mov, 1);
mov = movie_tools('color', oncolor, offcolor, wh, mov, 1);

set(wh, 'FaceAlpha', .5, 'FaceColor', offcolor);
delete(texthan)

%%
wh = findobj(han, 'Tag', 'brainstem');
h2 = addbrain('cerebellum');
set(h2, 'FaceColor', [.5 .5 .5]);

wh = [wh h2];

oncolor = [1 .5 0];
offcolor = [.65 .55 .5];

texthan = text(80, -75, 70, sprintf('Hindbrain\nPhysiological conditioning'), 'FontSize', 32, 'Color', .5*oncolor+.5*offcolor);
set(wh, 'FaceAlpha', .8);
mov = movie_tools('color', [.5 .5 .5], oncolor, wh, mov, 1);
mov = movie_tools('color', oncolor, offcolor, wh, mov, 1);

set(wh, 'FaceAlpha', .5, 'FaceColor', offcolor);
delete(texthan)

%% INSULA

wh = findobj(han, 'Tag', 'hires left');
h2 = addbrain('right');
view(120, 10);
lightRestoreSingle; material dull
set(h2, 'FaceColor', [.5 .5 .5], 'FaceAlpha', .05);
wh = [wh h2];
drawnow

anat = load('atlas_combined_gross_regions');

oncolor = [0 .5 1];
offcolor = [.5 .55 .65];

cluster_surf(anat.cl(8), 2, {oncolor}, wh);


texthan = text(80, 0, -40, sprintf('Insula\nTaste and viscerosensory learning'), 'FontSize', 32, 'Color', .5*oncolor+.5*offcolor);

mov = movie_tools('rotate',90,0, mov);
%mov = movie_tools('still', mov, 1);
delete(h2);
delete(texthan)

%% MOTOR

wh = findobj(han, 'Tag', 'hires left');


anat = load('atlas_labels_combined_info');
whregion = strcmp(anat.names, 'L precentral gyrus');

oncolor = [1 0 0];
offcolor = [.65 .5 .5];

cluster_surf(anat.cl(whregion), 2, {oncolor}, wh);


texthan = text(80, 20, -50, sprintf('M1\nMotor learning'), 'FontSize', 32, 'Color', .5*oncolor+.5*offcolor);
mov = movie_tools('still', mov, 1);

delete(texthan)

%% SENSORY

wh = findobj(han, 'Tag', 'hires left');


anat = load('atlas_labels_combined_info');
whregion = strcmp(anat.names, 'L middle occipital gyrus');

oncolor = [0 .5 1];
offcolor = [.5 .55 .65];

cluster_surf(anat.cl(whregion), 2, {oncolor}, wh);


texthan = text(80, -60, -50, sprintf('V1\nPerceptual learning'), 'FontSize', 32, 'Color', .5*oncolor+.5*offcolor);
mov = movie_tools('still', mov, 2);

delete(texthan)

%% FRONTAL

wh = findobj(han, 'Tag', 'hires left');


anat = load('atlas_labels_combined_info');
whregion = strcmp(anat.names, 'L superior frontal gyrus');

oncolor = [1 .5 0];
offcolor = [.65 .55 .5];

cluster_surf(anat.cl(whregion), 2, {oncolor}, wh);


texthan = text(80, -30, -70, sprintf('PFC\nTask and rule learning'), 'FontSize', 32, 'Color', .5*oncolor+.5*offcolor);
mov = movie_tools('still', mov, 2);

delete(texthan)


%%

vidObj = VideoWriter('LearningSystems2', 'MPEG-4');
vidObj.FrameRate = 10;
open(vidObj);
writeVideo(vidObj,mov);
close(vidObj);