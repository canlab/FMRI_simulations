function [meanrecipvif, vifs, design_struct] = generate_jittered_er_design(varargin)
% Generate an fMRI design with two temporally dependent events and random
% 'jitter' between event1 and event2 (ISI1) and/or between event2 and
% event1 on the subsequent trial (ISI2).
% 
% NOTE: This version was created for the ABCD MID task, and has not been tested
% on all combinations of all different parameter settings. Use with caution
% for applications beyond this purpose.
%
% Usage:
% -------------------------------------------------------------------------
% [meanrecipvif, vifs, design_struct] = generate_jittered_er_design([optional inputs])
%
% For objects: Type methods(object_name) for a list of special commands
%              Type help object_name.method_name for help on specific
%              methods.
%
% Author and copyright information:
% -------------------------------------------------------------------------
%     Copyright (C) 2015 Tor Wager
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% Inputs: all are optional
% -------------------------------------------------------------------------
% 'noplot',         doplot = 0; 
% 'event1duration', event1duration = next input argument, in seconds
% 'event2duration', event2duration = next input argument, in seconds
% 'ISI2isconstant', keep ITI constant
% 'ISI2isvariable', use variable ITI
% 'isidistribution', 'exponential' [default] or 'geometric'
% 'ISImean',        followed by mean ISI, including ISImin, for exponential only
% 'ISImin'
% 'ISImax'
% 'trialtypes'
% 'trialspertype'
% 'HPlength'
% 'TR'
%
% Outputs:
% -------------------------------------------------------------------------
% meanrecipvif      1 / mean variance inflation factor (VIF).  Higher is better. mean(1 ./ vifs)
% vifs              VIFs for each regressor. Higher is worse, 1 is ideal. This indexes multicolinearity.
% design_struct     variables you need to reconstruct the specific design,
%                   including onsets (ons).  
%                   To reconstruct the design, use X = onsets2fmridesign(ons, TR, ceil(scanlength), 'hrf');
%
% Examples:
% -------------------------------------------------------------------------
%
% [meanrecipvif, vifs, design_struct] = generate_jittered_er_design('ISImean', 2.5);
% print_matrix(design_struct.eventlist, design_struct.eventlist_names);
%
% See also:
% optimizeGA, onsets2fmridesign

% Programmers' notes:
% NOTE: This version was created for the ABCD MID task, and has not been tested
% on all combinations of all different parameter settings. Use with caution
% for applications beyond this purpose. - Tor Wager, 12/2015

% -------------------------------------------------------------------------
% DEFAULTS AND INPUTS
% -------------------------------------------------------------------------


% Process Control Parameters
% ----------------------------------
doplot = true;
calc_efficiency = true;

% Fixed Design Parameters
% ----------------------------------

% we want to get 10 trials/condition in 5 mins -
% so, 20 trials/condition total across 2 5-min runs

event1duration = 2;    % duration of cue
event2duration = 2;    % duration of feedback
trialtypes = 5;        % neutral, 2 levels of loss, 2 levels of gain
trialspertype = 20;
ISI2isconstant = 1;    % ITI is constant (as opposed to jittered).
ISI2constantvalue = 0; % in seconds, used only if ISI2isconstant

% All ISI times in sec.
isidistribution = 'exponential';  % 'exponential' or 'geometric'
ISImin = 1.5;           % Constraints: Psychological (can subjects process cue) and statistical (longer = less BOLD nonlinearity, which is difficult to model).
ISImean = 2;            % For 'exponential' only.  Includes ISImin.  There is an optimal empirical value -- longer is better for deconvolution/FIR, but we also need to fit within total scan time constraints.
ISIstep = .65;          % For 'geometric' only.  There is an optimal empirical value -- longer is better for deconvolution/FIR, but we also need to fit within total scan time constraints.
ISImax = 6;             % Truncate to avoid VERY long ISIs

% Assumptions about TR and scanning params
% Used in plotting and design construction: Will downsample to TR
TR = 2;

% high-pass filter
HPlength = 128;         % default HP filter in sec

% optional inputs with default values
% -----------------------------------

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}

            case 'noplot', doplot = 0; 
                
            case 'event1duration', event1duration = varargin{i+1}; varargin{i+1} = [];
            case 'event2duration', event2duration = varargin{i+1}; varargin{i+1} = [];
                
            case 'ISI2isconstant', ISI2isconstant = 1;
            case 'ISI2isvariable', ISI2isconstant = 0;
                
            case 'isidistribution', isidistribution = varargin{i+1}; varargin{i+1} = [];
                
            case 'ISImin', ISImin = varargin{i+1}; varargin{i+1} = [];
            case 'ISImean', ISImean = varargin{i+1}; varargin{i+1} = [];
            case 'ISImax', ISImax = varargin{i+1}; varargin{i+1} = [];

            case 'trialtypes', trialtypes = varargin{i+1}; varargin{i+1} = []; 
            case 'trialspertype', trialspertype = varargin{i+1}; varargin{i+1} = [];

            case 'HPlength', HPlength = varargin{i+1}; varargin{i+1} = [];
            case 'TR', TR = varargin{i+1}; varargin{i+1} = [];
                
            case 'contrasts' % do nothing, handle later after we know trial types
                
            otherwise, warning(['Unknown input string option:' varargin{i}]);
        end
    end
end

% Custom parameters whose defaults depend on user input

% Default contrasts
contrasts = eye(trialtypes); 
contrastweights = ones(1, trialtypes);

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
 
            case 'contrasts', contrasts = varargin{i+1}; varargin{i+1} = [];
                
            case 'contrastweights', contrastweights = varargin{i+1}; varargin{i+1} = [];
                
            % otherwise, warning(['Unknown input string option:' varargin{i}]);
        end
    end
end

% -------------------------------------------------------------------------
% GENERATE ISIs
% -------------------------------------------------------------------------

if doplot
    f1 = create_figure('diagnostic plots', 1, 3);
end

ntrials = trialspertype .* trialtypes;

switch isidistribution
    
    case 'exponential'
        % truncated exponential, in sec
        % -----------------------------------
        ISI1 = ISImin + exprnd(ISImean - ISImin, ntrials, 1);  % one column for fixed ISI, two cols for variable
        ISI1(ISI1 > ISImax) = ISImax;
        
        if ~ISI2constantvalue  % variable ITI/ISI2
            ISI2 = ISImin + exprnd(ISImean - ISImin, ntrials, 1);
            ISI2(ISI2 > ISImax) = ISImax;
            
        end
        
        if doplot
            figure(f1);
            [h, x] = hist(ISI1);
            bar(x, h);
            set(gca, 'XTick', 1:10);
            xlabel('ISI'), axis tight
            title('Empirical distribution of ISI1');
        end
        
        
    case 'geometric'
        % geometric distribution of ISIs
        % -----------------------------------
        
        x = [ISImin:ISIstep:9];
        p = geopdf(0:length(x)-1, .5);
        
        fprintf('Mean ISI is %3.2f\n', x*p');  % mean = 2.24 secs
        
        if doplot
            figure(f1);
            
            bar(p); set(gca, 'XTick', 1:10, 'XTickLabel', x);
            xlabel('ISI'), axis tight
            title('Generating distribution of ISIs');
        end
        
        % create list for actual selection
        clear ISI1 ISI2
        for i = 1:length(x)
            
            ISI1{i} = repmat(x(i), round(1000*p(i)), 1);
            
            ISI2{i} = repmat(x(i), round(1000*p(i)), 1);
            
        end
        
        ISI1 = cat(1, ISI1{:});
        ISI2 = cat(1, ISI2{:});  % Only used if ISI2constantvalue is false.
        
end  % ISI distribution


%%

clear ons finalISI* trialtype trialduration

% Build ALL trials
% Balance (better) or randomize (here) ISIs within trial types.

for i = 1:trialtypes
    
    % Select actual ISIs at random from distribution
    ISI1 = ISI1(randperm(length(ISI1)));
    ISI2 = ISI2(randperm(length(ISI2)));
    
    finalISI1{i} = ISI1(1:trialspertype);
    finalISI2{i} = ISI2(1:trialspertype);
    
    if ISI2isconstant
        
        finalISI2{i} = ISI2constantvalue * ones(size(finalISI2{i}));
    end
    
    trialtype{i} = i * ones(trialspertype, 1);
    trialduration{i} = event1duration + finalISI1{i} + event2duration + finalISI2{i};
    
end

ntrials = length(cat(1, trialtype{:}));

finalISI1 = cat(1, finalISI1{:});
finalISI2 = cat(1, finalISI2{:});
trialtype = cat(1, trialtype{:});
trialduration = cat(1, trialduration{:});

% randomize trial order
trialorder = randperm(ntrials);
finalISI1 = finalISI1(trialorder);
finalISI2 = finalISI2(trialorder);
trialtype = trialtype(trialorder);
trialduration = trialduration(trialorder);

% build overall list of onsets
onsets = cumsum([0; trialduration]);
onsets = onsets(1:end - 1);

% scan length (in sec) must be even multiple of the TR
scanlength = TR * ceil((onsets(end) + trialduration(end)) ./ TR);

if doplot
    fprintf('Total scan length is %3.2f secs\n', scanlength);
end

% Separate into onsets for each event type
clear ons ons2

for i = 1:trialtypes
    
    ons{i} = onsets(trialtype == i);
    
    ons2{i} = ons{i} + event1duration + finalISI1(trialtype == i);
    
    
end

ons = [ons ons2];

% Build design and get quality metrics
% ---------------------------------------------


% The code for lines below is in the Wagerlab (CANlab) github repository
% It builds the design and has tools for evaluating it as well.

X = onsets2fmridesign(ons, TR, scanlength, 'hrf');
vifs = getvif(X);

% This is a reasonable overall design objective function
% 1 is perfect from a multicolinearity standpoint, 0 is non-identified design matrix
meanrecipvif = mean(1 ./ vifs);

% Save output
% ---------------------------------------------

design_struct = struct('ons', [], 'TR', TR, 'X', X, 'event1duration', event1duration, 'event2duration', event1duration, 'trialtypes', trialtypes, 'trialspertype', trialspertype, 'scanlength', ceil(scanlength));
design_struct.ons = ons;

% Save table 

eventlist = [onsets onsets + event1duration + finalISI1 trialtype finalISI1 finalISI2];
eventlist(:, end+1) = event1duration;
eventlist(:, end+1) = event2duration;

% Note : This would create eventlist from ons cell array. We already have
% it so don't need to reduplicate.  But could be useful elsewhere...
% onsets1 = cat(1, ons{1:trialtypes});
% for i = 1:trialtypes
%     mytype{i} = i * ones(length(ons{i}), 1);
% end
% trialtype2 = cat(1, mytype{:});
% onsets2 = cat(1, ons{trialtypes+1:end});
% 
% eventlist2 = [onsets1 onsets2 trialtype2];
% [~, sortindex] = sort(onsets1, 'ascend');
% 
% eventlist2 = eventlist2(sortindex, :);

design_struct.eventlist_names = {'Event1 onset' 'Event2 onset' 'Trial type' 'ISI1' 'ITI' 'Event1Dur' 'Event2Dur'};
design_struct.eventlist = eventlist;


% Plot
% ---------------------------------------------
if doplot
    
    create_figure('design');
    
    plotDesign(ons, [], TR, 'samefig', 'durs', event1duration);
    
    figure(f1);
    
    subplot(1, 3, 2);
    imagesc(corrcoef(X)); colorbar; set(gca, 'YDir', 'reverse'); axis tight
    title('Pairwise correlations')
    
    subplot(1, 3, 3);
    title('Variance inflation, 1 = ideal');
    
    plot(vifs, 'ko', 'MarkerFaceColor', [1 .5 0], 'MarkerSize', 8);
    plot_horizontal_line(1);
    han = plot_horizontal_line(2); set(han, 'LineStyle', ':');
    
    set(gca, 'YLim', [0 max(vifs)+1], 'XLim', [0 length(vifs)+1]);
    
end

% Efficiency calculation
% ---------------------------------------------
% NOTE: not implemented in original ABCD scripts; for later CANLAB pain opt
% not time-efficient, but convenient, as designs change length
% design_struct.HPlength = HPlength;
% 
% % Expand contrasts: Assume we are interested in ONLY the first event of
% % each trial (stim), not the second (ratings)
% 
% if calc_efficiency
% 
%     xc = load('myscannerxc.mat');
%     [S,~,svi] = getSmoothing(design_struct.HPlength, 0, design_struct.TR, design_struct.scanlength, xc.myscannerxc);
%     
%     [eff,eff_vector] = calcEfficiency(contrastweights,contrasts,pinv(X),svi);
%     
%end % efficiency

% -------------------------------------------------------------------------

end % main function


