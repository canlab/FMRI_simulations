

% Matlab example

load fisheriris
t = table(species,meas(:,1),meas(:,2),meas(:,3),meas(:,4),...
'VariableNames',{'species','meas1','meas2','meas3','meas4'});
Meas = table([1 2 3 4]','VariableNames',{'Measurements'});
Meas
t

%% Random example - one-way RM ANOVA


t = table(y(:, 1), y(:, 2), y(:, 3), 'VariableNames', {'y1' 'y2'  'y3'})

rm = fitrm(t,'y1-y3~1')  % one-way repeated measures
anova(rm)
rm.WithinDesign

% i think this creates an orthogonal basis set of within-person contrasts

% is it iterative? does it estimate covariances?


% Same as F-test across 2 contrasts?
c = [1 -1 0; -1 -1 2]';
yc = y * c;

%%
%% Random example - 2 x 2 factorial RM ANOVA

y = mvnrnd([1 .5 .5 .3], [1 .6 .6 .6; .6 1 .6 .6; .6 .6 1 .6; .6 .6 .6 1], 50);
corr(y)

t = table(y(:, 1), y(:, 2), y(:, 3), y(:, 4), 'VariableNames', {'y1' 'y2'  'y3' 'y4'})

Meas = table([1 1 2 2]', [1 2 1 2]','VariableNames',{'F1' 'F2'});
rm = fitrm(t,'y1-y4~F1 + F2 + F1:F2', 'WithinDesign',Meas)

ranova(rm)


rm.WithinDesign
