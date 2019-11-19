
%% About this simulation:
% 1. specify sim parameters and display properties
% 2. Get graph matrices: getgraph subfunction
% 3. Draw initial graph, then draw the graph frame by frame and write movie frames: drawgraph subfunction
%    (Repeat steps 2 and 3 10 times for random graphs)
% 4. Write movie frames (M) to video file

% getgraph: Input parameters, output link matrices and indices
% drawgraph: (a) Draw initial graph, return graphics handles, and make links invisible
%            (b) Use data in handles to redraw graph frame by frame
%

%% -------------------------------------------------------------------------
% Specify sim parameters and display properties
% -------------------------------------------------------------------------

% Simulation parameters

nnodes = 15;
ntimesteps = 50;                        % not used yet by drawlines below
linkdensity = .17;

% Specify display properties

nodecolor = [.2 .2 .2];
nodefacecolor = 'w';
nodelineweight = 1;
nodesize = 18;

edgecolor = [.5 .5 .5];
edgewidth = .2;

% nodeaccentcolor = [1 .7 .7];
% nodeaccentcolor2 = [1 .85 .7];

nodeaccentcolors = {[1 .7 .7] [1 .85 .7]}; % for new modular functions

%% Get and draw the graph

for i = 1:10
    % Repeat 10 times, for 10 different random graphs
    
    [nodecoords, linkmatrix, whmax, linkmatrix1, indx2, wh2, linkmatrix2] = getgraph(nnodes, linkdensity);
    
    [h, h_node, h2] = draw_initial_graph(nodecoords, linkmatrix1, edgecolor, linkmatrix2, nodesize, nodecolor, nodefacecolor, nodelineweight);

    if i == 1
        
        % M = drawgraph(nodecoords, linkmatrix1, edgecolor, linkmatrix2, nodesize, nodecolor, nodefacecolor, nodelineweight, whmax, indx2, nodeaccentcolor, nodeaccentcolor2);
        
        % Note: The two lines of code below should do the same thing, in a
        % more modular/transparent form:
        
        M = create_movie_frames(h, h_node, h2, whmax, indx2, nodeaccentcolors);

    else
        
        %M_add = drawgraph(nodecoords, linkmatrix1, edgecolor, linkmatrix2, nodesize, nodecolor, nodefacecolor, nodelineweight, whmax, indx2, nodeaccentcolor, nodeaccentcolor2);
        
        M_add = create_movie_frames(h, h_node, h2, whmax, indx2, nodeaccentcolors);
        M = [M M_add];
        
    end
    
end


%% Write video

vidObj = VideoWriter('DynamicGraph.mp4', 'MPEG-4');
vidObj.FrameRate = 12;
open(vidObj);

sz = size(M(1).cdata);
sz = sz(1:2);

for i = 1:length(M)
    
    M(i).cdata = M(i).cdata(1:sz(1), 1:sz(2), :); % crop if needed
    
    writeVideo(vidObj,M(i));
end

% Close the file.
close(vidObj);
disp('Done writing video');

%% ------------------------------------------------------------------------
%
% SUBFUNCTIONS
%
% ------------------------------------------------------------------------
%%

function [nodecoords, linkmatrix, whmax, linkmatrix1, indx2, wh2, linkmatrix2] = getgraph(nnodes, linkdensity)

nodecoords = unifrnd(0, 1, nnodes, 2);  % n x 2 X, Y coordinates for nodes

nlinks = nnodes * (nnodes - 1) ./ 2;
links = zeros(nlinks, 1);
links(unifrnd(0, 1, nlinks, 1) < linkdensity) = 1;

linkmatrix = squareform(links);  % Matrix of random links

%% Calculate stuff for staged display

% Start node, "node 1", with max degree
nodedegree = sum(linkmatrix);
[~, whmax] = max(nodedegree);

% Create matrix of links to node whmax
linkmatrix1 = linktonodesubset(linkmatrix, whmax);

% Next layer of those that link to node 1
indx2 = logical(linkmatrix(whmax, :));
wh2  = find(indx2);
linkmatrix2 = linktonodesubset(linkmatrix, wh2);
linkmatrix2(logical(linkmatrix1)) = 0;

end % function

%%

function [h, h_node, h2] = draw_initial_graph(nodecoords, linkmatrix1, edgecolor, linkmatrix2, nodesize, nodecolor, nodefacecolor, nodelineweight)

% Draw initial graph
% -------------------------------------------------------------------------

create_figure('graph'); hold on;

% Draw links (edges)
h = nmdsfig_tools('drawlines', nodecoords, linkmatrix1, edgecolor);
set(h.hhp, 'Visible', 'off');

axis off

% Draw Stage 2
% -------------------------------------------------------------------------

% Draw links (edges)
h2 = nmdsfig_tools('drawlines', nodecoords, linkmatrix2, edgecolor);
set(h2.hhp, 'Visible', 'off');

% Draw all nodes (on top)
% Plot separately so we can change colors selectively
nnodes = size(nodecoords, 1);

for i = 1:nnodes
    h_node(i) = plot(nodecoords(i, 1), nodecoords(i, 2), 'o', 'markersize', nodesize, 'color', nodecolor, 'markerfacecolor', nodefacecolor, 'linewidth',  nodelineweight);
end

set(gca, 'XLim', [0 1], 'YLim', [0 1]);

axis off

end


%%

function M = create_movie_frames(h, h_node, h2, whmax, indx2, nodeaccentcolors)

% Dynamic: Draw lines time step by time step
% -------------------------------------------------------------------------

set(h_node(whmax), 'MarkerFaceColor', nodeaccentcolors{1}); drawnow;

M = drawDynamicLines(h, 'pause', 0);

set(h_node(whmax), 'MarkerFaceColor', 'w'); drawnow;

set(h_node(indx2), 'MarkerFaceColor', nodeaccentcolors{2}); drawnow;

M = [M drawDynamicLines(h2, 'pause', 0)];

set(h_node(indx2), 'MarkerFaceColor', 'w'); drawnow;


end

%% This combined function does both of the above at once. It's less flexible/transparent, so Tor refactored it to separate the two parts

function M = drawgraph(nodecoords, linkmatrix1, edgecolor, linkmatrix2, nodesize, nodecolor, nodefacecolor, nodelineweight, whmax, indx2, nodeaccentcolor, nodeaccentcolor2)

% Draw initial graph
% -------------------------------------------------------------------------

create_figure('graph'); hold on;

% Draw links (edges)
h = nmdsfig_tools('drawlines', nodecoords, linkmatrix1, edgecolor);
set(h.hhp, 'Visible', 'off');

axis off

% Draw Stage 2
% -------------------------------------------------------------------------

% Draw links (edges)
h2 = nmdsfig_tools('drawlines', nodecoords, linkmatrix2, edgecolor);
set(h2.hhp, 'Visible', 'off');

% Draw all nodes (on top)
% Plot separately so we can change colors selectively
nnodes = size(nodecoords, 1);

for i = 1:nnodes
    h_node(i) = plot(nodecoords(i, 1), nodecoords(i, 2), 'o', 'markersize', nodesize, 'color', nodecolor, 'markerfacecolor', nodefacecolor, 'linewidth',  nodelineweight);
end

set(gca, 'XLim', [0 1], 'YLim', [0 1]);
axis off

% Dynamic: Draw lines time step by time step
% -------------------------------------------------------------------------

set(h_node(whmax), 'MarkerFaceColor', nodeaccentcolor); drawnow;

M = drawDynamicLines(h, 'pause', 0);

set(h_node(whmax), 'MarkerFaceColor', 'w'); drawnow;

set(h_node(indx2), 'MarkerFaceColor', nodeaccentcolor2); drawnow;

M = [M drawDynamicLines(h2, 'pause', 0)];

set(h_node(indx2), 'MarkerFaceColor', 'w'); drawnow;

end

%% These subfunctions help modularize the code in the above functions

function linkmatrix1 = linktonodesubset(linkmatrix, whmax)
% linkmatrix = full link matrix
% whmax = subset of indices to include; integer vector

linkmatrix1 = zeros(size(linkmatrix));
linkmatrix1(whmax, :) = linkmatrix(whmax, :);
linkmatrix1(:, whmax) = linkmatrix(:, whmax);

end

%%

function M = drawDynamicLines(h, varargin)

M = getframe(gca); % Movie, if requested
mypos = get(gca, 'Position');
myxlim = get(gca, 'XLim');
myylim = get(gca, 'XLim');

% ----------------------------------------------------------------------
% Parse inputs
% ----------------------------------------------------------------------

p = inputParser;

% Validation functions - customized for each type of input
% ----------------------------------------------------------------------
valfcn_scalar = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar'});
valfcn_number = @(x) validateattributes(x, {'numeric'}, {'nonempty'}); % scalar or vector

% Optional inputs
% ----------------------------------------------------------------------
% Pattern: keyword, value, validation function handle
p.addParameter('pause', .1, valfcn_number); % can be scalar or vector
p.addParameter('movie', true, @islogical);
% p.addparameter('nodecolor', [1 1 1]); % not used here

% Parse inputs and distribute out to variable names in workspace
% ----------------------------------------------------------------------
p.parse(varargin{:});

IN = p.Results;
% fn = fieldnames(IN);
%
% for i = 1:length(fn)
%     str = sprintf('%s = IN.(''%s'');', fn{i}, fn{i});
%     eval(str)
% end

% ----------------------------------------------------------------------
% Main function
% ----------------------------------------------------------------------

nedges = length(h.hhp);
[X, Y] = deal({});

for i = 1:nedges
    
    % Save original data
    X{i} = get(h.hhp(i), 'XData');
    Y{i} = get(h.hhp(i), 'YData');
    
end

ntimepoints = length(X{1});

set(h.hhp, 'Visible', 'on');

for t = 1:ntimepoints
    
    for i = 1:nedges
        
        % Set data to reveal only 1:t time points
        set(h.hhp(i), 'XData', X{i}(1:t), 'YData', Y{i}(1:t))
        
    end
    
    set(gca, 'Position', mypos, 'XLim', myxlim, 'YLim', myylim); % enforce same position and limits
    
    drawnow
    
    M(end+1) = getframe(gca);
    
    pause(IN.pause);
    
end

end % function


%%


% out = nmdsfig_tools('connect2d', [10 0], [30 10], [1 .5 0], .5, .2, ntimesteps);
% X = out.h.XData;
% Y = out.h.YData;
% set(out.h, 'XData', X(1:5), 'YData', Y(1:5));
% set(out.h, 'XData', X(1:5), 'YData', Y(1:3));
% axis auto
% set(out.h, 'XData', X(1:3), 'YData', Y(1:3));
% set(gca, 'XLim', [min(X) max(X)], 'YLim', [min(Y) max(Y)]);
% for i = 1:length(X)
%     set(out.h, 'XData', X(1:i), 'YData', Y(1:i));
%     drawnow
%     pause(.1)
% end

