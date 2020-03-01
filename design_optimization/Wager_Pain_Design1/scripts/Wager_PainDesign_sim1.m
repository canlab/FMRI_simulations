% Default parameters

IN.event1duration = 8;    % duration of stim event
IN.event2duration = 5;    % duration of rating event
IN.trialtypes = 6;        % 2 (body site) x 3 (stim type)
IN.trialspertype = 8;
IN.ISI2isconstant = 0;    % ITI is constant (as opposed to jittered).
IN.ISI2constantvalue = 0; % in seconds, used only if ISI2isconstant
IN.isidistribution = 'exponential';  % 'exponential' or 'geometric'
IN.ISImin = 1;             % Constraints: Psychological (can subjects process cue) and statistical (longer = less BOLD nonlinearity, which is difficult to model).
%IN.ISImean = 5;            % For 'exponential' only.  Includes ISImin.  There is an optimal empirical value -- longer is better for deconvolution/FIR, but we also need to fit within total scan time constraints.
IN.ISImax = 16;            % Truncate to avoid VERY long ISIs

%% Simulation 1: Look at effects of ISI mean on design quality and scan time
% --------------------------------------------------------------------------

iter = 100;

ISImeans = [1.5:.5:10];
nISIs = length(ISImeans);

[meanrecipvif, des_efficiency, scanduration] = deal(zeros(iter, nISIs));

for k = 1:nISIs
    
    for i = 1:iter
        
        [meanrecipvif(i, k), vifs, design_struct] = generate_jittered_er_design_pain_plus_rating(IN, 'noplot', 'ISImean', ISImeans(k));
        
        des_efficiency(i, k) = design_struct.efficiency;
        
        scanduration(i, k) = design_struct.scanlength;
        
    end
    
end

SIM1.IN = IN;
SIM1.meanrecipvif = meanrecipvif;
SIM1.des_efficiency = des_efficiency;
SIM1.scanduration = scanduration;

% Notes:
% - For design of fixed number of trials, predictor variance is constant across ISI
% - meanrecipvif =~ 1/mean(vif) is highly related to efficiency
% - efficiency per unit time is sensible metric for optimizing ISIs
% - but with "contrasts" based on simple event betas, less rest/jitter and
% more trials is likely to always be better, as individual regressors are likely to
% be relatively orthogonal anyway. jitter is going to help de-conflate
% effects (decorrelate event betas) when times between events are very
% short, and/or allow for flexible model fits, but there is little
% advantage with canonical HRF. 
% - jitter will help with (1) event vs rest contrast, (2) flexible HRFs,
% (3) nonlinearity.
% - for calculating efficiency per unit time and optimal tradeoff points,
% the linearity (and scale) of how efficiency relates to power is also important. if
% efficiency is 1/(design related component of the variance). so
% sqrt(efficiency) is linearly related to the standard error of the contrasts, but 
% non-linearly related to power. 
% - normalizing of contrastweights to mean 1 also matters for
% linearity/scale. 


%%

create_figure('Design efficiency', 2, 2);

lineplot_columns(1./SIM1.meanrecipvif, 'markerfacecolor', [.5 .5 1], 'x', ISImeans);
title('Design colinearity: Higher is worse');
xlabel('ISI mean');
ylabel('Harmonic mean of VIFs');

subplot(2, 2, 2);

lineplot_columns(SIM1.scanduration, 'markerfacecolor', [0 .5 1], 'x', ISImeans);
title('Scan duration (2 runs together)');
xlabel('ISI mean');
ylabel('Duration (sec)');
plot_horizontal_line(600);

subplot(2, 2, 3);

lineplot_columns(SIM1.des_efficiency .^ .5, 'markerfacecolor', [.5 .5 1], 'x', ISImeans);
title('sqrt(Design efficiency): Higher is better');
xlabel('ISI mean');
ylabel('sqrt(Efficiency) (simple event contrasts)');

subplot(2, 2, 4);

lineplot_columns(100 .* SIM1.des_efficiency .^ .5 ./ SIM1.scanduration, 'markerfacecolor', [.5 .5 1], 'x', ISImeans);
title('Design efficiency per 100 sec');
xlabel('ISI mean');
ylabel('sqrt(Efficiency) (simple event contrasts)');

create_figure('VIF vs. Design efficiency'); 
plot(SIM1.meanrecipvif(:), sqrt(SIM1.des_efficiency(:)), 'k.');
xlabel('mean(1/vif)'); ylabel('sqrt(efficiency)');

create_figure('scan duration vs. efficiency'); 
plot(SIM1.scanduration(:), sqrt(SIM1.des_efficiency(:)), 'k.');
xlabel('scan duration (s)'); ylabel('sqrt(efficiency)');


%% Simulation 2: Add designs with more trials
% --------------------------------------------------------------------------
IN.event1duration = 8;    % duration of stim event
IN.event2duration = 5;    % duration of rating event
IN.trialtypes = 6;        % 2 (body site) x 3 (stim type)
IN.trialspertype = 10;    % ***ALTERED THIS FROM SIM1***
IN.ISI2isconstant = 0;    % ITI is constant (as opposed to jittered).
IN.ISI2constantvalue = 0; % in seconds, used only if ISI2isconstant
IN.isidistribution = 'exponential';  % 'exponential' or 'geometric'
IN.ISImin = 1;             % Constraints: Psychological (can subjects process cue) and statistical (longer = less BOLD nonlinearity, which is difficult to model).
%IN.ISImean = 5;            % For 'exponential' only.  Includes ISImin.  There is an optimal empirical value -- longer is better for deconvolution/FIR, but we also need to fit within total scan time constraints.
IN.ISImax = 16;            % Truncate to avoid VERY long ISIs

iter = 100;

ISImeans = [1.5:.5:10];
nISIs = length(ISImeans);

[meanrecipvif, des_efficiency, scanduration] = deal(zeros(iter, nISIs));

for k = 1:nISIs
    
    for i = 1:iter
        
        [meanrecipvif(i, k), vifs, design_struct] = generate_jittered_er_design_pain_plus_rating(IN, 'noplot', 'ISImean', ISImeans(k));
        
        des_efficiency(i, k) = design_struct.efficiency;
        
        scanduration(i, k) = design_struct.scanlength;
        
    end
    
end

SIM2.IN = IN;
SIM2.meanrecipvif = meanrecipvif;
SIM2.des_efficiency = des_efficiency;
SIM2.scanduration = scanduration;

f = findobj('Type', 'Figure', 'Tag', 'Design efficiency');
figure(f); hold on; 

newcolor = [.7 .2 .2];
newcolor2 = [1 .5 .5];

subplot(2, 2, 1); hold on;
lineplot_columns(1./SIM2.meanrecipvif, 'color', newcolor, 'markerfacecolor', newcolor2, 'x', ISImeans);

subplot(2, 2, 2); hold on;
lineplot_columns(SIM2.scanduration, 'color', newcolor, 'markerfacecolor', newcolor2, 'x', ISImeans);

subplot(2, 2, 3); hold on;
lineplot_columns(SIM2.des_efficiency .^ .5, 'color', newcolor, 'markerfacecolor', newcolor2, 'x', ISImeans);

subplot(2, 2, 4); hold on;
lineplot_columns(100 .* SIM2.des_efficiency .^ .5 ./ SIM1.scanduration, 'color', newcolor, 'markerfacecolor', newcolor2, 'x', ISImeans);

f = findobj('Type', 'Figure', 'Tag', 'VIF vs. Design efficiency');
figure(f); hold on; 
plot(SIM2.meanrecipvif(:), sqrt(SIM2.des_efficiency(:)), '.', 'color', newcolor2);

f = findobj('Type', 'Figure', 'Tag', 'scan duration vs. efficiency');
figure(f); hold on;
plot(SIM2.scanduration(:), sqrt(SIM2.des_efficiency(:)), 'r.', 'color', newcolor2);

% 10 min, 20 min, 30 min task time
hh = plot_vertical_line(600); set(hh, 'LineStyle', ':');
hh = plot_vertical_line(1200); set(hh, 'LineStyle', ':');
hh = plot_vertical_line(1800); set(hh, 'LineStyle', ':');

%% Simulation 3: Add designs with more trials
% --------------------------------------------------------------------------
IN.event1duration = 8;    % duration of stim event
IN.event2duration = 5;    % duration of rating event
IN.trialtypes = 6;        % 2 (body site) x 3 (stim type)
IN.trialspertype = 12;    % ***ALTERED THIS FROM SIM1***
IN.ISI2isconstant = 0;    % ITI is constant (as opposed to jittered).
IN.ISI2constantvalue = 0; % in seconds, used only if ISI2isconstant
IN.isidistribution = 'exponential';  % 'exponential' or 'geometric'
IN.ISImin = 1;             % Constraints: Psychological (can subjects process cue) and statistical (longer = less BOLD nonlinearity, which is difficult to model).
%IN.ISImean = 5;            % For 'exponential' only.  Includes ISImin.  There is an optimal empirical value -- longer is better for deconvolution/FIR, but we also need to fit within total scan time constraints.
IN.ISImax = 16;            % Truncate to avoid VERY long ISIs

iter = 100;

ISImeans = [1.5:.5:10];
nISIs = length(ISImeans);

[meanrecipvif, des_efficiency, scanduration] = deal(zeros(iter, nISIs));

for k = 1:nISIs
    
    for i = 1:iter
        
        [meanrecipvif(i, k), vifs, design_struct] = generate_jittered_er_design_pain_plus_rating(IN, 'noplot', 'ISImean', ISImeans(k));
        
        des_efficiency(i, k) = design_struct.efficiency;
        
        scanduration(i, k) = design_struct.scanlength;
        
    end
    
end

SIM3.IN = IN;
SIM3.meanrecipvif = meanrecipvif;
SIM3.des_efficiency = des_efficiency;
SIM3.scanduration = scanduration;

f = findobj('Type', 'Figure', 'Tag', 'Design efficiency');
figure(f); hold on; 

newcolor = [.2 .7 .2];
newcolor2 = [.5 1 .5];

subplot(2, 2, 1); hold on;
lineplot_columns(1./SIM3.meanrecipvif, 'color', newcolor, 'markerfacecolor', newcolor2, 'x', ISImeans);

subplot(2, 2, 2); hold on;
lineplot_columns(SIM3.scanduration, 'color', newcolor, 'markerfacecolor', newcolor2, 'x', ISImeans);

subplot(2, 2, 3); hold on;
lineplot_columns(SIM3.des_efficiency .^ .5, 'color', newcolor, 'markerfacecolor', newcolor2, 'x', ISImeans);

subplot(2, 2, 4); hold on;
lineplot_columns(100 .* SIM3.des_efficiency .^ .5 ./ SIM1.scanduration, 'color', newcolor, 'markerfacecolor', newcolor2, 'x', ISImeans);

f = findobj('Type', 'Figure', 'Tag', 'VIF vs. Design efficiency');
figure(f); hold on; 
plot(SIM3.meanrecipvif(:), sqrt(SIM3.des_efficiency(:)), '.', 'color', newcolor2);

f = findobj('Type', 'Figure', 'Tag', 'scan duration vs. efficiency');
figure(f); hold on;
plot(SIM3.scanduration(:), sqrt(SIM3.des_efficiency(:)), 'r.', 'color', newcolor2);

% 10 min, 20 min, 30 min task time
hh = plot_vertical_line(600); set(hh, 'LineStyle', ':');
hh = plot_vertical_line(1200); set(hh, 'LineStyle', ':');
hh = plot_vertical_line(1800); set(hh, 'LineStyle', ':');

%% Simulation 4: Add designs with more trials
% --------------------------------------------------------------------------
IN.event1duration = 8;    % duration of stim event
IN.event2duration = 5;    % duration of rating event
IN.trialtypes = 6;        % 2 (body site) x 3 (stim type)
IN.trialspertype = 14;    % ***ALTERED THIS FROM SIM1***
IN.ISI2isconstant = 0;    % ITI is constant (as opposed to jittered).
IN.ISI2constantvalue = 0; % in seconds, used only if ISI2isconstant
IN.isidistribution = 'exponential';  % 'exponential' or 'geometric'
IN.ISImin = 1;             % Constraints: Psychological (can subjects process cue) and statistical (longer = less BOLD nonlinearity, which is difficult to model).
%IN.ISImean = 5;            % For 'exponential' only.  Includes ISImin.  There is an optimal empirical value -- longer is better for deconvolution/FIR, but we also need to fit within total scan time constraints.
IN.ISImax = 16;            % Truncate to avoid VERY long ISIs

iter = 100;

ISImeans = [1.5:.5:10];
nISIs = length(ISImeans);

[meanrecipvif, des_efficiency, scanduration] = deal(zeros(iter, nISIs));

for k = 1:nISIs
    
    for i = 1:iter
        
        [meanrecipvif(i, k), vifs, design_struct] = generate_jittered_er_design_pain_plus_rating(IN, 'noplot', 'ISImean', ISImeans(k));
        
        des_efficiency(i, k) = design_struct.efficiency;
        
        scanduration(i, k) = design_struct.scanlength;
        
    end
    
end

SIM4.IN = IN;
SIM4.meanrecipvif = meanrecipvif;
SIM4.des_efficiency = des_efficiency;
SIM4.scanduration = scanduration;

f = findobj('Type', 'Figure', 'Tag', 'Design efficiency');
figure(f); hold on; 

newcolor = [.2 .2 .7];
newcolor2 = [.5 .5 1];

subplot(2, 2, 1); hold on;
lineplot_columns(1./SIM4.meanrecipvif, 'color', newcolor, 'markerfacecolor', newcolor2, 'x', ISImeans);

subplot(2, 2, 2); hold on;
lineplot_columns(SIM4.scanduration, 'color', newcolor, 'markerfacecolor', newcolor2, 'x', ISImeans);

subplot(2, 2, 3); hold on;
lineplot_columns(SIM4.des_efficiency .^ .5, 'color', newcolor, 'markerfacecolor', newcolor2, 'x', ISImeans);

subplot(2, 2, 4); hold on;
lineplot_columns(100 .* SIM4.des_efficiency .^ .5 ./ SIM1.scanduration, 'color', newcolor, 'markerfacecolor', newcolor2, 'x', ISImeans);

f = findobj('Type', 'Figure', 'Tag', 'VIF vs. Design efficiency');
figure(f); hold on; 
plot(SIM4.meanrecipvif(:), sqrt(SIM4.des_efficiency(:)), '.', 'color', newcolor2);

f = findobj('Type', 'Figure', 'Tag', 'scan duration vs. efficiency');
figure(f); hold on;
plot(SIM4.scanduration(:), sqrt(SIM4.des_efficiency(:)), 'r.', 'color', newcolor2);

% 10 min, 20 min, 30 min task time
hh = plot_vertical_line(600); set(hh, 'LineStyle', ':');
hh = plot_vertical_line(1200); set(hh, 'LineStyle', ':');
hh = plot_vertical_line(1800); set(hh, 'LineStyle', ':');

% legend({'8 trials/condition' '10 trials/condition' '12 trials/condition' '14 trials/condition'})

disp('8 trials/condition 10 trials/condition 12 trials/condition 14 trials/condition');

%%
save Wager_PainDesign_sim1 SIM1 SIM2 SIM3 SIM4

f = findobj('Type', 'Figure', 'Tag', 'Design efficiency');
figure(f); 
saveas(gcf, [strrep(strrep(get(f, 'Tag'), ' ', '_'), '.', '') '.png']);

f = findobj('Type', 'Figure', 'Tag', 'VIF vs. Design efficiency');
figure(f); 
saveas(gcf, [strrep(strrep(get(f, 'Tag'), ' ', '_'), '.', '') '.png']);

f = findobj('Type', 'Figure', 'Tag', 'scan duration vs. efficiency');
figure(f); 
saveas(gcf, [strrep(strrep(get(f, 'Tag'), ' ', '_'), '.', '') '.png']);

%% Convert to power

% reference effects hard-coded in efficiency2power:
% b_mean = 1;         % true effect 
% var_g = 1;          % group variance; individual differences
% s2 = 50;           % scan-to-scan noise variance
% N = 50;             % sample size
% alpha = 0.001;      % alpha value

power_est = [];
e = mean(SIM1.des_efficiency);

for i = 1:length(e)
    power_est(1, i) = efficiency2power(e(i));
end

e = mean(SIM2.des_efficiency);

for i = 1:length(e)
    power_est(2, i) = efficiency2power(e(i));
end

e = mean(SIM3.des_efficiency);

for i = 1:length(e)
    power_est(3, i) = efficiency2power(e(i));
end

e = mean(SIM4.des_efficiency);

for i = 1:length(e)
    power_est(4, i) = efficiency2power(e(i));
end

%%
create_figure('Power')

plot(ISImeans, power_est', 'LineWidth', 3);

legend({'8 trials/condition' '10 trials/condition' '12 trials/condition' '14 trials/condition'})

xlabel('mean ISI')
ylabel('Power, N = 50, true d = 1 + scan noise var(50)')
title('Power')
saveas(gcf, [strrep(strrep(get(gcf, 'Tag'), ' ', '_'), '.', '') '.png']);

% Find where duration is 20 min, 25 min, 30 min for each sim
% 20 min = 1 hr scan with T1, Pinel, TWI
% 25 = 1 hr, very aggressive, may need to shorten DWI or T1
% 30 = 1 hr scan only if no DWI and (no Pinel or short T1)

[~, wh] = min(abs(mean(SIM1.scanduration) - 1200));
plot(ISImeans(wh), power_est(1, wh), 'ko', 'MarkerSize', 10);

[~, wh] = min(abs(mean(SIM2.scanduration) - 1200));
plot(ISImeans(wh), power_est(2, wh), 'ko', 'MarkerSize', 10);

[~, wh] = min(abs(mean(SIM3.scanduration) - 1200));
plot(ISImeans(wh), power_est(3, wh), 'ko', 'MarkerSize', 10);

[~, wh] = min(abs(mean(SIM4.scanduration) - 1200));
plot(ISImeans(wh), power_est(4, wh), 'ko', 'MarkerSize', 10);

[~, wh] = min(abs(mean(SIM1.scanduration) - 1500));
plot(ISImeans(wh), power_est(1, wh), 'kv', 'MarkerSize', 10);

[~, wh] = min(abs(mean(SIM2.scanduration) - 1500));
plot(ISImeans(wh), power_est(2, wh), 'kv', 'MarkerSize', 10);

[~, wh] = min(abs(mean(SIM3.scanduration) - 1500));
plot(ISImeans(wh), power_est(3, wh), 'kv', 'MarkerSize', 10);

[~, wh] = min(abs(mean(SIM4.scanduration) - 1500));
plot(ISImeans(wh), power_est(4, wh), 'kv', 'MarkerSize', 10);

[~, wh] = min(abs(mean(SIM1.scanduration) - 1800));
plot(ISImeans(wh), power_est(1, wh), 'kd', 'MarkerSize', 10);

[~, wh] = min(abs(mean(SIM2.scanduration) - 1800));
plot(ISImeans(wh), power_est(2, wh), 'kd', 'MarkerSize', 10);

[~, wh] = min(abs(mean(SIM3.scanduration) - 1800));
plot(ISImeans(wh), power_est(3, wh), 'kd', 'MarkerSize', 10);

[~, wh] = min(abs(mean(SIM4.scanduration) - 1800));
plot(ISImeans(wh), power_est(4, wh), 'kd', 'MarkerSize', 10);


legend({'8 trials/condition' '10 trials/condition' '12 trials/condition' '14 trials/condition'})

%% Sample size curve for chosen design

[~, wh] = min(abs(mean(SIM3.scanduration) - 1500));
eff = mean(SIM3.des_efficiency(:, wh));

power_curve = [];
N = 10:100;

for i = 1:length(N)
    
    power_curve(i) = 100 * efficiency2power(eff, 'N', N(i));
    
end

create_figure('Power curve 25 min 12 trials x 6 conds')

plot(N, power_curve, 'LineWidth', 3);

xlabel('Sample size (N)')
ylabel('Power (%)')
title('Power curve: 25 min, 12 trials x 6 conds')
saveas(gcf, [strrep(strrep(get(gcf, 'Tag'), ' ', '_'), '.', '') '.png']);

plot_horizontal_line(80)
[~, wh] = min(abs(power_curve - 80));
plot_vertical_line(N(wh));
