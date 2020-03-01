% Simulation 1: Look at effects of ISI mean on design quality and scan time
% --------------------------------------------------------------------------

iter = 500;

ISImeans = [.8:.1:1.9];
nISIs = length(ISImeans);

[meanrecipvif, scanduration] = deal(zeros(iter, nISIs));

for k = 1:nISIs
    
    for i = 1:iter
        
        [meanrecipvif(i, k), vifs, design_struct] = generate_stop_signal_design('noplot', 'ISImean', ISImeans(k));
        
        scanduration(i, k) = design_struct.scanlength;
        
    end
    
end

%

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
for run = 1:40
    % generate 40 optimized runs
    % at the moment, 10000 designs takes about 1 min
    
    tic
    
    iter = 100000;
    ISImean = 1.1;
    lengthlimit = 375; % in sec
    
    [meanrecipvif, scanduration] = deal(zeros(iter, 1));
    
    for i = 1:iter
        
        [meanrecipvif(i, 1), vifs, design_struct] = generate_stop_signal_design('noplot', 'ISImean', ISImean);
        
        scanduration(i, 1) = design_struct.scanlength;
        
        % save the best so far.
        if meanrecipvif(i) == max(meanrecipvif)
            best_design_struct = design_struct;
        end
        
        if scanduration(i) <= lengthlimit && meanrecipvif(i) == max(meanrecipvif(scanduration <= lengthlimit))
            best_design_struct_under375sec = design_struct;
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
    
    under375 = (scanduration <= lengthlimit);
    vifunder375 = meanrecipvif(under375);
    scandurunder375 = scanduration(under375);
    [bestrecipvif, wh] = max(vifunder375);
    
    plot(scandurunder375(wh), 1./vifunder375(wh), 'ro', 'MarkerFaceColor', [1 .5 1], 'MarkerSize', 12);
    
    % Save best results
    % --------------------------------------------------------------------------
    
    diaryname = sprintf('STOPSIG_Events_best_design_of_100000_%s.txt', strrep(datestr(datetime), ' ', '_') );
    diary(diaryname)
    print_matrix(best_design_struct.eventlist, best_design_struct.eventlist_names);
    diary off
    
    diaryname = sprintf('STOPSIG_Events_best_design_of_100000_under_375sec_%s.txt', strrep(datestr(datetime), ' ', '_') );
    diary(diaryname)
    print_matrix(best_design_struct_under375sec.eventlist, best_design_struct_under375sec.eventlist_names);
    diary off
    
    
end

