%% Alpha Power Time Frequency Analysis for FCD Sternberg data
clear
clc
close all
run startup
path = '/Volumes/methlab/Students/Arne/FCD/data/features/';
dirs = dir(path);
folders = dirs([dirs.isdir] & ~ismember({dirs.name}, {'.', '..'}));
subjects = {folders.name};

%% Compute grand average time and frequency data GATFR
for subj= 1:length(subjects)
    datapath = strcat(path,subjects{subj}, '/eeg');
    cd(datapath)
    load tfr_stern
    tfr2_all{subj} = tfr2;
    tfr4_all{subj} = tfr4;
    tfr6_all{subj} = tfr6;
    disp(['Subject ' num2str(subj) '/' num2str(length(subjects)) ' TFR loaded.'])
end

% Load fixation data
for subj= 1:length(subjects)
    datapath = strcat(path,subjects{subj}, '/eeg');
    cd(datapath)
    load tfr_stern_fix
    tfr2_all_fix{subj} = tfr2;
    tfr4_all_fix{subj} = tfr4;
    tfr6_all_fix{subj} = tfr6;
    disp(['Subject ' num2str(subj) '/' num2str(length(subjects)) ' TFR with fixation loaded.'])
end

% Compute grand average
gatfr2 = ft_freqgrandaverage([],tfr2_all{:});
gatfr4 = ft_freqgrandaverage([],tfr4_all{:});
gatfr6 = ft_freqgrandaverage([],tfr6_all{:});

gatfr2_fix = ft_freqgrandaverage([],tfr2_all_fix{:});
gatfr4_fix = ft_freqgrandaverage([],tfr4_all_fix{:});
gatfr6_fix = ft_freqgrandaverage([],tfr6_all_fix{:});

%% Define channels
load('tfr_stern.mat');
% Occipital channels
occ_channels = {};
for i = 1:length(tfr2.label)
    label = tfr2.label{i};
    if contains(label, {'O'}) 
        occ_channels{end+1} = label;
    end
end
channels = occ_channels;

%% Plot TFR for each individual condition
close all

% Common configuration
cfg = [];
load('/Volumes/methlab/Students/Arne/MA/headmodel/layANThead.mat'); % Load layout
cfg.layout = layANThead; % your specific layout
cfg.baseline = [-Inf -0.5]; % baseline correction window in seconds
cfg.baselinetype = 'absolute'; % type of baseline correction
cfg.showlabels = 'yes'; % show channel labels
cfg.colorbar = 'yes'; % include color bar
cfg.zlim = 'maxabs'; % color limits
cfg.xlim = ([-0.5 2]);
cfg.ylim = [5 20];
clim = ([-5 5]);
color_map = flipud(cbrewer('div', 'RdBu', 64)); % 'RdBu' for blue to red diverging color map

% WM load 2 NOFIX
figure;
set(gcf, 'Position', [100, 200, 2000, 1200], 'Color', 'w');

ft_singleplotTFR(cfg, gatfr2);
colormap(color_map);
set(gca, 'CLim', clim);
set(gca, 'FontSize', 20)
colorbar;
xlabel('Time [ms]');
ylabel('Frequency [Hz]');
title('Sternberg WM load 2 TFR NOFIX');

saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/tfr/FCD_tfr_ga_sternberg_2_nofix.png');

% WM load 2 FIX
figure;
set(gcf, 'Position', [100, 200, 2000, 1200], 'Color', 'w');

ft_singleplotTFR(cfg, gatfr2_fix);
colormap(color_map);
set(gca, 'CLim', clim);
set(gca, 'FontSize', 20)
colorbar;
xlabel('Time [ms]');
ylabel('Frequency [Hz]');
title('Sternberg WM load 2 TFR FIX');

saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/tfr/FCD_tfr_ga_sternberg_2_fix.png');

% WM load 4 NOFIX
figure;
set(gcf, 'Position', [100, 200, 2000, 1200], 'Color', 'w');

ft_singleplotTFR(cfg, gatfr4);
colormap(color_map);
set(gca, 'CLim', clim);
set(gca, 'FontSize', 20)
colorbar;
xlabel('Time [ms]');
ylabel('Frequency [Hz]');
title('Sternberg WM load 4 TFR NOFIX');

saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/tfr/FCD_tfr_ga_sternberg_4_nofix.png');

% WM load 4 FIX
figure;
set(gcf, 'Position', [100, 200, 2000, 1200], 'Color', 'w');

ft_singleplotTFR(cfg, gatfr4_fix);
colormap(color_map);
set(gca, 'CLim', clim);
set(gca, 'FontSize', 20)
colorbar;
xlabel('Time [ms]');
ylabel('Frequency [Hz]');
title('Sternberg WM load 4 TFR FIX');

saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/tfr/FCD_tfr_ga_sternberg_4_fix.png');

% WM load 6 NOFIX
figure;
set(gcf, 'Position', [100, 200, 2000, 1200], 'Color', 'w');

ft_singleplotTFR(cfg, gatfr6);
colormap(color_map);
set(gca, 'CLim', clim);
set(gca, 'FontSize', 20)
colorbar;
xlabel('Time [ms]');
ylabel('Frequency [Hz]');
title('Sternberg WM load 6 TFR NOFIX');

saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/tfr/FCD_tfr_ga_sternberg_6_nofix.png');

% WM load 6 FIX
figure;
set(gcf, 'Position', [100, 200, 2000, 1200], 'Color', 'w');

ft_singleplotTFR(cfg, gatfr6_fix);
colormap(color_map);
set(gca, 'CLim', clim);
set(gca, 'FontSize', 20)
colorbar;
xlabel('Time [ms]');
ylabel('Frequency [Hz]');
title('Sternberg WM load 6 TFR FIX');

saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/tfr/FCD_tfr_ga_sternberg_6_fix.png');


%% Plot the grand averages for the DIFFERENCE 
close all

% Compute difference
diff = gatfr6;
diff.powspctrm = gatfr6.powspctrm - gatfr2.powspctrm;

diff_fix = gatfr6_fix;
diff_fix.powspctrm = gatfr6_fix.powspctrm - gatfr2_fix.powspctrm;

% Define configuration for multiplot
cfg = [];
load('/Volumes/methlab/Students/Arne/MA/headmodel/layANThead.mat');
cfg.layout = layANThead; % your specific layout
cfg.channel = channels; % specify the channels to include
cfg.showlabels = 'yes'; % show channel labels
cfg.colorbar = 'yes'; % include color bar
cfg.xlim = [1 2]; 
cfg.ylim = [5 20];
color_map = flipud(cbrewer('div', 'RdBu', 64)); % 'RdBu' for blue to red diverging color map
clim = [-2.75, 2.75];

% Plot: Difference Time-Frequency Response NOFIX
figure;
set(gcf, 'Position', [100, 200, 2000, 1200], 'Color', 'w');

ft_singleplotTFR(cfg, diff);
xlabel('Time [s]');
ylabel('Frequency [Hz]');
colorbar;
colormap(color_map);
set(gca, 'FontSize', 25);
title('Sternberg TFR Diff (WM load 6 minus WM load 2) NOFIX', 'FontName', 'Arial', 'FontSize', 30);
set(gca, 'CLim', clim);
yline(8, 'LineWidth', 5, 'LineStyle', '-', 'Color', 'r');
yline(14, 'LineWidth', 5, 'LineStyle', '-', 'Color', 'r');

% Save 
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/tfr/FCD_tfr_sternberg_diff_nofix.png');

%% Plot: Difference Time-Frequency Response FIX
figure;
set(gcf, 'Position', [100, 200, 2000, 1200], 'Color', 'w');
clim = [-20, 20];

ft_singleplotTFR(cfg, diff_fix);
xlabel('Time [s]');
ylabel('Frequency [Hz]');
colorbar;
colormap(color_map);
set(gca, 'FontSize', 25);
title('Sternberg TFR Diff (WM load 6 minus WM load 2) FIX', 'FontName', 'Arial', 'FontSize', 30);
set(gca, 'CLim', clim);
yline(8, 'LineWidth', 5, 'LineStyle', '-', 'Color', 'r');
yline(14, 'LineWidth', 5, 'LineStyle', '-', 'Color', 'r');

% Save 
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/tfr/FCD_tfr_sternberg_diff_fix.png');
