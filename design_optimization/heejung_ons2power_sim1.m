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
ylabel('Power, true d = 0.3');
legend({'HRF correct' 'HRF misspec'})
