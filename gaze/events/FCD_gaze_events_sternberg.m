%% Visualization of gaze events for FCD

% Visualizations:
%   

%% Setup
clear
clc
close all
path = '/Volumes/methlab/Students/Arne/FCD/data/features/';
dirs = dir(path);
folders = dirs([dirs.isdir] & ~ismember({dirs.name}, {'.', '..'}));
subjects = {folders.name};

%% Load gaze data
for subj = 1:length(subjects)
    datapath = strcat(path,subjects{subj}, '/gaze/');
    cd(datapath)
    % Saccades
    load('saccades.mat');  
    saccs2(subj) =      mean([sacc2{1:end}]');
    saccs4(subj) =      mean([sacc4{1:end}]');
    saccs6(subj) =      mean([sacc6{1:end}]');
    saccs2fix(subj) =   mean([sacc2fix{1:end}]');
    saccs4fix(subj) =   mean([sacc4fix{1:end}]');
    saccs6fix(subj) =   mean([sacc6fix{1:end}]');
    % Fixations
    load('fixations.mat'); 
    fixs2(subj) =       mean([fix2{1:end}]');
    fixs4(subj) =       mean([fix4{1:end}]');
    fixs6(subj) =       mean([fix6{1:end}]');
    fixs2fix(subj) =    mean([fix2fix{1:end}]');
    fixs4fix(subj) =    mean([fix4fix{1:end}]');
    fixs6fix(subj) =    mean([fix6fix{1:end}]');
    % Blinks
    load('blinks.mat');
    blinks2(subj) =     mean([blink2{1:end}]');
    blinks4(subj) =     mean([blink4{1:end}]');
    blinks6(subj) =     mean([blink6{1:end}]');
    blinks2fix(subj) =  mean([blink2fix{1:end}]');
    blinks4fix(subj) =  mean([blink4fix{1:end}]');
    blinks6fix(subj) =  mean([blink6fix{1:end}]');
end
dataSacc = [saccs2', saccs4', saccs6'];
dataSaccFix = [saccs2fix', saccs4fix', saccs6fix'];
dataFix = [fixs2', fixs4', fixs6'];
dataFixFix = [fixs2fix', fixs4fix', fixs6fix'];
dataBlink = [blinks2', blinks4', blinks6'];
dataBlinkFix = [blinks2fix', blinks4fix', blinks6fix'];

%% BARPLOT SACCADES individual participants percentage changes from NoFix to FIX 
close all
for subs = 1:length(subjects)
    saccChange2(subs) = (dataSaccFix(subs, 1) - dataSacc(subs, 1)) / dataSaccFix(subs, 1) * 100;
    saccChange4(subs) = (dataSaccFix(subs, 2) - dataSacc(subs, 2)) / dataSaccFix(subs, 2) * 100;
    saccChange6(subs) = (dataSaccFix(subs, 3) - dataSacc(subs, 3)) / dataSaccFix(subs, 3) * 100;
end

% Bar Plot for Relative Differences
figure;
set(gcf, 'Position', [200, 200, 1400, 600], 'Color', 'w'); 
data = [saccChange2', saccChange4', saccChange6'];
conditions = {'WM load2', 'WM load 4', 'WM load 6'};
colors = {'b', 'k', 'r'};
hbar = bar(data);
for k = 1:length(hbar)
    hbar(k).FaceColor = colors{k};
end
% set(gca, 'YLim', [min(data(:)) * 1.15 max(data(:)) * 1.25]);
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Change in Saccades [%]', 'FontName', 'Arial', 'FontSize', 20);
title('Relative Change in Saccade Occurences from BLANK to FIXCROSS', 'FontName', 'Arial', 'FontSize', 25);
legend(conditions, 'FontName', 'Arial', 'FontSize', 15, 'Location', 'southwest');

medians = [median(saccChange2), median(saccChange4), median(saccChange6)];
means = [mean(saccChange2), mean(saccChange4), mean(saccChange6)];
for i = 1:3
    text(i+2, -200, sprintf('Median: %.1f%%', medians(i)), 'FontSize', 15, 'FontName', 'Arial', 'Color', colors{i});
    text(i+2, -220, sprintf('Mean: %.1f%%', means(i)), 'FontSize', 15, 'FontName', 'Arial', 'Color', colors{i});
end

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/gaze/events/barplot/FCD_gaze_events_saccades_barplot.png');

%% BARPLOT FIXATIONS individual participants percentage changes from NoFix to FIX 
close all
for subs = 1:length(subjects)
    fixChange2(subs) = (dataFixFix(subs, 1) - dataFix(subs, 1)) / dataFixFix(subs, 1) * 100;
    fixChange4(subs) = (dataFixFix(subs, 2) - dataFix(subs, 2)) / dataFixFix(subs, 2) * 100;
    fixChange6(subs) = (dataFixFix(subs, 3) - dataFix(subs, 3)) / dataFixFix(subs, 3) * 100;
end

% Bar Plot for Relative Differences
figure;
set(gcf, 'Position', [200, 200, 1400, 600], 'Color', 'w'); 
data = [fixChange2', fixChange4', fixChange6'];
conditions = {'WM load2', 'WM load 4', 'WM load 6'};
colors = {'b', 'k', 'r'};
hbar = bar(data);
for k = 1:length(hbar)
    hbar(k).FaceColor = colors{k};
end
% set(gca, 'YLim', [min(data(:)) * 1.15 max(data(:)) * 1.25]);
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Change in Fixations [%]', 'FontName', 'Arial', 'FontSize', 20);
title('Relative Change in Fixation Occurences from BLANK to FIXCROSS', 'FontName', 'Arial', 'FontSize', 25);
legend(conditions, 'FontName', 'Arial', 'FontSize', 15, 'Location', 'southwest');

medians = [median(fixChange2), median(fixChange4), median(fixChange6)];
means = [mean(fixChange2), mean(fixChange4), mean(fixChange6)];
for i = 1:3
    text(i+2, -200, sprintf('Median: %.1f%%', medians(i)), 'FontSize', 15, 'FontName', 'Arial', 'Color', colors{i});
    text(i+2, -220, sprintf('Mean: %.1f%%', means(i)), 'FontSize', 15, 'FontName', 'Arial', 'Color', colors{i});
end

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/gaze/events/barplot/FCD_gaze_events_fixations_barplot.png');

%% BARPLOT BLINKS individual participants percentage changes from NoFix to FIX 
close all
for subs = 1:length(subjects)
    blinkChange2(subs) = (dataBlinkFix(subs, 1) - dataBlink(subs, 1)) / dataBlinkFix(subs, 1) * 100;
    blinkChange4(subs) = (dataBlinkFix(subs, 2) - dataBlink(subs, 2)) / dataBlinkFix(subs, 2) * 100;
    blinkChange6(subs) = (dataBlinkFix(subs, 3) - dataBlink(subs, 3)) / dataBlinkFix(subs, 3) * 100;
end

% Bar Plot for Relative Differences
figure;
set(gcf, 'Position', [200, 200, 1400, 600], 'Color', 'w'); 
data = [blinkChange2', blinkChange4', blinkChange6'];
conditions = {'WM load2', 'WM load 4', 'WM load 6'};
colors = {'b', 'k', 'r'};
hbar = bar(data);
for k = 1:length(hbar)
    hbar(k).FaceColor = colors{k};
end
% set(gca, 'YLim', [min(data(:)) * 1.15 max(data(:)) * 1.25]);
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Change in Blinks [%]', 'FontName', 'Arial', 'FontSize', 20);
title('Relative Change in Blink Occurences from BLANK to FIXCROSS', 'FontName', 'Arial', 'FontSize', 25);
legend(conditions, 'FontName', 'Arial', 'FontSize', 15, 'Location', 'southwest');

medians = [median(blinkChange2), median(blinkChange4), median(blinkChange6)];
means = [mean(blinkChange2), mean(blinkChange4), mean(blinkChange6)];
for i = 1:3
    text(i+2, 40, sprintf('Median: %.1f%%', medians(i)), 'FontSize', 15, 'FontName', 'Arial', 'Color', colors{i});
    text(i+2, 30, sprintf('Mean: %.1f%%', means(i)), 'FontSize', 15, 'FontName', 'Arial', 'Color', colors{i});
end

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/gaze/events/barplot/FCD_gaze_events_blinks_barplot.png');