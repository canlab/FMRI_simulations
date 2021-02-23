n = 50;     % participants
k = 10000;  % tests
d = .5 ;    % true effect Cohen's d
proptrue = .5; % proportion true positive (rest are null)

numtrue = floor(k * proptrue); % number of tests with pos results

whtrue = 1:numtrue;  % indices of which are true effect and null
whnull = numtrue+1:k;

mu = [d * ones(1, numtrue) zeros(1, k - numtrue)];

niter = 20;

run_sim(n, k, mu, numtrue, niter)

% Conclusions: 
% FDR is controlled at expected levels for Storey. 
% BH returns 1/2 the expected nominal FDR with 50% true positives. This
% seems to be a function of having many true positives (see below).
% Storey does not have higher discriminability, but is more sensitive due to higher (but appropriate) FDR.
% BH1 and BH2 are not identical

%% % --------------------------------------------------------------------
% SMALL SAMPLE FDR
% --------------------------------------------------------------------

n = 50;     % participants
k = 50;    % tests
d = .5 ;    % true effect Cohen's d
proptrue = .5; % proportion true positive (rest are null)

numtrue = floor(k * proptrue); % number of tests with pos results

mu = [d * ones(1, numtrue) zeros(1, k - numtrue)];

niter = 50;

run_sim(n, k, mu, numtrue, niter)

% Conclusions: 
% FDR correction can be used with small numbers of tests (the BH version).
% However, performance becomes more variable across samples, with observed
% FDR up to 20% with k = 50 tests.
% Storey is more variable in performance with small numbers of tests and
% can be erratic. It doesn't control FDR well and is not recommended.
% D-prime is lower for story
% BH1 and BH2 are not identical, and BH2 is probably a bit more sensitive


%% % --------------------------------------------------------------------
% RARE PROPORTION FDR
% --------------------------------------------------------------------

n = 50;     % participants
k = 10000;    % tests
d = .5 ;    % true effect Cohen's d
proptrue = .01; % proportion true positive (rest are null)

numtrue = floor(k * proptrue); % number of tests with pos results

mu = [d * ones(1, numtrue) zeros(1, k - numtrue)];

niter = 20;

run_sim(n, k, mu, numtrue, niter)

% Conclusions: 
% Storey is most sensitive. All methods control FDR similarly.
% BH methods are not overconservative with 1% true positives.


%% % --------------------------------------------------------------------
% MEDIUM NUMBER OF TESTS (parcels)
% --------------------------------------------------------------------

n = 50;     % participants
k = 500;    % tests
d = .5 ;    % true effect Cohen's d
proptrue = .1; % proportion true positive (rest are null)

numtrue = floor(k * proptrue); % number of tests with pos results

mu = [d * ones(1, numtrue) zeros(1, k - numtrue)];

niter = 100;

run_sim(n, k, mu, numtrue, niter)

% Conclusions: 
% Storey is most sensitive and controls FDR appropriately.
% BH methods are slightly overconservative with 10% true positives.
% Performance becomes highly variable (erratic) as number of true positives
% drops. FDR performs best & is most stable with large numbers of tests
% with many true positives.

%% Coming soon: Positive dependence, negative dependence
% Line graphs of sims across parameters



function run_sim(n, k, mu, numtrue, niter)

clear bh storey bh2

whtrue = 1:numtrue;  % indices of which are true effect and null
whnull = numtrue+1:k;

for i = 1:niter
    
    fprintf('%d ', i);
    
    % Generate data and P-values
    % ------------------------------------------
    dat = mvnrnd(mu, eye(k), n);
    
    [H,P,CI,STATS] = ttest(dat);
    
    % FDR correction
    % ------------------------------------------
    
    % Benjamini-Hochberg
    pt = FDR(P, .05);
    
    bh.tpr(i, 1) = sum(P(whtrue) < pt) ./ length(whtrue);
    bh.fpr(i, 1) = sum(P(whnull) < pt) ./ length(whnull);
    bh.d(i, 1) = norminv(bh.tpr(i, 1)) - norminv(bh.fpr(i, 1));         % d' value (discriminability)
    bh.fdr(i, 1) = sum(P(whnull) < pt) ./ sum(P < pt);      % observed false discovery rate
    
    % Storey 2002 procedure
    [sFDR, Q, pi0] = mafdr(P);
    
    % Storey q < 0.05 two-tailed
    storey.tpr(i, 1) = sum(sFDR(whtrue) < .05) ./ length(whtrue);
    storey.fpr(i, 1) = sum(sFDR(whnull) < .05) ./ length(whnull);
    storey.d(i, 1) = norminv(storey.tpr(i, 1)) - norminv(storey.fpr(i, 1));         % d' value (discriminability)
    storey.fdr(i, 1) = sum(sFDR(whnull) < .05) ./ sum(sFDR < .05);      % observed false discovery rate
    
    FDR_BH = mafdr(P, 'BHFDR', true);
    
    bh2.tpr(i, 1) = sum(FDR_BH(whtrue) < .05) ./ length(whtrue);
    bh2.fpr(i, 1) = sum(FDR_BH(whnull) < .05) ./ length(whnull);
    bh2.d(i, 1) = norminv(bh2.tpr(i, 1)) - norminv(bh2.fpr(i, 1));         % d' value (discriminability)
    bh2.fdr(i, 1) = sum(FDR_BH(whnull) < .05) ./ sum(FDR_BH < .05);      % observed false discovery rate
    
end % iterations

create_figure('FDR', 2, 2)

jitter = unifrnd(-.1, .1, niter, 1);

plot(ones(niter, 1)+jitter, bh.tpr, 'ko', 'MarkerFaceColor', [.5 .5 .5]);
plot(2*ones(niter, 1)+jitter, bh2.tpr, 'ko', 'MarkerFaceColor', [.5 .5 .5]);
plot(3*ones(niter, 1)+jitter, storey.tpr, 'ro', 'MarkerFaceColor', [1 .5 .5]);

boxplot([bh.tpr bh2.tpr storey.tpr])

set(gca, 'XTick', [1:3], 'XLim', [0 4], 'XTickLabels', {'BH1' 'BH2' 'Storey'}, 'XTickLabelRotation', 45); %'YLim', [0 1]);
title('TPR');

subplot(2, 2, 2)

plot(ones(niter, 1)+jitter, bh.fpr, 'ko', 'MarkerFaceColor', [.5 .5 .5]);
plot(2*ones(niter, 1)+jitter, bh2.fpr, 'ko', 'MarkerFaceColor', [.5 .5 .5]);
plot(3*ones(niter, 1)+jitter, storey.fpr, 'ro', 'MarkerFaceColor', [1 .5 .5]);

boxplot([bh.fpr bh2.fpr storey.fpr])

set(gca, 'XTick', [1:3], 'XLim', [0 4], 'XTickLabels', {'BH1' 'BH2' 'Storey'}, 'XTickLabelRotation', 45); %, 'YLim', [0 1]);
title('FPR');

subplot(2, 2, 3)

plot(ones(niter, 1)+jitter, bh.d, 'ko', 'MarkerFaceColor', [.5 .5 .5]);
plot(2*ones(niter, 1)+jitter, bh2.d, 'ko', 'MarkerFaceColor', [.5 .5 .5]);
plot(3*ones(niter, 1)+jitter, storey.d, 'ro', 'MarkerFaceColor', [1 .5 .5]);

boxplot([bh.d bh2.d storey.d])

set(gca, 'XTick', [1:3], 'XLim', [0 4], 'XTickLabels', {'BH1' 'BH2' 'Storey'}, 'XTickLabelRotation', 45); %, 'YLim', [0 1]);
title('D-prime');

subplot(2, 2, 4)

plot(ones(niter, 1)+jitter, bh.fdr, 'ko', 'MarkerFaceColor', [.5 .5 .5]);
plot(2*ones(niter, 1)+jitter, bh2.fdr, 'ko', 'MarkerFaceColor', [.5 .5 .5]);
plot(3*ones(niter, 1)+jitter, storey.fdr, 'ro', 'MarkerFaceColor', [1 .5 .5]);

boxplot([bh.fdr bh2.fdr storey.fdr])

set(gca, 'XTick', [1:3], 'XLim', [0 4], 'XTickLabels', {'BH1' 'BH2' 'Storey'}, 'XTickLabelRotation', 45); %, 'YLim', [0 1]);
title('FDR');
plot_horizontal_line(0.05);

end % function run_sim

