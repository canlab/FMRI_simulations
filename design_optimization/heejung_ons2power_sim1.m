names = {'CueH_LowI_cue' 'CueH_medI_cue' 'CueH_HiI_cue' 'CueL_LowI_cue' 'CueL_medI_cue' 'CueL_HiI_cue' ...
    'CueH_LowI_s' 'CueH_medI_s' 'CueH_HiI_s' 'CueL_LowI_s' 'CueL_medI_s' 'CueL_HiI_s'};

connames = {'CueHvL_cue' 'CueHvL_stim' 'StimLvH_stim' 'Cue_x_stim_stim'};

cons = [1 1 1 -1 -1 -1 0 0 0 0 0 0;  % CueHvL_cue
    0 0 0 0 0 0 1 1 1 -1 -1 -1; % CueHvL_stim
    0 0 0 0 0 0 1 0 -1 1 0 -1];   % StimLvH_stim

cons(4, :) = cons(2, :) .* cons(3, :); % Cue_x_stim_stim

cons = cons';

%%

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