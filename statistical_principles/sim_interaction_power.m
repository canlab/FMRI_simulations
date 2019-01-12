% Monte Carlo:
% -------------------------------------

mu = [0 0];
mycov = .5;
Sigma = [1 mycov; mycov 1];

xy = mvnrnd(mu, Sigma, 500);

sz = size(xy);

create_figure('fig'); 
hold on;

title('Predictors')
pthan = plot3(xy(:, 1), xy(:, 2), zeros(sz), 'bo');

%% Rotate

targetaz = 12; 
targetel = 20;
[az, el] = view;
tsteps = 20;
zlim = 5;

az = linspace(az, targetaz, tsteps);
el = linspace(el, targetel, tsteps);

for i = 1:tsteps
    
    view(az(i), el(i));
    set(gca, 'ZLim', [-.1 zlim]);
    axis vis3d
    
    drawnow
    pause(.1)
    
end

%% Draw cylinder
% -------------------------------------
zval = 5;  % bottom of cylinder
zheight = .1; % height
cradius = 25; % radius of cylinder
ccolor = [.3 .9 .4]; 

r = [0 cradius .* ones(1,20) 0];
[X,Y,Z] = cylinder(r, 100);

Z = Z * zheight + zval;

han = surf(X, Y, Z);

lighting gouraud
lightRestoreSingle
set(han, 'EdgeColor', 'none', 'FaceColor', ccolor);
axis vis3d

%%

