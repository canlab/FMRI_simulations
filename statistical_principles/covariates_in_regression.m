% Controlling for an outcome-unrelated covariate
% causal connections:
%
%  
% xe
%  |
%  v
%  x <- xs -> y <- ye
%       ^
%       |
%  c <- cs
%  ^
%  |
%  ce
%
% Here, xs is a mediator of cs -> y, and controlling for c weakens the xs -> y relationship
% 
% true
n = 1000;
clear d      % effect sizes
iter = 100;

for i = 1:iter
    
    ye = randn(n, 1); % y error
    xe = randn(n, 1); % x error
    ce = randn(n, 1); % c error
    
    cs = randn(n, 1);              % c true signal
    xs = (cs + randn(n, 1)) ./ 2;  % x true signal (c contributes)
    %xs = randn(n, 1));            % x true signal (c does not contribute)
    
    % observed signals: plus random noise (e)
    y = (xs + ye) ./ 2; % y observed (c does not contribute)
    x = (xs + xe) ./ 2; % x observed
    c = (cs + ce) ./ 2;
    
    % Fit with c
    [b, dev, stats] = glmfit([x c], y);
    if i < 2, glm_table(stats, {'x' 'c'}); end
    tval = stats.t(2);
    d(i, 1) = tval ./ sqrt(n);
    
    % Fit without c
    [b, dev, stats] = glmfit(x, y);
    if i < 2, glm_table(stats, {'x'}); end
    tval = stats.t(2);
    d(i, 2) = tval ./ sqrt(n);
    
end

figure; hist(d); legend({'Full model, x controlling c', 'x only'}); title('Effect size')
figure; hist(d(:, 2) - d(:, 1)); title('Effect size, x only - x controlling c');

%% % Controlling for an outcome-unrelated covariate
% causal connections:
%
%  
% xe
%  |
%  v
%  x <- xs -> y <- ye
%  ^
%  |
%  cs -> c
%        ^
%        |
%        ce
%
% Here, cs and xs are unrelated and c contributes a source of error to observed x
% Controlling for c strengthens the xs -> y relationship
% x is a "pseudo-mediator" here, because the cs->x effect and xs->y effects
% are actually independent.

% true
n = 1000;
clear d      % effect sizes
iter = 100;

for i = 1:iter
    
    ye = randn(n, 1); % y error
    xe = randn(n, 1); % x error
    ce = randn(n, 1); % c error
    
    cs = randn(n, 1);              % c true signal
    % xs = (cs + randn(n, 1)) ./ 2;  % x true signal (c contributes)
    xs = randn(n, 1);            % x true signal (c does not contribute)
    
    % observed signals: plus random noise (e)
    y = (xs + ye) ./ 2; % y observed (c does not contribute)
    x = (xs + xe + cs) ./ 3; % x observed
    c = (cs + ce) ./ 2;
    
    % Fit with c
    [b, dev, stats] = glmfit([x c], y);
    if i < 2, glm_table(stats, {'x' 'c'}); end
    tval = stats.t(2);
    d(i, 1) = tval ./ sqrt(n);
    
    % Fit without c
    [b, dev, stats] = glmfit(x, y);
    if i < 2, glm_table(stats, {'x'}); end
    tval = stats.t(2);
    d(i, 2) = tval ./ sqrt(n);
    
end

figure; hist(d); legend({'Full model, x controlling c', 'x only'}); title('Effect size')
figure; hist(d(:, 2) - d(:, 1)); title('Effect size, x only - x controlling c');

%%
% causal connections:
%
%  x -> y
%  ^   /
%  |  /
%   c
%

%% Conditioning on a collider

% c < y
% ^
% x

% true
n = 1000;

x = randn(n, 1);
y = randn(n, 1);
c = (x + y + randn(n, 1)) ./ 3;
int = ones(size(x));

[b,~, r, ~, stats] = regress(y, [int c x]);

create_figure('scatter', 2, 2)

% All
plot(x, y, 'ko', 'MarkerFaceColor', [.5 .5 .5]);
xlabel('x - Income')
ylabel('y - IQ')
title('All observations')
refline

wh = c > median(c);

% Split - together
subplot(2, 2, 2)
% plot(x, y, 'ko', 'MarkerFaceColor', [.5 .5 .5]);
plot(x(wh), y(wh), 'ko', 'MarkerFaceColor', [.7 .3 .8]);
plot(x(~wh), y(~wh), 'ko', 'MarkerFaceColor', [.2 .7 .5]);
xlabel('x - Income')
ylabel('y - IQ')
title('Conditioning on c (school quality)')
refline

subplot(2, 2, 3)

plot(x(wh), y(wh), 'ko', 'MarkerFaceColor', [.7 .3 .8]);
refline
plot(x(~wh), y(~wh), 'ko', 'Color', [.7 .7 .7]);

xlabel('x - Income')
ylabel('y - IQ')

title('High c (good schools)')


subplot(2, 2, 4)

plot(x(~wh), y(~wh), 'ko', 'MarkerFaceColor', [.2 .7 .5]);
refline
plot(x(wh), y(wh), 'ko', 'Color', [.7 .7 .7]);

xlabel('x - Income')
ylabel('y - IQ')

title('Low c (poor schools)')

