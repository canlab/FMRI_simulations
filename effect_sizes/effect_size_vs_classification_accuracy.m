% Converting effect size into a probability of correctly guessing the group for an
% individual is called the "common language effect size" (McGraw and Wong, 1992), 
% also known as the probability of superiority (Grissom and Kim, 2005)
% See Lakens 2013 primer.

% McGraw, Kenneth O., and Seok P. Wong. "A common language effect size statistic." Psychological bulletin 111.2 (1992): 361.

% Two-sample example:
% example from McGraw and Wong 1992: height for male vs. female
% mag = 69.7 - 64.3; % inches
% sd = [2.8 2.6];
% sd_diff = sqrt(sum(sd .^ 2)); % because the variance of the diff is the sum of the two variances
% d = mag / sd_diff
% p = normcdf(d); % 92% chance that male taller than female

% Using normal probability model to get expected relationships
% conditional on normal distribution

% NNT example for genetic disorder
% d = norminv(1 - 10E-10) / sqrt(100000)
% p = normcdf(d)
% p = normcdf(d/2)
% nnt = 1/(p - .50)  = 264

% Effect size
% For one sample, the effect size is the standardized distance from a fixed value, zero.
% Thus, it is the mean sample value / its standard deviation.
% This also applies to a forced-choice test where we compare two values and
% decide which is higher.

d = [0:.05:3];
p = normcdf(d / sqrt(2)); % sqrt(2) because we are doing forced choice.

create_figure('d vs. classification accuracy', 2, 2)
h1 = plot(d, p, 'LineWidth', 3);
xlabel('Effect size (d)')
ylabel('Classification Accuracy')

% When comparing two independent samples, each sample has a standard deviation. 
% The std of the difference is sqrt(var1 + var2)
% If standard devs are equal, d will be 1/sqrt(2) times the distance between the two means.
% if doing a forced-choice comparison, picking exactly one from each
% distribution, then normcdf(d) applies. This is the "common language" metric. 
%
% But if choosing a single observation and making a decision, we have less info.
% This is called single-interval classification. Here, if standard
% deviations are equal and d is the standardized distance between the
% means, with sd1 = sd2 = 1, then 
% anything less than d/2 away from the correct distribution will be misclassified.
% This is appropriate for classifying, e.g., patients vs. controls

p2 = normcdf(d/2);
h2 = plot(d, p2, 'LineWidth', 3);

% crosshairs
hh = plot([.8 .8], [.5 normcdf(.8/2)], 'k--');
hh = plot([0 .8], [normcdf(.8/2) normcdf(.8/2)], 'k--');
text(0.8 - 0.1, 0.47, sprintf('%3.1f', 0.8), 'FontSize', 14)

d90 = norminv(0.9) * sqrt(2);
hh = plot([d90 d90], [.5 normcdf(d90  / sqrt(2))], 'k--');
hh = plot([0 d90], [normcdf(d90 / sqrt(2)) normcdf(d90  / sqrt(2))], 'k--');
d90
text(d90 - 0.1, 0.47, sprintf('%3.1f', d90), 'FontSize', 14)

d90 = norminv(0.9)*2;
hh = plot([d90 d90], [.5 normcdf(d90/2)], 'k--');
hh = plot([0 d90], [normcdf(d90/2) normcdf(d90/2)], 'k--');
d90
text(d90 - 0.1, 0.47, sprintf('%3.1f', d90), 'FontSize', 14)

set(gca, 'YLim', [.4 1]);

hh = plot_horizontal_line(.5); 
set(hh, 'LineStyle', ':', 'Linewidth', 2);

legend([h1 h2 hh], {'One sample' 'Two samples' 'Chance'})

title('Accuracy by effect size');

%% Simulation, with normally distributed variables

% Note: this simulation requires mean2 > mean1 to work correctly.

mean1 = 0;
mean2 = .8;
sd1 = 1;
sd2 = 1;

% McGraw example
% mean1 = 64.3;
% mean2 = 69.7;
% sd1 = 2.8;
% sd2 = 2.6;

x1 = mvnrnd(mean1, sd1 ^ 2, 100000);
x2 = mvnrnd(mean2, sd2 ^ 2, 100000); % effect size of 0.8

% Forced-choice
d_force_choice = abs(mean2 - mean1) ./ sqrt(sd1 ^ 2 + sd2 ^ 2) % McGraw 1992. abs(d)/sqrt(2)
p_force_choice = normcdf(d_force_choice)  % the "common language effect size"

empirical_forcedchoice = sum(x2 > x1) ./ length(x1)

% Single-interval
d_single = abs(mean2 - mean1) ./ sqrt((sd1 ^ 2 + sd2 ^ 2) / 2) % Lakens 2013
p_single_interval = normcdf(d_single / 2)

subplot(2, 2, 2);

[hvals, xvals] = hist([x1 x2], 100);

% normalize to make PDF
hvals = hvals ./ sum(hvals);

% simple plot
%plot(xvals, hvals)

% filled plots
fill([xvals xvals], [zeros(size(hvals, 1), 1) hvals(:, 1)], 'r', 'LineWidth', 2, 'FaceAlpha', .2, 'EdgeColor', 'r');
fill([xvals xvals], [zeros(size(hvals, 1), 1) hvals(:, 2)], 'b', 'LineWidth', 2, 'FaceAlpha', .2, 'EdgeColor', 'b');


hh = plot_vertical_line(0); set(hh, 'Color', 'r', 'LineWidth', 4)
hh = plot_vertical_line(.8); set(hh, 'Color', 'b', 'LineWidth', 4)

xlabel('Signal')
ylabel('Empirical probability density');

% misclassification rate: percentage of distribution for class x2 where x1 > .2

 % which is classified as distribution 1
 % cumsum at end is to avoid anomalies where both are empty at ends of
 % distribution, purely for plotting purposes.
 
wh = hvals(:, 1) > hvals(:, 2) | cumsum(hvals(:, 1)) < .01; 

mcr_x1 = sum(hvals(wh, 2)) ./ sum(hvals(:, 2));
mcr_x2 = sum(hvals(~wh, 1)) ./ sum(hvals(:, 1));

mcr = mean([mcr_x1 mcr_x2]);

empirical_singleinterval = 1 - mcr 

title('Two class distributions, d = 0.8');

% Plot correct classification zones
subplot(2, 2, 3);

plot(xvals, hvals(:, 1), 'r', 'LineWidth', 4);
plot(xvals, hvals(:, 2), 'b', 'LineWidth', 4);

xx = [[xvals(wh); max(xvals(wh))] [xvals(wh); max(xvals(wh))]];
yy = [zeros(sum(wh)+1, 1) [hvals(wh, 1); 0]];
fill(xx, yy, 'r', 'FaceAlpha', .2, 'EdgeColor', 'none');

hh = plot_vertical_line(max(xvals(wh))); set(hh, 'Color', 'k', 'LineWidth', 4)

subplot(2, 2, 4);

plot(xvals, hvals(:, 1), 'r', 'LineWidth', 4);
plot(xvals, hvals(:, 2), 'b', 'LineWidth', 4);

xx = [[  min(xvals(~wh)); xvals(~wh)] [ min(xvals(~wh)); xvals(~wh)]];
yy = [zeros(sum(~wh)+1, 1) [0; hvals(~wh, 2)]];
fill(xx, yy, 'b', 'FaceAlpha', .2, 'EdgeColor', 'none');


hh = plot_vertical_line(max(xvals(wh))); set(hh, 'Color', 'k', 'LineWidth', 4)

title('Correct classification zones');

%%
figsavedir = fullfile(pwd, 'figures');
saveas(gcf, fullfile(figsavedir, 'effect_size_class_accuracy_plots.png'));
saveas(gcf, fullfile(figsavedir, 'effect_size_class_accuracy_plots.svg'));
