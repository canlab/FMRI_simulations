
%%

trial_spacing_options = [2:20];
epoch_duration_options = [1 2 3 4];

run_length = 480;
epoch_duration = 1;
TR = 1;

f1 = create_figure('Design matrix');
f2 = create_figure('Efficiency');

for d = 1:length(epoch_duration_options)
    epoch_duration = epoch_duration_options(d);
    
    % Initialize
    eff = zeros(length(trial_spacing_options), 1);
    
    figure(f1)
    
    for i = 1:length(trial_spacing_options)
        
        trial_spacing_in_sec = trial_spacing_options(i);
        
        % Single-trial design onsets
        ons = mat2cell([1:trial_spacing_in_sec:run_length-10]', ones(length([1:trial_spacing_in_sec:run_length-10]), 1))';
        
        clf;
        [X,d,out,handles] = plotDesign(ons, [], TR, 'durs', epoch_duration, 'samefig');
        drawnow
        
        [eff(i), eff_vector, contrasts] = calcEfficiency(X(1:run_length, :));
        
    end % trial spacing
    
    
    figure(f2)
    plot(trial_spacing_options, eff, '-o', 'LineWidth', 3);
    xlabel('inter-trial spacing (sec)');
    ylabel('Average efficiency per trial');
    
    drawnow
    
end % epoch duration

%%
epoch_duration = 3;
trial_spacing_in_sec = 8;

f = findobj('Tag', 'Design matrix');
figure(f);

ons = mat2cell([1:trial_spacing_in_sec:run_length-10]', ones(length([1:trial_spacing_in_sec:run_length-10]), 1))';
[eff_avg, eff_vector] = calcEfficiency(X(1:run_length, :));

clf;
[X,d,out,handles] = plotDesign(ons, [], TR, 'durs', epoch_duration, 'samefig');
drawnow

eff_avg

length(ons)
