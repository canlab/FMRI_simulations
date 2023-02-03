% time series plot - alias to low frequencies

% 2*pi radians is one period of the sine wave.
% this code will produce a sine wave with periodicity of 40.5 samples.
% so signal frequency is 1/40.5 samples
% there will be about 20 periods in the plot

x = 0:1/(2*pi):40*pi + 1/(2*pi);
y = sin(x); 
rad2s = inline('x ./ (2*pi)');
s = rad2s(x);                   % assume this happens over 20 seconds (arbitrary)

figure('Color','w','Position',[68         784        1431         227]);
plot(s,y, 'LineWidth', 2)

% undersample: every 40 elements is ~every 2 sec (TR = 2)
sh = 5; 
z = y(sh:40:end);  % z is undersampled signal
z2 = s(sh:40:end); 
hold on; 
plot(z2,z,'ro--', 'LineWidth', 3)

sig1 = z; % save for fft plot

set(gca, 'FontSize', 20, 'YColor', 'w');
axis off
% dt = diff(s)
% dt(1) * 40
% % 1.01 sec = downsampling

%% Time series plot - sample at Nyquist

% 2*pi radians is one period of the sine wave.
% this code will produce a sine wave with periodicity of 40.5 samples.
% so signal frequency is 1/40.5 samples
% there will be about 20 periods in the plot

x = 0:1/(2*pi):40*pi + 1/(2*pi);
y = sin(x);
rad2s = inline('x ./ (2*pi)');
s = rad2s(x);                   % assume this happens over 20 seconds (arbitrary)

figure('Color','w','Position',[68         784        1431         227]);
plot(s,y, 'LineWidth', 2)
axis tight
text(21, 0.3, 'Sampling at', 'FontSize', 24 );
text(21, -0.3, 'the signal period', 'FontSize', 24 );
set(gca, 'XLim', [0 23]);

% undersample: every 40 elements is ~every 2 sec (TR = 2)
% every 20 elements is twice the sampling freq, the Nyquist limit
for sampleevery = 80:-1:2
    
    sh = 5;
    %sampleevery = 10;
    z = y(sh:sampleevery:end);  % z is undersampled signal
    z2 = s(sh:sampleevery:end);
    hold on;
    if exist('hh', 'var') && ishandle(hh), delete(hh); end
    hh = plot(z2,z,'ro--', 'LineWidth', 3);
    
    set(gca, 'FontSize', 20, 'YColor', 'w');
    axis off
    
    if exist('hh2', 'var') && ishandle(hh2), delete(hh2); end
    hh2 = text(21, 0, sprintf('%3.1fx', 40/sampleevery), 'FontSize', 24);
    
    drawnow
    pause(.8)
    
end

% dt = diff(s)
% dt(1) * 40
% % 1.01 sec = downsampling

%% time series plot - alias to moderate frequencies

x = 0:1/(2*pi):40*pi;
y = sin(x); 

rad2s = inline('x ./ (2*pi) * 60 ./ P1', 1);   % p1 is frequency in cycles / s
s = rad2s(x,80);

figure('Color','w','Position',[68         784        1431         227]);
plot(s,y, 'LineWidth', 2)

RTy = 1./length(s(s < 1));
sh = 5; 
z = y(sh:length(s(s < 1)):end);  % signal - undersampled
z2=s(sh:length(s(s < 1)):end);   % x

hold on; 
plot(z2,z,'ro--', 'LineWidth', 3)

set(gca, 'FontSize', 20, 'YColor', 'w');
axis off

%% FFT plot

%create_figure('fft');
% 
% 
% [myfft, freq, handle] = fft_plot_scnlab(sig1, dt, 'color', 'r'); hold on
% 
% [myfft, freq, handle] = fft_plot_scnlab(z, 1/RTy, 'color', [1 .5 0]);
% 
% [myfft, freq, handle] = fft_plot_scnlab(y, dt, 'color', [0    0.4470    0.7410]);

%% OLD - but good

figure('Color','w'); 
hold on

zz = abs(fft(z)); zz = zz./max(zz); 
plot((1:round(length(zz)./2)) ./ length(zz), zz(1:round(length(zz)./2)),'ro-', 'LineWidth', 3)

yy = abs(fft(y)); 
yy2 = yy(1:round(length(yy)./2)); yy2 = yy2./max(yy2);
hold on; 
plot((1:round(length(yy)./2)) ./ (RTy * length(yy)), yy2,'o-', 'Color', [0    0.4470    0.7410], 'LineWidth', 3)

title('Frequency','FontSize',18)
xlabel('Hz','FontSize',18)
set(gca,'FontSize',18)

set(gca,'XLim',[0 2])
