%% SET UP DATA

img = which('scalped_single_subj_T1.img')


V = spm_vol(img); v = spm_read_vols(V);

mm = voxel2mm([1 1 1; size(v)]', V.mat);
xcoords = linspace(mm(1,1), mm(1,2), size(v, 1));
ycoords = linspace(mm(2,1), mm(2,2), size(v, 2));
zcoords = linspace(mm(3,1), mm(3,2), size(v, 3));
v = permute(v,[2 1 3]);


nslices = size(v,3);

[X, Y, Z] = meshgrid(xcoords, ycoords, zcoords); 
% slicedat = v(:,:,wh_slice)';

v = smooth3(v, 'gaussian', [3 3 3], .65) ;

%% SET UP AXIS

figure('Color','w')
view(135,30);

axis vis3d
axis image
lightRestoreSingle(gca)
lighting gouraud
material dull

set(gca,'ZLim',[-70 80], 'XLim', [-70 70], 'YLim', [-110 70]);
axis off
camzoom(1.3)

[az,el]=view;

drawnow



%% SET UP MOVIE

movlength = 3;
mov = [];

axh = gca;

fps = 10;
nframes = movlength .* fps;

if isempty(mov)
    mov = avifile('mymovie.avi','Quality',75,'Compression','None','Fps',fps);
end

% add to existing
%O = struct('add2movie',[],'zoom',1,'azOffset',[],'elOffset',[],'timecourse',[],'fps',5,'length',6);

    
    
        
%%  MAKE SLICES


for slices = 1:nslices

    wh_slice = [slices slices + 1];

    % for full surface reconstruction
% %     FV = isosurface(X(:,:,wh_slice), Y(:,:,wh_slice), Z(:,:,wh_slice), v(:,:,wh_slice), 250000);   
% %     hPatch = patch(FV);
    
    %isonormals(X, Y, Z, v, hPatch);
% %     set(hPatch, 'Tag', 'BrainSurface', 'FaceColor', [.5 .5 .5], 'EdgeColor', 'none', 'FaceAlpha', 1);

    FVC = isocaps(X(:,:,wh_slice), Y(:,:,wh_slice), Z(:,:,wh_slice), v(:,:,wh_slice),250000);
    caphandle = patch(FVC, 'FaceColor', 'interp', 'EdgeColor', 'none');

% %     lighting gouraud
% %     material dull

    %axis image
    drawnow

    H = gca;
    try
        mov = addframe(mov,H);
    catch
        disp('Cannot write frame.  Failed to set stream format??')
        mov = close(mov);
    end

end


%% surface fig of volume


FV = isosurface(X, Y, Z, v, 250000);
hPatch = patch(FV);
isonormals(X, Y, Z, v, hPatch);

set(hPatch, 'Tag', 'BrainSurface', 'FaceColor', [.5 .5 .5], 'EdgeColor', 'none', 'FaceAlpha', 1);
view(135,30);

% axis vis3d
% axis image
lightRestoreSingle(gca)
lighting gouraud
material dull

H = gca;
try
        mov = addframe(mov,H);
    catch
        disp('Cannot write frame.  Failed to set stream format??')
        mov = close(mov);
end
    

%% Close the movie

mov = close(mov);



