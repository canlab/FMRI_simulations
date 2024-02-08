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
e = randn(n, 1); % some data, the ideal whitened error timeseries 
create_figure('e', 2, 1); 
plot(e, 'k', 'LineWidth', 2)

es = V*e;       % smoothed data
                % see also: y = filter(1, [1 rho], eta); <- different tho

hold on; 
plot(es, 'LineWidth', 2)
legend({'True whitened error' 'Observed smooth errors'})

subplot(2, 1, 2);

plot(inv(V) * es, 'k', 'LineWidth', 2) % ideal whitened with true V matrix

% with noisy V estimate based on data - can we recover the true
% coefficient?
rho_hat = aryule(es, 1);

v_hat_vec = rho_hat(1);

for i = 2:n 

    v_hat_vec(i) = rho_hat(2) .^ (i-1); 

end
V_hat = toeplitz(v_hat_vec);

plot(inv(V_hat) * es, 'LineWidth', 2) % recovered: whitened with estimated V matrix

legend({'True whitened error' 'Recovery with AR(1) model'})


%%

% see also:
%[xc,Vi] = canonical_autocorrelation(TR,n,varargin)

