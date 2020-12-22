function OUT = onsets2power(ons, varargin)
% Convert a set of onsets to power, given reference effect, variances, and sample size
% alpha version!!!
%
% Tor Wager, Michael Sun, Heejung Jung 2020
%
% power_est = onsets2power(ons, varargin)
% power_est = onsets2power(ons, 'N', 30)


% -------------------------------------------------------------------------
% DEFAULT ARGUMENT VALUES
% -------------------------------------------------------------------------

true_effect_size = 1;         % true effect
var_g = 1;                          % group variance; individual differences
s2 = 50;                        % scan-to-scan noise variance
N = 50;                         % sample size
alpha = 0.001;              % alpha value

epochdur = 0;
hrfshape = false; 

n_iter = 100000;

% -------------------------------------------------------------------------
% OPTIONAL INPUTS
% -------------------------------------------------------------------------

allowable_inputs = {'TR' 'contrasts' 'true_effect_size' 'var_g' 's2' 'N' 'alpha' 'n_iter' 'epochdur'};

% optional inputs with default values - each keyword entered will create a variable of the same name

for i = 1:length(varargin)
    
    if strcmp(varargin{i}, 'hrfshape'), hrfshape = true;
        
    elseif ischar(varargin{i})
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

% Generate true neural signal pre-convolution - enter as modulators
% -------------------------------------------------------------------------

% Prep contrasts and mod values
% Scale contrasts to mean diffs across conditions
%
% Generate true signal for every event type based on contrasts (hypotheses)
% Generate overall true signal based on sum of event type signals, then add
% noise.
%
% We create parametric mod values that implement our hypotheses about diffs
% among conditions (contrasts). Contrasts are used to generate true pmod
% values, which are scaled by the desired true effect size (true_effect_size) and
% passed to onsets2fmridesign to convolve them.
% This is used to generate the true signal, which is the same for every
% simulation/iteration, with different noise values added.

for i = 1:size(contrasts, 2)
    
    wh = contrasts(:, i) > 0;
    s = sum( contrasts(wh, i) );
    
    contrasts(:, i) = contrasts(:, i) ./ s;
    
    % factor in true effect size
    contrasts(:, i) = true_effect_size  .* contrasts(:, i);  
    
end

% add row for model intercept
contrasts(end+1, :) = 0;

%     contrasts = contrasts ./ repmat(sum(contrasts(contrasts > 0, )), size(contrasts, 1), 1);

pmod = cell(size(ons));
pmvals = sum(contrasts, 2); % overall amplitude of each regressor is based on effects (contrasts) that influence it

for i  = 1:length(ons)
    
    pmod{i} = ones(size(ons{i})) .* pmvals(i);
    
end

% get length
[X, delta, delta_hires, hrf] = onsets2fmridesign(ons, TR);
len = ceil(size(X, 1) .* TR);

% HRF
myhrf = spm_hrf(1) ./ max(spm_hrf(1));

% init values

OUT.regressors.p = ones(length(ons), n_iter);
[OUT.regressors.b, OUT.regressors.t] = deal(zeros(length(ons), n_iter));

OUT.contrasts.t = zeros(size(contrasts, 2), n_iter);
OUT.contrasts.p = ones(size(contrasts, 2), n_iter);

% Generate 'true' design matrix for purposes of generating true data y
% Run outside of loop unless we want to vary hrf shape
    % HRF random variation would happen here
    %     [X, delta, delta_hires, hrf] = onsets2fmridesign(ons, TR);
    % note: scaling of HRF for diff epochs****
    % Control amplitude scaling here; use 'noampscale'
    if ~hrfshape
        
        if epochdur
            % Epoch dur in sec - convolve
            
            hrfnew = conv(ones(epochdur, 1), myhrf);
            % DETERMINE REASONABLE SCALING.   hrfnew = hrfnew/ max(hrfnew);
            myhrf = hrfnew;
            
        end
        
        Xtrue = onsets2fmridesign(ons, TR, len, myhrf, 'parametric_singleregressor', pmod, 'noampscale');
    end
    
    % Design matrix we will fit to the data.
    X = onsets2fmridesign(ons, TR, len, myhrf, 'noampscale');
    
    
for i = 1:n_iter
    
    % Generate 'true' design matrix for purposes of generating true data y
    % -------------------------------------------------------------------------
    if hrfshape
        
        % generate semi-random HRF shape from a family
        % spm_hrf(1, params);
        % conv with semi-random length
        %myhrf = *** TO DO***
        
        % add epoch dur
        if epochdur
            % Epoch dur in sec - convolve
            
            hrfnew = conv(ones(epochdur, 1), myhrf);
            % DETERMINE REASONABLE SCALING.   hrfnew = hrfnew/ max(hrfnew);
            myhrf = hrfnew;
            
        end
        
        Xtrue = onsets2fmridesign(ons, TR, len, myhrf, 'parametric_singleregressor', pmod, 'noampscale');
        
    end
    

    % Generate true signal y
    % -----------------------------------
    
    % Add noise (ar). Default is std sigma=1. obs std should be greater
    w = noise_arp(size(X, 1));
    
    y = sum(Xtrue, 2) + w;
    
%     figure; plot(y)
%     hold on; plot(sum(X(:, 1:end-1), 2))

    % Fit the model, save stats on significance (power) and bias
    % -----------------------------------
    [b, dev, stat] = glmfit(X, y, 'normal', 'Constant', 'off');
    
    OUT.regressors.b(:, i) = b(1:end-1);
    OUT.regressors.t(:, i) = stat.t(1:end-1);
    OUT.regressors.p(:, i) = stat.p(1:end-1);
    
    % contrasts
    se_con = stat.s .^ 2 .* contrasts' * inv(X' * X) * contrasts;
    OUT.contrasts.t(:, i) = (b' * contrasts)' ./ sqrt(diag(se_con));
    OUT.contrasts.p(:, i) = 2 * (1 - tcdf(abs(OUT.contrasts.t(:, i)), len - size(X, 2)));
    
    
end

OUT.contrasts.sig05 = OUT.contrasts.p' < 0.05 & OUT.contrasts.t' > 0;
OUT.contrasts.power_est05 = sum(OUT.contrasts.sig05) ./ n_iter;

OUT.contrasts.sig001 = OUT.contrasts.p' < 0.001 & OUT.contrasts.t' > 0;
OUT.contrasts.power_est001 = sum(OUT.contrasts.sig001) ./ n_iter;

OUT.contrasts.sig0001 = OUT.contrasts.p' < 0.0001 & OUT.contrasts.t' > 0;
OUT.contrasts.power_est0001 = sum(OUT.contrasts.sig0001) ./ n_iter;

OUT.contrasts.sigfwer = OUT.contrasts.p' < 1e-8 & OUT.contrasts.t' > 0;
OUT.contrasts.power_estfwer = sum(OUT.contrasts.sigfwer) ./ n_iter;


% to do this, we likely want to generate true effect sizes a different way
% OUT.regressors.sig05 = OUT.regressors.p' < 0.05;
% OUT.regressors.power_est05 = sum(OUT.regressors.sig05) ./ n_iter;
% 
% OUT.regressors.sig001 = OUT.regressors.p' < 0.001;
% OUT.regressors.power_est001 = sum(OUT.regressors.sig001) ./ n_iter;
% 
% OUT.regressors.sig0001 = OUT.regressors.p' < 0.0001;
% OUT.regressors.power_est0001 = sum(OUT.regressors.sig0001) ./ n_iter;

end

