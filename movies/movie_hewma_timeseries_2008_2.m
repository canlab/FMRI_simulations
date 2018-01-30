%% prep clusters 
%load Lucy_wholebrain2
load hewma_cl_sig_60_regions

preprochan = @(ts) resil2_custom_preproc(ts);

%% prep clusters 2
for i = 1:length(cl)
    
    for j = 1:size(cl(i).raw_data, 3)
        
        cl(i).preproc_data(:, :, j) = preprochan(cl(i).raw_data(:, :, j));
        
    end
    
    cl(i).all_vox_avg = nanmean(cl(i).preproc_data, 3);
        
    
    cl(i).timeseries = nanmean(cl(i).all_vox_avg, 2); % grand average
    
end

clpos_data_for_movie = cl;
clpos_data_for_movie(cat(1, clpos_data_for_movie.numVox) < 2) = [];

ts = cat(2, clpos_data_for_movie.timeseries);

%% prep colormap

% Set up colormap stuff
% --------------------------------------------
%tmp = cat(2, clpos_data_for_movie.all_vox_avg);

refZrange = [0 3 -eps -3]; % z-scores
poscm = colormap_tor([.2 .2 .4], [1 1 0], [.9 .6 .1]);  %slate to orange to yellow
negcm = colormap_tor([.2 .2 .4], [0 0 1], [0 .3 1]);  % slate to light blue to dark blue

%% Prep figure %% Set up

create_figure('Surfaces', 2, 3);

p1 = addbrain; lighting gouraud; lightRestoreSingle; set(p1, 'FaceAlpha', 1); material dull
axis image; axis off

subplot(2, 3, 2);
p2 = addbrain('right'); lighting gouraud; lightRestoreSingle; set(p2, 'FaceAlpha', 1); material dull; set(p2, 'FaceColor', [.5 .5 .5]);
axis image; axis off

% 4 and 5 are left and right views
subplot(2, 3, 4);
p4 = addbrain; lighting gouraud; lightRestoreSingle; set(p4, 'FaceAlpha', 1); material dull
view(270, 0); lightRestoreSingle;
axis image; axis off

% delete this because we will copy it over from p1!
delete(p4);

subplot(2, 3, 5);
axis off

subplot(2, 3, 6);
p3 = addbrain('limbic'); lighting gouraud; lightRestoreSingle; set(p3, 'FaceAlpha', 1); material dull; 

%
%p3 = p3(1:end-1); % don't manip surface
set(p3(end), 'FaceAlpha', .2, 'FaceColor', [.5 .5 .5]);

p3 = [p3 addbrain('brainstem')];
set(p3(end), 'FaceAlpha', .8);
view(135, 10);

subplot(2, 3, 3)
cla
plot(ts);
set(gca, 'XLim', [0 size(ts, 1)]);
xlabel('time (TRs, 2*sec)');


%saveas(gcf,'baseline_movie_fig2', 'fig');

%% init movie

mov = avifile('hewma_ts_movie2.avi','Quality',75,'Compression','None','Fps',10);
f1 = gcf;

%%
subplot(2, 3, 3)
cla
plot(ts);
set(gca, 'XLim', [0 size(ts, 1)]);
xlabel('time (TRs, 2*sec)');

for i = 1:5:length(clpos_data_for_movie(1).timeseries)

    fprintf('\n******************************\nTimepoint %3.0f\n******************************\n', i);
tic
    % This is the data that will determine the color at this time point
    % May want to constrain across all time points with reference limits
    % May want to use custom colormap
    % How about direction of effect?
    
    for j = 1:length(clpos_data_for_movie)
        clpos_data_for_movie(j).Z = clpos_data_for_movie(j).all_vox_avg(i, :);
    end

    subplot(2, 3, 3);
    if exist('lineh', 'var') && ~isempty(ishandle(lineh)) && ishandle(lineh), delete(lineh); end
    lineh = plot_vertical_line(i);
    set(lineh, 'Color', 'g', 'LineWidth', 3);
    drawnow
    
    subplot(2, 3, 1);
    cluster_surf(clpos_data_for_movie, 3, [p1], 'heatmap', refZrange, 'colormaps', poscm, negcm);

    subplot(2, 3, 2);
    cluster_surf(clpos_data_for_movie, 3, [p2], 'heatmap', refZrange, 'colormaps', poscm, negcm);

    if exist('p4', 'var') && ishandle(p4), delete(p4); end
    p4 = copyobj(p1, subplot(2, 3, 4));
    lighting gouraud; 
    view(270, 0); lightRestoreSingle;
    axis image; axis off

    if exist('p5', 'var') && ishandle(p5), delete(p5); end
    p5 = copyobj(p1, subplot(2, 3, 5));
    lighting gouraud; 
    view(90, 0); lightRestoreSingle;
    axis image; axis off
    
%     subplot(2, 3, 4);
%     cluster_surf(clpos_data_for_movie, 3, [p4], 'heatmap');

    subplot(2, 3, 5);
    cluster_surf(clpos_data_for_movie, 3, [p3], 'heatmap', refZrange,'colormaps', poscm, negcm);



    drawnow

    mov = addframe(mov,gcf);

    toc
end

% Close
mov = close(mov);



%%
