names = {'CueH_LowI_cue' 'CueH_medI_cue' 'CueH_HiI_cue' 'CueL_LowI_cue' 'CueL_medI_cue' 'CueL_HiI_cue' ...
    'CueH_LowI_s' 'CueH_medI_s' 'CueH_HiI_s' 'CueL_LowI_s' 'CueL_medI_s' 'CueL_HiI_s'};

connames = {'CueHvL_cue' 'CueHvL_stim' 'StimLvH_stim' 'Cue_x_stim_stim'};

cons = [1 1 1 -1 -1 -1 0 0 0 0 0 0;  % CueHvL_cue
    0 0 0 0 0 0 1 1 1 -1 -1 -1; % CueHvL_stim
    0 0 0 0 0 0 1 0 -1 1 0 -1];   % StimLvH_stim

cons(4, :) = cons(2, :) .* cons(3, :); % Cue_x_stim_stim

cons = cons';

%% Vanilla - HRF is exactly correct, no epochs

true_eff_size = [0.1 0.3 0.5 0.7 1 1.3 1.5 1.8 2];
OUT = {};

for i = 1:length(true_eff_size)
    
    fprintf('%d ', i)
    
    OUT{i} = onsets2power(best_design_struct.ons, 'TR', best_design_struct.TR, 'contrasts', cons, 'n_iter', 50, 'true_effect_size', true_eff_size(i));
    
end

%

for i = 1:length(true_eff_size)
    
    power05(i, :) = OUT{i}.contrasts.power_est05;
    
    power001(i, :) = OUT{i}.contrasts.power_est001;
    
    powerfwer(i, :) = OUT{i}.contrasts.power_estfwer;
    
end

create_figure('con power', 1, 3);
plot(true_eff_size, power05);
xlabel('True effect size');
ylabel('Power');
axis tight;
set(gca, 'YLim', [0 1]);
legend(connames)

subplot(1, 3, 2)
plot(true_eff_size, power001);
xlabel('True effect size');
ylabel('Power');
axis tight;
set(gca, 'YLim', [0 1]);

subplot(1, 3, 3)
plot(true_eff_size, powerfwer);
xlabel('True effect size');
ylabel('Power');
axis tight;
set(gca, 'YLim', [0 1]);

drawnow

%% With HRF mismodeling, no epochs

true_eff_size = [0.1 0.3 0.5 0.7 1 1.3 1.5 1.8 2];
OUThrfmis = {};

for i = 1:length(true_eff_size)
    
    fprintf('%d ', i)
    
    OUThrfmis{i} = onsets2power(best_design_struct.ons, 'TR', best_design_struct.TR, 'hrfshape', 'contrasts', cons, 'n_iter', 50, 'true_effect_size', true_eff_size(i));
    
end

%

for i = 1:length(true_eff_size)
    
    power05(i, :) = OUThrfmis{i}.contrasts.power_est05;
    
    power001(i, :) = OUThrfmis{i}.contrasts.power_est001;
    
    powerfwer(i, :) = OUThrfmis{i}.contrasts.power_estfwer;
    
end

create_figure('con power with hrf misspec', 1, 3);
plot(true_eff_size, power05);
xlabel('True effect size');
ylabel('Power');
axis tight;
set(gca, 'YLim', [0 1]);
legend(connames)

subplot(1, 3, 2)
plot(true_eff_size, power001);
xlabel('True effect size');
ylabel('Power');
axis tight;
set(gca, 'YLim', [0 1]);

subplot(1, 3, 3)
plot(true_eff_size, powerfwer);
xlabel('True effect size');
ylabel('Power');
axis tight;
set(gca, 'YLim', [0 1]);

drawnow


%% Vary number of trials in design

true_eff_size = 0.3;
pow = zeros(12, size(cons, 2));

for i = 1:12
    
    fprintf('First %d trials. ', i)
    
    % Get first i trials only
    ons = cellfun(@(x) x(1:i), best_design_struct.ons, 'UniformOutput', false);
    
    outstruct = onsets2power(ons, 'TR', best_design_struct.TR, 'hrfshape', 'contrasts', cons, 'n_iter', 200, 'true_effect_size', true_eff_size);
    
    pow(i, :) = outstruct.contrasts.power_est;
    
    disp('Done.')
    
end

create_figure('mean con power vs num trials');
plot(pow, 'o-', 'MarkerFaceColor', [.5 .5 1], 'LineWidth', 3);

xlabel('First n trials');
ylabel('Power, true d = 0.3');

%% Try some random ER designs as a function of some parameters

% Generate a random ER design with 4 trial types, 2 events per trial (cue and stim), and 12 trials per type
% (regressors are organized with cue regressors for all types, then stim regs for all types)
% default TR = 2. many parameters can be altered with inputs, including spacing of events.
[meanrecipvif, vifs, design_struct] = generate_jittered_er_design('ISImean', 2.5, 'trialtypes', 4, 'trialspertype', 12);

[X,d,out,handles] = plotDesign(design_struct.ons, [], 2);

%% Power simulation as a function of number of trials
% For every iteration, generate a new random design and a new noise vector

% Here, we look at 1:n trials, allowing the run to grow with trial number (longer scan)

% Set contrasts
c = [1 -1 0 0 1 -1 0 0 ;
    0  0 1 -1 0 0 1 -1 ;
    1 -1 1 -1 0 0 0 0 ;
    0 0 0 0 1 -1 1 -1 ;
    ]';

true_eff_size = 0.2;   % Signal magnitude
ntrials = 20;          % simulate over 1:n trials
niter = 100;           % how many noise iterations for a given design for power estimates
ndesigns = 10;         % how many different random designs to average over

pow_hrfok = zeros(ntrials, ndesigns);
pow_hrfmisspec = zeros(ntrials, ndesigns);

for j = 1:ndesigns
    
    for i = 1:ntrials
        
        fprintf('First %d trials. ', i)
        
        % Generate a single novel design
        [meanvif, ~, design_struct] = generate_jittered_er_design('ISImean', 2.5, 'trialtypes', 4, 'trialspertype', i, 'noplot');
        
        len(i, 1) = design_struct.scanlength;
        
        % Simulate power with 100 noise vectors (very rough estimate)
        % With HRF misspec
        outstruct = onsets2power(design_struct.ons, 'TR', best_design_struct.TR, 'hrfshape', 'contrasts', c, 'n_iter', niter, 'true_effect_size', true_eff_size);
        
        pow_hrfmisspec(i, j) = mean(outstruct.contrasts.power_est, 2);
        
        % Without HRF misspec
        outstruct = onsets2power(design_struct.ons, 'TR', best_design_struct.TR, 'contrasts', c, 'n_iter', niter, 'true_effect_size', true_eff_size);
        
        pow_hrfok(i, j) = mean(outstruct.contrasts.power_est, 2);
        
        
        disp('Done.')
        
    end % trials loop
    
end % designs loop

create_figure('mean con power vs num trials');
plot(mean(pow_hrfok, 2), 'o-', 'MarkerFaceColor', [.5 .5 1], 'LineWidth', 3);
plot(mean(pow_hrfmisspec, 2), 'o-', 'MarkerFaceColor', [1 .5 1], 'LineWidth', 3);

xlabel('First n trials');
ylabel('Power, true d = 0.2');
legend({'HRF correct' 'HRF misspec'})

%% Vary spacing of design
% Variable event spacing for a design with 12 events per type, allowing the length to grow as spacing increases
 
% For every iteration, generate a new random design and a new noise vector

% Here, we look at mean ISI

% Set contrasts
% c = [1 -1 0 0 1 -1 0 0 ;
%     0  0 1 -1 0 0 1 -1 ;
%     1 -1 1 -1 0 0 0 0 ;
%     0 0 0 0 1 -1 1 -1 ;
%     ]';

c = eye(8);

isimeans = [.5:3.5 5:2:20];  % Mean ISI (variable)
true_eff_size = 0.2;   % Signal magnitude
ntrials = 12;          % simulate over 1:n trials
niter = 100;           % how many noise iterations for a given design for power estimates
ndesigns = 10;         % how many different random designs to average over

pow_hrfok = zeros(length(isimeans), ndesigns);
pow_hrfmisspec = zeros(length(isimeans), ndesigns);
len = zeros(length(isimeans), ndesigns);

for j = 1:ndesigns
    
    for i = 1:length(isimeans)
        
        fprintf('ISI %3.2f. ', isimeans(i))
        
        % Generate a single novel design
        [meanvif, ~, design_struct] = generate_jittered_er_design('ISImean', isimeans(i), 'ISImin', 0.1, 'ISImax', 20, 'trialtypes', 4, 'trialspertype', ntrials, 'noplot');
        
        if j == 1
            create_figure('Design plot');
            [X,d,out,handles] = plotDesign(design_struct.ons, [], 2, 'samefig');
            set(gca, 'XLim', [0 450])
            drawnow
        end
        
        len(i, j) = design_struct.scanlength;
        
        % Simulate power with 100 noise vectors (very rough estimate)
        % With HRF misspec
        outstruct = onsets2power(design_struct.ons, 'TR', best_design_struct.TR, 'hrfshape', 'contrasts', c, 'n_iter', niter, 'true_effect_size', true_eff_size);
        
        pow_hrfmisspec(i, j) = mean(outstruct.contrasts.power_est, 2);
        
        % Without HRF misspec
        outstruct = onsets2power(design_struct.ons, 'TR', best_design_struct.TR, 'contrasts', c, 'n_iter', niter, 'true_effect_size', true_eff_size);
        
        pow_hrfok(i, j) = mean(outstruct.contrasts.power_est, 2);
        
        
        disp('Done.')
        
    end % trials loop
    
end % designs loop

create_figure('mean con power vs num trials');
plot(mean(len, 2), mean(pow_hrfok, 2), 'o-', 'MarkerFaceColor', [.5 .5 1], 'LineWidth', 3);
plot(mean(len, 2), mean(pow_hrfmisspec, 2), 'o-', 'MarkerFaceColor', [1 .5 1], 'LineWidth', 3);

xlabel('Run length');
ylabel('Power, true d = 0.2');
legend({'HRF correct' 'HRF misspec'})

%% Vary spacing of design
% Variable event spacing, keeping length constant at 400 sec and packing in
% more vs. fewer trials
 
% For every iteration, generate a new random design and a new noise vector

% Here, we look at mean ISI

% Set contrasts
% c = [1 -1 0 0 1 -1 0 0 ;
%     0  0 1 -1 0 0 1 -1 ;
%     1 -1 1 -1 0 0 0 0 ;
%     0 0 0 0 1 -1 1 -1 ;
%     ]';

c = eye(8);

isimeans = [.5:3.5 5:2:20];  % Mean ISI (variable)
true_eff_size = 0.2;   % Signal magnitude
ntrials = 30;          % this will be reduced to keep length the same for all....
maxlength = 400;
niter = 100;           % how many noise iterations for a given design for power estimates
ndesigns = 10;         % how many different random designs to average over

pow_hrfok = zeros(length(isimeans), ndesigns);
pow_hrfmisspec = zeros(length(isimeans), ndesigns);
len = zeros(length(isimeans), ndesigns);

for j = 1:ndesigns
    
    for i = 1:length(isimeans)
        
        fprintf('ISI %3.2f. ', isimeans(i))
        
        % Generate a single novel design
        [meanvif, ~, design_struct] = generate_jittered_er_design('ISImean', isimeans(i), 'ISImin', 0.1, 'ISImax', 20, 'trialtypes', 4, 'trialspertype', ntrials, 'noplot');
        
        % restrict to max length
        for x = 1:length(design_struct.ons)
            design_struct.ons{x}(design_struct.ons{x} > maxlength) = [];
        end
        
        if j == 1
            create_figure('Design plot');
            [X,d,out,handles] = plotDesign(design_struct.ons, [], 2, 'samefig');
            set(gca, 'XLim', [0 450])
            drawnow
        end
        
        len(i, j) = design_struct.scanlength;
        
        % Simulate power with 100 noise vectors (very rough estimate)
        % With HRF misspec
        outstruct = onsets2power(design_struct.ons, 'TR', best_design_struct.TR, 'hrfshape', 'contrasts', c, 'n_iter', niter, 'true_effect_size', true_eff_size);
        
        pow_hrfmisspec(i, j) = mean(outstruct.contrasts.power_est, 2);
        
        % Without HRF misspec
        outstruct = onsets2power(design_struct.ons, 'TR', best_design_struct.TR, 'contrasts', c, 'n_iter', niter, 'true_effect_size', true_eff_size);
        
        pow_hrfok(i, j) = mean(outstruct.contrasts.power_est, 2);
        
        
        disp('Done.')
        
    end % trials loop
    
end % designs loop

create_figure('mean con power vs num trials');
plot(isimeans, mean(pow_hrfok, 2), 'o-', 'MarkerFaceColor', [.5 .5 1], 'LineWidth', 3);
plot(isimeans, mean(pow_hrfmisspec, 2), 'o-', 'MarkerFaceColor', [1 .5 1], 'LineWidth', 3);

xlabel('Mean ISI');
ylabel('Power, true d = 0.2');
legend({'HRF correct' 'HRF misspec'})
title('Power for 400 sec, 4 trial types x 2 events per');


%% Vary number of event types
% 4.5 mean ISI event spacing, keeping length constant at 400 sec and packing in
% more vs. fewer trials

trialtypes = 1:9;
isimean = 4.5;        % Mean ISI 
true_eff_size = 0.2;   % Signal magnitude
ntrials = 50;          % this will be reduced to keep length the same for all....
maxlength = 400;
niter = 100;           % how many noise iterations for a given design for power estimates
ndesigns = 10;         % how many different random designs to average over

pow_hrfok = zeros(length(trialtypes), ndesigns);
pow_hrfmisspec = zeros(length(trialtypes), ndesigns);
len = zeros(length(trialtypes), ndesigns);

for j = 1:ndesigns
    
    for i = 1:length(trialtypes)
        
        fprintf('Trial types %d. ', trialtypes(i))
        
        % Contrasts - just condition amplitudes
        c = eye(2 .* trialtypes(i));
        
        % Generate a single novel design
        [meanvif, ~, design_struct] = generate_jittered_er_design('ISImean', isimean, 'ISImin', 0.1, 'ISImax', 20, 'trialtypes', trialtypes(i), 'trialspertype', ntrials, 'noplot');
        
        % restrict to max length
        for x = 1:length(design_struct.ons)
            design_struct.ons{x}(design_struct.ons{x} > maxlength) = [];
        end
        
        if j == 1
            create_figure('Design plot');
            [X,d,out,handles] = plotDesign(design_struct.ons, [], 2, 'samefig');
            set(gca, 'XLim', [0 450])
            drawnow
        end
        
        len(i, j) = design_struct.scanlength;
        
        % Simulate power with 100 noise vectors (very rough estimate)
        % With HRF misspec
        outstruct = onsets2power(design_struct.ons, 'TR', best_design_struct.TR, 'hrfshape', 'contrasts', c, 'n_iter', niter, 'true_effect_size', true_eff_size);
        
        pow_hrfmisspec(i, j) = mean(outstruct.contrasts.power_est, 2);
        
        % Without HRF misspec
        outstruct = onsets2power(design_struct.ons, 'TR', best_design_struct.TR, 'contrasts', c, 'n_iter', niter, 'true_effect_size', true_eff_size);
        
        pow_hrfok(i, j) = mean(outstruct.contrasts.power_est, 2);
        
        
        disp('Done.')
        
    end % trials loop
    
end % designs loop

create_figure('mean con power vs num trials');
plot(trialtypes, mean(pow_hrfok, 2), 'o-', 'MarkerFaceColor', [.5 .5 1], 'LineWidth', 3);
plot(trialtypes, mean(pow_hrfmisspec, 2), 'o-', 'MarkerFaceColor', [1 .5 1], 'LineWidth', 3);

xlabel('Number of trial types');
ylabel('Power, true d = 0.2');
legend({'HRF correct' 'HRF misspec'})
title('Power for 400 sec, 4.5 mean ISI, single-condition contrasts');
