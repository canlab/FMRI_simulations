


create_figure('autocorr', 1, 3);
colormap bone;

X = eye(10); imagesc(X); set(gca, 'YDir', 'reverse'); axis tight

subplot(1, 3, 2); set(gca, 'YDir', 'reverse'); axis tight
rho = .7; 
X = toeplitz([1 rho rho^2 rho^3 rho^4 rho^5 rho^7 rho^8 rho^9 rho^10]);
imagesc(X);

subplot(1, 3, 3); set(gca, 'YDir', 'reverse'); axis tight
rho = .7; k = .4;
X = diag([1 1 1 1 1 .6 .6 .6 .6 .6]);
X = X + diag([.8 .8 .8 .8 .8], 5);
imagesc(X);


%%

n = 200;    % number of time points

rho = 0.5;  % rho autocorrelation param for AR(1) model 
% e(i+1) = rho * e(i) + eta(i), e = error, eta = innovation/new random error

v_vec = 1;

for i = 2:n 

    v_vec(i) = rho .^ (i-1); 

end

V = toeplitz(v_vec);
create_figure('V', 1, 2)
imagesc(V); colorbar
title('Autocorrelation (V)')
set(gca, 'YDir', 'Reverse'); axis tight
% zoom in
set(gca, 'XLim', [0 20], 'YLim', [0 20])
canlab_redblue_symmetric_colormap

subplot(1, 2, 2)
imagesc(inv(V))
title('Whitening (inv(V))')
colorbar
set(gca, 'YDir', 'Reverse'); axis tight
% zoom in
set(gca, 'XLim', [0 20], 'YLim', [0 20])
canlab_redblue_symmetric_colormap

% 
eta = randn(n, 1); % some data, the ideal whitened error timeseries 
create_figure('e', 2, 1); 
plot(eta, 'k', 'LineWidth', 2)

es = filter(1, [1 rho], eta); 

hold on; 
plot(es, 'LineWidth', 2)
legend({'True whitened error' 'Observed smooth errors'})

subplot(2, 1, 2);

plot(eta, 'k', 'LineWidth', 2) 

plot(inv(sqrt(V)) * es, 'r', 'LineWidth', 2) % ideal whitened with true V matrix

% with noisy V estimate based on data - can we recover the true
% coefficient?
rho_hat = aryule(es, 1);

v_hat_vec = rho_hat(1);

for i = 2:n 

    v_hat_vec(i) = rho_hat(2) .^ (i-1); 

end
V_hat = toeplitz(v_hat_vec);

plot(inv(sqrt(V_hat)) * es, 'LineWidth', 2) % recovered: whitened with estimated V matrix

legend({'True whitened error' 'Recovered from V' 'Recovery with AR(1) model'})


%%

% see also:
%[xc,Vi] = canonical_autocorrelation(TR,n,varargin)

