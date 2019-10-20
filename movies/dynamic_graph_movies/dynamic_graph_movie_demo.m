nnodes = 15;
ntimesteps = 50;                        % not used yet by drawlines below
nodecoords = unifrnd(0, 1, nnodes, 2);  % n x 2 X, Y coordinates for nodes

linkdensity = .5;

nlinks = nnodes * (nnodes - 1) ./ 2;
links = zeros(nlinks, 1);
links(unifrnd(0, 1, nlinks, 1) > linkdensity) = 1;

linkmatrix = squareform(links);  % Matrix of random links

%% Specify display properties

nodecolor = [.2 .2 .2];
nodefacecolor = 'w';
nodelineweight = 2;
nodesize = 18;

edgecolor = [.5 .5 .5];
edgewidth = .2;

%% Draw initial graph

create_figure('graph'); hold on;

% Draw links (edges)

h = nmdsfig_tools('drawlines', nodecoords, linkmatrix, edgecolor);

    % function handles_out = drawlines(pc,sigmat,[color],[style],[bendval])

% Draw nodes (on top)

h_node = plot(nodecoords(:, 1), nodecoords(:, 2), 'o', 'markersize', nodesize, 'color', nodecolor, 'markerfacecolor', nodefacecolor, 'linewidth',  nodelineweight);
 
axis off

%% Dynamic: Draw lines time step by time step

drawDynamicLines(h, 'pause', .1)


%%
function drawDynamicLines(h, varargin)

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
p.addParameter('movie', 0, @islogical);

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

for t = 1:ntimepoints
    
    for i = 1:nedges
        
        % Set data to reveal only 1:t time points
        set(h.hhp(i), 'XData', X{i}(1:t), 'YData', Y{i}(1:t))
        
    end
    
    drawnow
    
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

