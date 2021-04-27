%% Set up

f1 = create_figure('surface');
axis off
han = addbrain('coronal_slabs_4'); axis off

axhan = findobj(f1, 'Type', 'axes');

table_list = load_image_set('list');

%% Make each surface rendering and write movie frames

mov = [];

for i = 1:length(table_list.keyword)
    
    [dat, name] = load_image_set(table_list.keyword{i});
    
    han = surface(dat, 'surface_handles', han, 'nolegend');
    
    axes(axhan(5))
    title(strrep(table_list.keyword{i}, '_', ' '));
    
    mov = movie_tools('still', mov, .5);
    
    
    han = addbrain('eraseblobs', han);
    
%     mov = movie_tools('still', mov, .1);
    
end

%% Close video

vidObj = VideoWriter('SignatureSlabs', 'MPEG-4');
vidObj.FrameRate = 5;
open(vidObj);
writeVideo(vidObj,mov);
close(vidObj);

%% Matrix of correlations among all signatures

[dat, names] = load_image_set('all');
plot_correlation_matrix(dat.dat, 'names', table_list.keyword);