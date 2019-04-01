

%          p(1) - delay of response (relative to onset)          6
%          p(2) - delay of undershoot (relative to onset)       16
%          p(3) - dispersion of response                         1
%          p(4) - dispersion of undershoot                       1
%          p(5) - ratio of response to undershoot                6
%          p(6) - onset {seconds}                                0
%          p(7) - length of kernel {seconds}                    32
%  

% Simulate two hypothetical components whose signals are mixed
% ----------------------------------------------------------------

c1 = spm_hrf(.1, [8 16 1.5 1 Inf 3 55]);
c1 = 250*(c1 ./ 2.7); % scale so reasonable with Gaussian N(0, 1) noise

c2a = -.3 * spm_hrf(.1, [9 16 3.5 1 Inf 3 55]);

c2 =  spm_hrf(.1, [16 16 5 1 Inf 3 55]);
c2 = 300*(c2a + c2);

create_figure('sim_components', 1, 2);
plot([c1 c2a+c2], 'LineWidth', 3)
h1 = drawbox(32, 180, -.3, .05, [.2 .2 .2]);
axis off

subplot(1, 2, 2);

true_y = c1 + c2; 
y = true_y + .3 *  noise_arp(size(true_y, 1), .7); % randn(size(true_y));

plot(y, 'k', 'LineWidth', 3)
%h1 = drawbox(32, 180, -.3, .05, [.2 .2 .2]);

axis off

%% Generate simulated signals
% Each signal has a different mixture of c1 and c2
% with different (autocorrelated) Gaussian noise

n = 10000;
ons = [1:600:10000]';

X1 = onsets2fmridesign(ons, 1, n, c1, 'noampscale');
X1 = X1(:, 1);

X2 = onsets2fmridesign(ons, 1, n, c2, 'noampscale');
X2 = X2(:, 1);

e1 = noise_arp(n, .9);
e2 = noise_arp(n, .9);

y1 = 5*X1 / max(X1) + 2*X2 / max(X2) + e1; %randn(size(X1, 1), 1);

y2 = 2*X1 / max(X1) + 5*X2 / max(X2) + e2; %randn(size(X1, 1), 1);

