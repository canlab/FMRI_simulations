function [m_hat, s_hat] = est_kalman_simple(obs_values, se_hat, sh_hat)
% [m_hat, s_hat] = est_kalman_simple(obs_values, se_hat, sh_hat)
%
% This function returns predictions given model parameter estimates - the "forward model"
%mj: i wouldn't say this function returns fits (fit refers to match between model predictions and data; there are no data here) 
%    the function essentially returns model predictions, although not directly 
%    the model's prediction is the sequence of responses by the subject, which might equal m_hat(:) or it might be a sequence of samples from N(m_hat(:),s_hat(:)) 

n = length(obs_values);

% Initialize vectors

m_hat = zeros(n,1);                    % fitted (estimated) sequence of true means; zero for first trial
s_hat = zeros(n,1);                    % fitted (estimated) sequence of true variances; sh for first trial
s_hat(1) = sh_hat;

% Estimate

for i = 1:n - 1
    
    % precision-weighted mean
    m_hat(i+1) = (m_hat(i) * se_hat + obs_values(i) * s_hat(i)) / (se_hat + s_hat(i)); 

    % 
    s_hat(i+1) = se_hat * s_hat(i) / (se_hat + s_hat(i)) + sh_hat;
    
end


end % main function