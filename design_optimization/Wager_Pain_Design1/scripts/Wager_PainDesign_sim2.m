
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

plot(scanduration(wh), 1./meanrecipvif(wh), 'ro', 'MarkerFaceColor', newcolor2, 'MarkerSize', 12);

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


