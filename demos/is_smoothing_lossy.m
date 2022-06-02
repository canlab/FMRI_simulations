

dat = noise_arp(1000, [0.7 0.1]);
[dat_smoothed, I, S] = hpfilter(dat, 2, 120, 1000);

% This doesn't work because rank is 967, not 1000, so it TOTALLY fails
% datprime = inv(S) * dat_smoothed; rank(S)

% Try this instead to recover original, approximately
datprime = pinv(S) * dat_smoothed;

figure; plot(dat); 
hold on; plot(datprime)

% it kinda works. but not perfectly.

% if we add some noise, it might work less well...
% small diffs may lead to large diffs
std(dat)
datprime2 = pinv(S) * dat_smoothed + .05 * std(dat) * randn(1000, 1);

plot(datprime2)

% it's not too affected by a small amount of noise added in this way.

corr([dat datprime datprime2])


%%

% figure; imagesc(dat_smoothed); colorbar
% figure; imagesc(dat); colorbar

figure; imagesc(yprime); colorbar
yprime = pinv(S) * dat_smoothed;
figure; imagesc(yprime - dat); colorbar

