function power_est = efficiency2power(des_efficiency, varargin)
% Convert efficiency to power, given reference effect, variances, and sample size
% alpha version!!!
%
% Tor Wager
%
% power_est = efficiency2power(des_efficiency, varargin)
% power_est = efficiency2power(des_efficiency, 'N', 30)

% For one participant:
% var(b-hat) = s-hat^2 / efficiency 
% se(b-hat) = sqrt(s-hat^2 * (X'X)^-1) = s-hat / sqrt(efficiency)
% t = b-hat / se(b-hat) = b-hat*sqrt(eff)/ s_hat
% E(t) = E(b) / s * sqrt(eff)
% effect size d = E(b) / s . this is within-person, s is TR-to-TR noise, will be low
% E(t) = d * sqrt(eff)
% d is reference effect size (input)
% E(p) = 1 - cdf(abs(E(t))

% could simulate noncentral t rand numbers to get distribution of p < alpha, e.g., 0.05.

% Group:
% t_g = b_mean / std(b_mean) / sqrt(N)
% variance sum law. var(sum_n) = var(n1) + var(n2) ... etc.
% variance of average is the variance of indiviual, if all individuals have
% same var
% a = normrnd(0, 1, 100, 10000); mean(var(a)), var(sum(a)) / 100
% var(b_ind) is the variance of the average induced by measurement error
% var(b_mean) = var_g + var(b-hat)
% t_g = b_mean / (sqrt(var(b_mean)) / sqrt(N))
% t_g = b_mean / (sqrt(var_g + var(b-hat)) / sqrt(N))
% t_g = b_mean / (sqrt(var_g + s-hat^2 / efficiency) / sqrt(N))
% define d_g group effect size as b_mean / sqrt(var_g) 
% or
% simulate noncentral t
% define 

% -------------------------------------------------------------------------
% DEFAULT ARGUMENT VALUES
% -------------------------------------------------------------------------

b_mean = 1;         % true effect 
var_g = 1;          % group variance; individual differences
s2 = 50;           % scan-to-scan noise variance
N = 50;             % sample size
alpha = 0.001;      % alpha value

n_samples = 100000;

% -------------------------------------------------------------------------
% OPTIONAL INPUTS
% -------------------------------------------------------------------------

allowable_inputs = {'b_mean' 'var_g' 's2' 'N' 'alpha' 'n_samples'};

% optional inputs with default values - each keyword entered will create a variable of the same name

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}

            case allowable_inputs
                
                eval([varargin{i} ' = varargin{i+1}; varargin{i+1} = [];']);
                
            otherwise, warning(['Unknown input string option:' varargin{i}]);
        end
    end
end

% -------------------------------------------------------------------------
% MAIN FUNCTION
% -------------------------------------------------------------------------

df_g = N - 1;       % group DF for one-sample t-test

% Expected t for group with reference variances/N
t_g = b_mean .* sqrt(N) ./ (var_g + s2 ./ des_efficiency).^.5; 

t_vals = nctrnd(df_g, t_g, n_samples, 1);
% note: generated t-vals are a bit higher than t_g on average...look into
% this later

p = 1 - tcdf(t_vals, df_g); % reference effect is one-tailed, so this is too...think about 2-tailed later

power_est = sum(p < alpha) / n_samples;

end

