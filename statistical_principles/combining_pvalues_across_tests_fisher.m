% Combining P-values

% See: 
% Lazar, Nicole A., Beatriz Luna, John A. Sweeney, and William F. Eddy. 2002. 
% ?Combining Brains: A Survey of Methods for Statistical Pooling of Information.? NeuroImage 16 (2): 538?50.

% Fisher's test combining multiple independent tests

p = [.05 .032]      % k P-values. here k = 2.
Tf = -2 * sum(log(p));
P = 1 - chi2cdf(Tf, 2 * length(p))

% if you put in 1-tailed P-vals, you get out 1-tailed. Same for 2-tailed.

% Null hypothesis simulation
% ------------------------------------

pp = unifrnd(0, 1, 10000, 2);

[Tf, P] = deal(zeros(10000, 1));

for i = 1:size(pp, 1)
    
    Tf(i, 1) = -2 * sum(log(pp(i, :)));
    P(i, 1) = 1 - chi2cdf(Tf(i, 1), 2 * size(pp, 2)); 
    
end

figure; plot(sort(P))
sum(P < .05) ./ 10000

% This is correct.

% What if we just take the product of the input P-values?
% ------------------------------------

prodp = pp(:, 1) .* pp(:, 2);
figure; plot(sort(prodp))
sum(prodp < .05) ./ 10000

% False positive rate is 20% here.

% Permutation test
% ------------------------------------

% Suppose we do k tests in each of r regions.

% We can calculate Fisher's combined test across a set of regions/voxels/nodes, 
% combining information across 2 or more tests within a region

% Permutation tests adjust appropriately for covariance across regions and
% across tests.

% We can get a FWER corrected P-value based on the max Tf across regions,
% without calculating region-level P-values at all, or calculate
% uncorrected P-values and FDR-correct across them.
