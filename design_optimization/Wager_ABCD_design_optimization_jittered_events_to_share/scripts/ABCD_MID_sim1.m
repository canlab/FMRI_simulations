% Simulation 1: Look at effects of ISI mean on design quality and scan time
% --------------------------------------------------------------------------

iter = 100;

ISImeans = [1.5:.2:4];
nISIs = length(ISImeans);

[meanrecipvif, scanduration] = deal(zeros(iter, nISIs));

for k = 1:nISIs
    
    for i = 1:iter
        
        [meanrecipvif(i, k), vifs, design_struct] = generate_jittered_er_design('noplot', 'ISImean', ISImeans(k));
        
        scanduration(i, k) = design_struct.scanlength;
        
    end
    
end

%%

create_figure('Design multicolinearity', 1, 2);

lineplot_columns(1./meanrecipvif, 'markerfacecolor', [.5 .5 1], 'x', ISImeans);
title('Design colinearity: Higher is worse');
xlabel('ISI mean');
ylabel('Harmonic mean of VIFs');

subplot(1, 2, 2);

lineplot_columns(scanduration, 'markerfacecolor', [0 .5 1], 'x', ISImeans);
title('Scan duration (2 runs together)');
xlabel('ISI mean');
ylabel('Duration (sec)');
plot_horizontal_line(600);

%% Simulation 2: Generate a population of designs and pick the best
% --------------------------------------------------------------------------
tic

iter = 10000;
ISImean = 2.5;

[meanrecipvif, scanduration] = deal(zeros(iter, 1));

for i = 1:iter
        
        [meanrecipvif(i, 1), vifs, design_struct] = generate_jittered_er_design('noplot', 'ISImean', ISImean);
        
        scanduration(i, 1) = design_struct.scanlength;
        
        % save the best so far.
        if meanrecipvif(i) == max(meanrecipvif)
            best_design_struct = design_struct;
        end
  
        if scanduration(i) <= 660 && meanrecipvif(i) == max(meanrecipvif(scanduration <= 660))
            best_design_struct_under660 = design_struct;
        end
        
end

toc

% Figure
% --------------------------------------------------------------------------

create_figure('Design population', 1, 1);

plot(scanduration, 1./meanrecipvif, 'ko', 'MarkerFaceColor', [0 .5 1]);
xlabel('Scan duration');
ylabel('Multicolinearity (lower is better)');

[bestrecipvif, wh] = max(meanrecipvif);

plot(scanduration(wh), 1./meanrecipvif(wh), 'ro', 'MarkerFaceColor', [1 .5 .5], 'MarkerSize', 12);

under660 = (scanduration <= 660);
vifunder660 = meanrecipvif(under660);
scandurunder660 = scanduration(under660);
[bestrecipvif, wh] = max(vifunder660);

plot(scandurunder660(wh), 1./vifunder660(wh), 'ro', 'MarkerFaceColor', [1 .5 1], 'MarkerSize', 12);

% Save best results
% --------------------------------------------------------------------------

diaryname = sprintf('MID_Events_best_design_of_10000_%s.txt', strrep(datestr(datetime), ' ', '_') );
diary(diaryname)
print_matrix(best_design_struct.eventlist, best_design_struct.eventlist_names);
diary off

diaryname = sprintf('MID_Events_best_design_of_10000_under_660sec_%s.txt', strrep(datestr(datetime), ' ', '_') );
diary(diaryname)
print_matrix(best_design_struct_under660.eventlist, best_design_struct_under660.eventlist_names);
diary off


