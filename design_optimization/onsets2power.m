function OUT = onsets2power(ons, varargin)
% Convert a set of onsets to power, given reference effect, variances, and sample size
% alpha version!!!
%
% Tor Wager, Michael Sun, Heejung Jung 2020
%
% power_est = onsets2power(ons, varargin)
% power_est = onsets2power(ons, 'N', 30)
%
% Simulate a situation where for every contrast, the conditions with
% positive contrast weights have a neural response magnitude equal to 1 *
% true desired effect size, and conditions with a negative contrast weight
% do not elicit a neural response. For different contrasts, we are thus
% simulating different true signals. We're simulating a voxel that shows a
% true effect for each specified contrast.
% Note: This will not work correctly for contrasts that are not
% comparisons of means...e.g., [-3 -1 1 3] contasts.


% -------------------------------------------------------------------------
% DEFAULT ARGUMENT VALUES
% -------------------------------------------------------------------------
contrasts = [];
true_effect_size = 1;         % true effect
% var_g = 1;                    % group variance; individual differences UNUSED RIGHT NOW
% s2 = 50;                        % scan-to-scan noise variance
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
% values,
% We want to simulate a true effect magnitude that is constant for a trial type across
% all contrasts.  If we scale contrast weights, neural effects will be larger for some contrasts
% than others, which makes comparing [A B C] vs. [D E F] equally powerful as [A vs. D] because
% the neural effect magnitude is smaller for the former than latter contrast. This is undesirable.
% Solution: Input true effect magnitude for a given condition rather than effect size
%
% Contrast regressors are passed to onsets2fmridesign to convolve them.
% This is used to generate the true signal, which is the same for every
% simulation/iteration, with different noise values added.

% Simulate a situation where for every contrast, the conditions with
% positive contrast weights have a neural response magnitude equal to 1 *
% true desired effect size, and conditions with a negative contrast weight
% do not elicit a neural response. For different contrasts, we are thus
% simulating different true signals. We're simulating a voxel that shows a
% true effect for each specified contrast.

% Fix neural effect magnitude at 1 or -1; see above.
true_neural_signal_weights = contrasts;
wh = contrasts > 0;
true_neural_signal_weights(wh) = 1;
wh = contrasts < 0;
true_neural_signal_weights(wh) = 0;

true_neural_signal_weights = true_effect_size  .* true_neural_signal_weights;

% old way - see above
% for i = 1:size(contrasts, 2)
%
%     wh = contrasts(:, i) > 0;
%
%     % Do not scale contrast-wise; see above
%     %     s = sum( contrasts(wh, i) );
%     %     contrasts(:, i) = contrasts(:, i) ./ s;
%
%     % factor in true effect size
%     contrasts(:, i) = true_effect_size  .* contrasts(:, i);
%
% end

% add row for model intercept
contrasts(end+1, :) = 0;

%     contrasts = contrasts ./ repmat(sum(contrasts(contrasts > 0, )), size(contrasts, 1), 1);

pmod = cell(size(ons));
pmvals = sum(true_neural_signal_weights, 2); % overall amplitude of each regressor is based on effects (contrasts) that influence it

for i  = 1:length(ons)
    
    pmod{i} = ones(size(ons{i})) .* pmvals(i);
    
end

% get length
X = onsets2fmridesign(ons, TR);
len = ceil(size(X, 1) .* TR) + 1;  % Added 1 to avoid cutting off final event within TR/16 of end

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


if epochdur
    % Epoch dur in sec - convolve
    % amp of this will be too large to be realistic, but adjusted
    % below using 'nonlinsaturation'
    myhrf = conv(ones(ceil(epochdur), 1), myhrf);
    
    % Don't use epochs built into onsets2fmridesign, because we want to
    % control scaling and sample at 1 sec when generating simulated true activity
    
    if ~hrfshape
        Xtrue = onsets2fmridesign(ons, TR, len, myhrf, 'parametric_singleregressor', pmod, 'noampscale', 'nonlinsaturation');
    end
    
else
    
    if ~hrfshape
        Xtrue = onsets2fmridesign(ons, TR, len, myhrf, 'parametric_singleregressor', pmod, 'noampscale');
    end
    
end

% Design matrix we will fit to the data.
% This is used whether hrfshape = true or false
X = onsets2fmridesign(ons, TR, len, myhrf, 'noampscale');


for i = 1:n_iter
    
    % Generate 'true' design matrix for purposes of generating true data y
    % -------------------------------------------------------------------------
    if hrfshape
        % choose constrained random-shape HRF for every iteration
        % generate semi-random HRF shape from a family
        % spm_hrf(1, params);
        % conv with semi-random length
        
        %         for i = 1:100
        
        %height = 1;
        delay = exprnd(1);        % onset delay
        peak = normrnd(6, 3);       % time to peak
        peak(peak <= 0) = 1;
        uonset = normrnd(16, 1);    % undershoot onset
        dispers = normrnd(1, .3);       % dispersion (0 = nan, low = peaked; high = diffuse)
        dispers(dispers <= 0) = 1;
        udisp = normrnd(1, .3);       % undershoot dispersion (0 = nan, low = peaked; high = diffuse)
        udisp(udisp <= 0) = 1;
        rtou = normrnd(6, 3);       % response to undershoot
        klength = 32;
        
        p = [peak uonset dispers udisp rtou delay klength];
        
        true_hrf_this_iter = spm_hrf(1, p);
        true_hrf_this_iter = true_hrf_this_iter ./ max(true_hrf_this_iter);
        
        %         plot(true_hrf_this_iter)
        %
        %         end
        
        
        if epochdur
            % Epoch dur in sec - convolve
            % amp of this will be too large to be realistic, but adjusted
            % below using 'nonlinsaturation'
            % Don't normalize: signal magnitude is effectively input mag. *
            % number of seconds duration.
            trueepochdur = min(1, round(normrnd(epochdur, 3)));
            true_hrf_this_iter = conv(ones(trueepochdur, 1), true_hrf_this_iter);
            
            % Don't use epochs built into onsets2fmridesign, because we want to
            % control scaling and sample at 1 sec when generating simulated true activity
            
            Xtrue = onsets2fmridesign(ons, TR, len, true_hrf_this_iter, 'parametric_singleregressor', pmod, 'noampscale', 'nonlinsaturation');
            
            
        else
            trueepochdur = 1 + geornd(.5); % true epochs are somewhat longer than assumed (min = 1, for single event)
            % Normalize here so that epoch does not influence effect
            % magnitude. With epochs specified, we're assuming there is
            % greater true signal, so don't normalize in this way.
            true_hrf_this_iter = conv(ones(trueepochdur, 1) ./ trueepochdur, true_hrf_this_iter);
            
            Xtrue = onsets2fmridesign(ons, TR, len, true_hrf_this_iter, 'parametric_singleregressor', pmod, 'noampscale');
            
        end
        

    end % if hrfshape
    
    
    
    % Generate true signal y
    % -----------------------------------
    
    % Add noise (ar). Default is std sigma=1. obs std should be greater
    w = noise_arp(size(X, 1));
    
    y = sum(Xtrue, 2) + w;
    
    %     figure; plot(y)
    %     hold on; plot(sum(X(:, 1:end-1), 2))
    
    % Fit the model, save stats on significance (power) and bias
    % -----------------------------------
    [b, ~, stat] = glmfit(X, y, 'normal', 'Constant', 'off');
    
    OUT.regressors.b(:, i) = b(1:end-1);
    OUT.regressors.t(:, i) = stat.t(1:end-1);
    OUT.regressors.p(:, i) = stat.p(1:end-1);
    
    % contrasts
    se_con = stat.s .^ 2 .* contrasts' * inv(X' * X) * contrasts;
    OUT.contrasts.t(:, i) = (b' * contrasts)' ./ sqrt(diag(se_con));
    OUT.contrasts.p(:, i) = 2 * (1 - tcdf(abs(OUT.contrasts.t(:, i)), len - size(X, 2)));
    
    
end

OUT.contrasts.sig = OUT.contrasts.p' < alpha & OUT.contrasts.t' > 0;
OUT.contrasts.power_est = sum(OUT.contrasts.sig, 1) ./ n_iter;
OUT.contrasts.alpha = alpha;

OUT.contrasts.sig05 = OUT.contrasts.p' < 0.05 & OUT.contrasts.t' > 0;
OUT.contrasts.power_est05 = sum(OUT.contrasts.sig05, 1) ./ n_iter;

OUT.contrasts.sig001 = OUT.contrasts.p' < 0.001 & OUT.contrasts.t' > 0;
OUT.contrasts.power_est001 = sum(OUT.contrasts.sig001, 1) ./ n_iter;

OUT.contrasts.sig0001 = OUT.contrasts.p' < 0.0001 & OUT.contrasts.t' > 0;
OUT.contrasts.power_est0001 = sum(OUT.contrasts.sig0001, 1) ./ n_iter;

OUT.contrasts.sigfwer = OUT.contrasts.p' < 1e-8 & OUT.contrasts.t' > 0;
OUT.contrasts.power_estfwer = sum(OUT.contrasts.sigfwer, 1) ./ n_iter;


% to do this, we likely want to generate true effect sizes a different way
OUT.regressors.sig05 = OUT.regressors.p' < 0.05;
OUT.regressors.power_est05 = sum(OUT.regressors.sig05, 1) ./ n_iter;

OUT.regressors.sig001 = OUT.regressors.p' < 0.001;
OUT.regressors.power_est001 = sum(OUT.regressors.sig001, 1) ./ n_iter;

OUT.regressors.sig0001 = OUT.regressors.p' < 0.0001;
OUT.regressors.power_est0001 = sum(OUT.regressors.sig0001, 1) ./ n_iter;

end % main function

