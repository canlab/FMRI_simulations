function [m_hat, s_hat] = est_kalman_simple(obs_values, se_hat, sh_hat)
% [m_hat, s_hat] = est_kalman_simple(obs_values, se_hat, sh_hat)
%
% This function returns fits given parameter estimates - the "forward model"

n = length(obs_values);

% Initialize vectors

m_hat = zeros(n,1);                    % fitted (estimated) sequence of true means; zero for first trial
s_hat = zeros(n,1);                    % fitted (estimated) sequence of true variances; sh for first trial
s_hat(1) = sh_hat;

% Estimate

for i = 1:n - 1
    
    m_hat(i+1) = (m_hat(i) * se_hat + obs_values(i) * s_hat(i)) / (se_hat + s_hat(i));  % precision-weighted mean
    s_hat(i+1) = se_hat * s_hat(i) / (se_hat + s_hat(i)) + sh_hat;
    
end


end % main function