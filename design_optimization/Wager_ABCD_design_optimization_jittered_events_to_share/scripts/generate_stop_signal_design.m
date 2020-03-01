function [meanrecipvif, vifs, design_struct] = generate_stop_signal_design(varargin)
% Generate an fMRI design with two temporally dependent events and random
% 'jitter' between event1 and event2 (ISI1) and/or between event2 and
% event1 on the subsequent trial (ISI2).
% 
% NOTE: This version was created for the ABCD stop-signal task
% based on input from Hugh Garavan:
% There are 300 Go and 60 Stop trials and these are split over two runs (ideally an equal split of Go and Stop trials across both).  fMRI timing parameters are: run = 5:55 min, 355.4 sec, 355400 ms, 445 TRs (@800ms, rounding up).
% Currently the task stipulates a minimum of 4 and a maximum of 7 Go trials between each Stop trial.  This was based on the IMAGEN version but it strikes me that this restriction may negatively impact on the ability to generate optimal designs.  (As an aside, it might also make the presentation of a Stop be more predictable than is desirable).  I might be inclined to impose at least one Go between STOPs (lets us calculate post-STOP slowing) but have no other such constraints?
% Currently the inter trial intervals range from 700 to 1090 msec with increments of 15 msec.  Again, we might not have to preserve this restriction if it is an obstacle to generating an optimal design?  
% The one piece of info that I don?t yet have is the remaining timing details for each trial ? that is, the total trial onset intervals.  The intervals in the preceding bullet point refer to just the intervals between trials but you will likely want to know the total duration of each trial.  (I suppose the average can be calculated ? if each run is 355.4 seconds and there are 150 Go and 30 Stop trials per run then that is 1.974 seconds per trial.  However, BJ, are there now 5 seconds of fixation cross at the end of each run ? if so, 350.4/180 trials = 1.947 seconds per trial.  And is there a fixation cross at the start that needs to be accommodated?  (If BJ can?t answer quickly, I?ll dig into the script shortly and send you the details).
%
%
% Usage:
% -------------------------------------------------------------------------
% [meanrecipvif, vifs, design_struct] = generate_stop_signal_design([optional inputs])
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
doplot = 1;

% Fixed Design Parameters
% ----------------------------------

event1duration = 1;    % duration of cue
trialtypes = 2;         % stop, go
trialspertype = [150 30]; % for one run; 300 go, 60 stop total

% All ISI times in sec.
isidistribution = 'exponential';  % 'exponential' or 'geometric'
ISImin = .700;           % Constraints: Psychological (can subjects process cue) and statistical (longer = less BOLD nonlinearity, which is difficult to model).
ISImean = 1.1;          % For 'exponential' only.  Includes ISImin.  There is an optimal empirical value -- longer is better for deconvolution/FIR, but we also need to fit within total scan time constraints.
ISIstep = .1;          % For 'geometric' only.  There is an optimal empirical value -- longer is better for deconvolution/FIR, but we also need to fit within total scan time constraints.
ISImax = 2;             % Truncate to avoid VERY long ISIs

allow_repeats = [1 0];  % Repeats ok for each trial type?  1=go=yes, 2=stop=no

% Needs to be 355 sec per run


%event2duration = 2;    % duration of feedback
%ISI2isconstant = 1;    % ITI is constant (as opposed to jittered).
%ISI2constantvalue = 0; % in seconds, used only if ISI2isconstant

% Assumptions about TR and scanning params
% Used in plotting and design construction: Will downsample to TR
TR = 2;


% optional inputs with default values
% -----------------------------------

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}

            case 'noplot', doplot = 0; 
                
            case 'event1duration', event1duration = varargin{i+1}; varargin{i+1} = [];
            %case 'event2duration', event2duration = varargin{i+1}; varargin{i+1} = [];
                
            %case 'ISI2isconstant', ISI2isconstant = 1;
            %case 'ISI2isvariable', ISI2isconstant = 0;
                
            case 'isidistribution', isidistribution = varargin{i+1}; varargin{i+1} = [];
            case 'ISImean', ISImean = varargin{i+1}; varargin{i+1} = [];
                
            otherwise, warning(['Unknown input string option:' varargin{i}]);
        end
    end
end



% -------------------------------------------------------------------------
% GENERATE ISIs
% -------------------------------------------------------------------------

if doplot
    f1 = create_figure('diagnostic plots', 1, 3);
end

ntrials = sum(trialspertype);

switch isidistribution
    
    case 'exponential'
        % truncated exponential, in sec
        % -----------------------------------
        ISI1 = ISImin + exprnd(ISImean - ISImin, ntrials, 1);  % one column for fixed ISI, two cols for variable
        ISI1(ISI1 > ISImax) = ISImax;
        
%         if ~ISI2constantvalue  % variable ITI/ISI2
%             ISI2 = ISImin + exprnd(ISImean - ISImin, ntrials, 1);
%             ISI2(ISI2 > ISImax) = ISImax;
%             
%         end
        
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
            
%             ISI2{i} = repmat(x(i), round(1000*p(i)), 1);
            
        end
        
        ISI1 = cat(1, ISI1{:});
        ISI2 = cat(1, ISI2{:});  % Only used if ISI2constantvalue is false.
        
end  % ISI distribution


%%

clear ons finalISI* trialtype trialduration

% Build ALL trials
% Balance (better) or randomize (here) ISIs within trial types.
% -------------------------------------------------------------------------

for i = 1:trialtypes
    
    % Select actual ISIs at random from distribution
    ISI1 = ISI1(randperm(length(ISI1)));
%     ISI2 = ISI2(randperm(length(ISI2)));
    
    finalISI1{i} = ISI1(1:trialspertype(i));
%     finalISI2{i} = ISI2(1:trialspertype);
    
%     if ISI2isconstant
%         
%         finalISI2{i} = ISI2constantvalue * ones(size(finalISI2{i}));
%     end
    
    trialtype{i} = i * ones(trialspertype(i), 1);
    trialduration{i} = event1duration + finalISI1{i}; % + event2duration + finalISI2{i};
    
end

ntrials = length(cat(1, trialtype{:}));

finalISI1 = cat(1, finalISI1{:});
% finalISI2 = cat(1, finalISI2{:});
trialtype = cat(1, trialtype{:});
trialduration = cat(1, trialduration{:});

% randomize trial order
% -------------------------------------------------------------------------
trialorder = randperm(ntrials);
finalISI1 = finalISI1(trialorder);
% finalISI2 = finalISI2(trialorder);
trialtype = trialtype(trialorder);
trialduration = trialduration(trialorder);

% constraints: do not allow repeats of trial type 2
% -------------------------------------------------------------------------

trialtype = constrain_avoid_repeats(trialtype, trialtypes, allow_repeats);



% build overall list of onsets
% -------------------------------------------------------------------------

onsets = cumsum([0; trialduration]);
onsets = onsets(1:end - 1);

scanlength = onsets(end) + trialduration(end);

if doplot
    fprintf('Total scan length is %3.2f secs\n', scanlength);
end

% Separate into onsets for each event type
clear ons ons2

for i = 1:trialtypes
    
    ons{i} = onsets(trialtype == i);
    
%     ons2{i} = ons{i} + event1duration + finalISI1(trialtype == i);
    
    
end

% ons = [ons ons2];

% Build design and get quality metrics
% ---------------------------------------------


% The code for lines below is in the Wagerlab (CANlab) github repository
% It builds the design and has tools for evaluating it as well.

X = onsets2fmridesign(ons, TR, ceil(scanlength), 'hrf');
vifs = getvif(X);

% This is a reasonable overall design objective function
% 1 is perfect from a multicolinearity standpoint, 0 is non-identified design matrix
meanrecipvif = mean(1 ./ vifs);

% Save output
% ---------------------------------------------

design_struct = struct('ons', [], 'TR', TR, 'event1duration', event1duration, 'trialtypes', trialtypes, 'trialtype_list', trialtype, 'trialspertype', trialspertype, 'scanlength', ceil(scanlength));
design_struct.ons = ons;

% Save table 

eventlist = [onsets trialtype finalISI1];
eventlist(:, end+1) = event1duration;
% eventlist(:, end+1) = event2duration;

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

design_struct.eventlist_names = {'Event1 onset' 'Trial type' 'ISI1' 'Event1Dur'};
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

end % main function



% ---------------------------------------------
% SUBFUNCTIONS
% ---------------------------------------------


function trialtype = constrain_avoid_repeats(trialtype, trialtypes, allow_repeats)

for i = 1:trialtypes
    
    % skip this if repeats are OK
    if allow_repeats(i), continue, end
    
    % find repeats to swap out
    repeats = find(all([trialtype == i [0; trialtype(1:end-1) == i]], 2));  % trial is an i and preceding trial is an i...move these
    
    k = length(repeats);
    
    % find eligible trials with no adjacent trials of the same type, to
    % swap with
    eligible = find(all([trialtype ~= 2 [0; trialtype(1:end-1) ~= 2] [trialtype(2:end) ~= 2; 0]], 2));
    
    eligible = eligible(randperm(length(eligible)));  % randomize which we choose; take first k (length repeats)
    
    replacements = eligible(k+1:end);

    eligible = eligible(1:k);

    % avoid sequential eligible trials to avoid placing two repeats next to one another
    [sorted_eligible, indx] = sort(eligible);
    wh_replace = indx(diff(sorted_eligible) == 1);
    
    for j = 1:length(wh_replace)
        
        rindx = 1;
        isok = 0;
        
        while ~isok
            
        candidate = replacements(rindx);
        isok = ~any(abs(eligible - candidate) == 1);
        rindx = rindx + 1;
        
        end
        
        eligible(wh_replace(j)) = candidate;
        
    end
    
    
    if length(repeats) > length(eligible)
        warning(sprintf('too many trials of type %3.0f to avoid repeats. skipping constraint.', i));
        continue
    end
    
    % swap repeat with a non-repeat trial
    for j = 1:k
        
        oldtype = trialtype(repeats(j));
        newtype = trialtype(eligible(j));
        
        trialtype(repeats(j)) = newtype;
        trialtype(eligible(j)) = oldtype;
        
       
    end
    
    
end

end % function


