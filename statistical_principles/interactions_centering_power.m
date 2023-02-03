x1 = 3 + randn(100, 1); x2 = 3 + randn(100, 1); x3 = x1 .* x2;
X = [x1 x2 x3 ones(size(x1))];
y = X * [1 1 1 5]' + 20 * randn(size(x1));

figure; hold on; plot(x1, y, 'k.'); refline
plot(x2, y, 'k.'); refline
corr(X)
figure; hold on; plot3(x1, x2, x3, 'k.');
%figure; hold on; surf(x1, x2, x3);

vifs = getvif(X)
vifs = getvif(X(:, 1:2))

[b, dev, stat] = glmfit(X(:, 1:3), y);

glm_table(stat, {'x1' 'x2' 'x1*x2'}, b);

% new design matrix where I center the interactions

X2 = [zscore(x1) zscore(x2) zscore(x1) .* zscore(x2) ones(size(x1))];

[b2, dev, stat2] = glmfit(X2(:, 1:3), y);

glm_table(stat2, {'x1' 'x2' 'x1*x2'}, b2);


t = array2table([b b2], 'RowNames', {'Intcpt' 'x1' 'x2' 'x1*x2'}, 'VariableNames', {'b_noncen' 'b_cent'});
disp(t)

% this makes interaction interpretable as the crossover -- effect of x1
% depends on x2 and vice versa.

% otherwise, b3 (interaction) also

%%
y = X * [1 0 0 5]' + 5 * randn(size(x1));

disp('No centering of predictors')
[b, dev, stat] = glmfit(X(:, 1:3), y);
glm_table(stat, {'x1' 'x2' 'x1*x2'}, b);

disp('Centering of predictors')
[b2, dev, stat2] = glmfit(X2(:, 1:3), y);
glm_table(stat2, {'x1' 'x2' 'x1*x2'}, b2);

t = array2table([b b2], 'RowNames', {'Intcpt' 'x1' 'x2' 'x1*x2'}, 'VariableNames', {'b_noncen' 'b_cent'});
disp(t)

