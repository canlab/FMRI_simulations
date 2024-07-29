
  %% Power for 0.05 two-tailed, correlation

  create_figure('Power');

  rvals = [0.1 0.2 0.3 0.4 0.5];

  colors = custom_colors([.7 .5 .2], [1 .6 .2], length(rvals));

  % axis limits
  set(gca, 'XLim', [0 1000]);
  xlabel('Participants (N)');
  ylabel('Power')

  % crosshairs (n is determined in advance)
  hh = plot_horizontal_line(.8);
  set(hh, 'LineStyle', '--', 'Color', [.2 .2 .2])

  for i = 1:length(rvals)

      [ncrit,pow,obspow, ~, ~, lineh(i)] = power_calc(rvals(i), .025, 20, 'r', colors{i}, 0, 1);

      set(gca, 'YLim', [0 1])
      hh = plot_vertical_line(ncrit(1));
      set(hh, 'LineStyle', '--', 'Color', [.2 .2 .2])
      set(hh, 'YData', [0 0.8]);

  end

  set(gca, 'FontSize', 28);

  title('Power, Pearson''s r, p < 0.05 two-tailed');
  legend(lineh, cellstr(num2str(rvals'))', 'Location', 'SouthEast')

% One sample: d = 0.20, N needed 80% = 781 , N needed 50% = 385
% 
% One sample: d = 0.41, N needed 80% = 193 , N needed 50% =  97
% 
% One sample: d = 0.63, N needed 80% =  84 , N needed 50% =  44
% 
% One sample: d = 0.87, N needed 80% =  46 , N needed 50% =  25
% 
% One sample: d = 1.15, N needed 80% =  28 , N needed 50% =  16

    %% Power for 0.001 uncorrected

  create_figure('Power');

  rvals = [0.1 0.2 0.3 0.4 0.5];

  colors = custom_colors([.7 .5 .2], [1 .6 .2], length(rvals));

  % axis limits
  set(gca, 'XLim', [0 1000]);
  xlabel('Participants (N)');
  ylabel('Power')

  % crosshairs (n is determined in advance)
  hh = plot_horizontal_line(.8);
  set(hh, 'LineStyle', '--', 'Color', [.2 .2 .2])

  for i = 1:length(rvals)

      [ncrit,pow,obspow, ~, ~, lineh(i)] = power_calc(rvals(i), .001, 20, 'r', colors{i}, 0, 1);

      set(gca, 'YLim', [0 1])
      hh = plot_vertical_line(ncrit(1));
      set(hh, 'LineStyle', '--', 'Color', [.2 .2 .2])
      set(hh, 'YData', [0 0.8]);

  end

  set(gca, 'FontSize', 28);

  title('Power, Pearson''s r, p < 0.001');
  legend(lineh, cellstr(num2str(rvals'))', 'Location', 'SouthEast')


%   One sample: d = 0.20, N needed 80% = 1537 , N needed 50% = 953
% 
% One sample: d = 0.41, N needed 80% = 378 , N needed 50% = 237
% 
% One sample: d = 0.63, N needed 80% = 163 , N needed 50% = 104
% 
% One sample: d = 0.87, N needed 80% =  88 , N needed 50% =  58
% 
% One sample: d = 1.15, N needed 80% =  53 , N needed 50% =  36


  %% Power for 0.05 two-tailed, correlation
% EFFECT NOT CORRELATION

  create_figure('Power');

  dvals = [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9];

  colors = custom_colors([.7 .5 .2], [1 .6 .2], length(dvals));

  % axis limits
  set(gca, 'XLim', [0 1000]);
  xlabel('Participants (N)');
  ylabel('Power')

  % crosshairs (n is determined in advance)
  hh = plot_horizontal_line(.8);
  set(hh, 'LineStyle', '--', 'Color', [.2 .2 .2])

  for i = 1:length(dvals)

      [ncrit,pow,obspow, ~, ~, lineh(i)] = power_calc(dvals(i), .025, 20, 'd', colors{i}, 0, 1);

      set(gca, 'YLim', [0 1])
      hh = plot_vertical_line(ncrit(1));
      set(hh, 'LineStyle', '--', 'Color', [.2 .2 .2])
      set(hh, 'YData', [0 0.8]);

  end

  set(gca, 'FontSize', 28);

  title('Power, Cohen''s d, p < 0.05 two-tailed');
  legend(lineh, cellstr(num2str(dvals'))', 'Location', 'SouthEast')

% One sample: d = 0.10, N needed 80% = 787 , N needed 50% = 387
% 
% 2-group: d = 0.10, N per group 80% = 1572 , N per group 50% = 771
% 
% One sample: d = 0.20, N needed 80% = 199 , N needed 50% =  99
% 
% 2-group: d = 0.20, N per group 80% = 395 , N per group 50% = 195
% 
% One sample: d = 0.30, N needed 80% =  90 , N needed 50% =  46
% 
% 2-group: d = 0.30, N per group 80% = 177 , N per group 50% =  88
% 
% One sample: d = 0.40, N needed 80% =  52 , N needed 50% =  27
% 
% 2-group: d = 0.40, N per group 80% = 101 , N per group 50% =  51
% 
% One sample: d = 0.50, N needed 80% =  34 , N needed 50% =  18
% 
% 2-group: d = 0.50, N per group 80% =  65 , N per group 50% =  34
% 
% One sample: d = 0.10, N needed 80% = 787 , N needed 50% = 387
% 
% 2-group: d = 0.10, N per group 80% = 1572 , N per group 50% = 771
% 
% One sample: d = 0.20, N needed 80% = 199 , N needed 50% =  99
% 
% 2-group: d = 0.20, N per group 80% = 395 , N per group 50% = 195
% 
% One sample: d = 0.30, N needed 80% =  90 , N needed 50% =  46
% 
% 2-group: d = 0.30, N per group 80% = 177 , N per group 50% =  88
% 
% One sample: d = 0.40, N needed 80% =  52 , N needed 50% =  27
% 
% 2-group: d = 0.40, N per group 80% = 101 , N per group 50% =  51
% 
% One sample: d = 0.50, N needed 80% =  34 , N needed 50% =  18
% 
% 2-group: d = 0.50, N per group 80% =  65 , N per group 50% =  34
% 
% One sample: d = 0.60, N needed 80% =  24 , N needed 50% =  14
% 
% 2-group: d = 0.60, N per group 80% =  46 , N per group 50% =  24
% 
% One sample: d = 0.70, N needed 80% =  19 , N needed 50% =  11
% 
% 2-group: d = 0.70, N per group 80% =  35 , N per group 50% =  19
% 
% One sample: d = 0.80, N needed 80% =  15 , N needed 50% =   9
% 
% 2-group: d = 0.80, N per group 80% =  27 , N per group 50% =  15
% 
% One sample: d = 0.90, N needed 80% =  12 , N needed 50% =   8
% 
% 2-group: d = 0.90, N per group 80% =  22 , N per group 50% =  12
