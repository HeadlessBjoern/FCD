%% Visualization of gaze deviation for FCD

% Visualizations:
%   Boxplots of euclidean distances for gaze deviation

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
    datapath = strcat(path, subjects{subj}, '/gaze');
    cd(datapath);
    load('gaze_dev_sternberg.mat');
    l2gazedev{subj} = l2gdev;
    l4gazedev{subj} = l4gdev;
    l6gazedev{subj} = l6gdev;

    load('gaze_dev_sternberg_fix.mat');
    l2gazedevfix{subj} = l2gdevfix;
    l4gazedevfix{subj} = l4gdevfix;
    l6gazedevfix{subj} = l6gdevfix;
end

% Concatenate all subjects' data for each condition
all_l2 = vertcat(l2gazedev{:});
all_l4 = vertcat(l4gazedev{:});
all_l6 = vertcat(l6gazedev{:});
all_l2fix = vertcat(l2gazedevfix{:});
all_l4fix = vertcat(l4gazedevfix{:});
all_l6fix = vertcat(l6gazedevfix{:});

%% GAZE DEVIATION BOXPLOTS
dataDeviation = [all_l2, all_l4, all_l6];
dataDeviationFix = [all_l2fix, all_l4fix, all_l6fix];

% Plot setup
figure;
set(gcf, 'Position', [100, 100, 1200, 600], 'Color', 'w'); 
colors = {'b', 'k', 'r'};
conditions = {'WM load 2', 'WM load 4', 'WM load 6'};

% Gaze Deviation without Fixation Cross
subplot(1,2,1);
hold on;
boxplot(dataDeviation, 'Colors', 'k', 'Symbol', '', 'Widths', 0.5);

% Plot individual data points and lines connecting the same participants
for subj = 1:length(subjects)
    plot(1:length(conditions), dataDeviation(subj, :), '-o', 'Color', [0.5, 0.5, 0.5], 'MarkerFaceColor', 'w');
end

% Scatter plot for individual points
scatterHandles = gobjects(1, length(conditions));
for condIdx = 1:length(conditions)
    scatterHandles(condIdx) = scatter(repelem(condIdx, length(subjects)), dataDeviation(:, condIdx), 100, colors{condIdx}, 'filled', 'MarkerEdgeColor', 'k');
end

xlabel('Conditions', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Mean Euclidean Deviation [px]', 'FontName', 'Arial', 'FontSize', 20);
set(gca, 'XTick', 1:length(conditions), 'XTickLabel', conditions, 'FontSize', 15);
set(gca, 'LineWidth', 1.5);
set(gca, 'XLim', [0.5 length(conditions) + 0.5]);
set(gca, 'YLim', [min(dataDeviation(:)) * 0.85 max(dataDeviation(:)) * 1.15]);
legend(scatterHandles, conditions, 'FontName', 'Arial', 'FontSize', 15, 'Location', 'best');
title('Gaze Deviation Blank', 'FontName', 'Arial', 'FontSize', 25);
hold off;

% Gaze Deviation with Fixation Cross
subplot(1,2,2);
hold on;
boxplot(dataDeviationFix, 'Colors', 'k', 'Symbol', '', 'Widths', 0.5);

% Plot individual data points and lines connecting the same participants
for subj = 1:length(subjects)
    plot(1:length(conditions), dataDeviationFix(subj, :), '-o', 'Color', [0.5, 0.5, 0.5], 'MarkerFaceColor', 'w');
end

% Scatter plot for individual points
scatterHandles = gobjects(1, length(conditions));
for condIdx = 1:length(conditions)
    scatterHandles(condIdx) = scatter(repelem(condIdx, length(subjects)), dataDeviationFix(:, condIdx), 100, colors{condIdx}, 'filled', 'MarkerEdgeColor', 'k');
end

xlabel('Conditions', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Mean Euclidean Deviation [px]', 'FontName', 'Arial', 'FontSize', 20);
set(gca, 'XTick', 1:length(conditions), 'XTickLabel', conditions, 'FontSize', 15);
set(gca, 'LineWidth', 1.5);
set(gca, 'XLim', [0.5 length(conditions) + 0.5]);
set(gca, 'YLim', [min(dataDeviationFix(:)) * 0.85 max(dataDeviationFix(:)) * 1.15]);
legend(scatterHandles, conditions, 'FontName', 'Arial', 'FontSize', 15, 'Location', 'best');
title('Gaze Deviation FixCross', 'FontName', 'Arial', 'FontSize', 25);
hold off;

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/gaze/deviation/boxplot/FCD_gaze_dev_sternberg_boxplot_euclidean.png');

%% BARPLOT individual participants percentage changes from NoFix to FIX 
close all
for subs = 1:length(subjects)
    gazeChange2(subs) = (dataDeviationFix(subs, 1) - dataDeviation(subs, 1)) / dataDeviationFix(subs, 1) * 100;
    gazeChange4(subs) = (dataDeviationFix(subs, 2) - dataDeviation(subs, 2)) / dataDeviationFix(subs, 2) * 100;
    gazeChange6(subs) = (dataDeviationFix(subs, 3) - dataDeviation(subs, 3)) / dataDeviationFix(subs, 3) * 100;
end

% Bar Plot for Relative Differences
figure;
set(gcf, 'Position', [200, 200, 1400, 600], 'Color', 'w'); 
data = [gazeChange2', gazeChange4', gazeChange6'];
colors = {'b', 'k', 'r'};
hbar = bar(data);
for k = 1:length(hbar)
    hbar(k).FaceColor = colors{k};
end
set(gca, 'YLim', [min(data(:)) * 1.15 max(data(:)) * 1.25]);
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Change in Gaze Deviation [%]', 'FontName', 'Arial', 'FontSize', 20);
title('Relative Change in Gaze Deviation from BLANK to FIXCROSS', 'FontName', 'Arial', 'FontSize', 25);
legend(conditions, 'FontName', 'Arial', 'FontSize', 15, 'Location', 'best');

medians = [median(gazeChange2), median(gazeChange4), median(gazeChange6)];
means = [mean(gazeChange2), mean(gazeChange4), mean(gazeChange6)];
for i = 1:3
    text(i+3, -85, sprintf('Median: %.1f%%', medians(i)), 'FontSize', 15, 'FontName', 'Arial', 'Color', colors{i});
    text(i+3, -90, sprintf('Mean: %.1f%%', means(i)), 'FontSize', 15, 'FontName', 'Arial', 'Color', colors{i});
end

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/gaze/deviation/barplot/FCD_gaze_dev_change_percentage.png');

%% BARPLOT individual participants percentage changes from NoFix to FIX INDIVLOADS
close all
% Bar Plot for Relative Differences LOAD2
figure;
set(gcf, 'Position', [200, 200, 800, 600], 'Color', 'w'); 
data = gazeChange2';
hbar = bar(data);
hbar.FaceColor = 'k';
set(gca, 'YLim', [min(data(:)) * 1.15 max(data(:)) * 1.25]);
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Change in Gaze [%]', 'FontName', 'Arial', 'FontSize', 20);
title('Relative Change in Gaze (FIXCROSS-BLANK) in WM load 2', 'FontName', 'Arial', 'FontSize', 20);

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/gaze/deviation/barplot/FCD_gaze_dev_relative_change_percentage_L2.png');

% Bar Plot for Relative Differences LOAD4
figure;
set(gcf, 'Position', [200, 200, 800, 600], 'Color', 'w'); 
data = gazeChange4';
hbar = bar(data);
hbar.FaceColor = 'k';
set(gca, 'YLim', [min(data(:)) * 1.15 max(data(:)) * 1.25]);
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Change in Gaze [%]', 'FontName', 'Arial', 'FontSize', 20);
title('Relative Change in Gaze (FIXCROSS-BLANK) in WM load 4', 'FontName', 'Arial', 'FontSize', 20);

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/gaze/deviation/barplot/FCD_gaze_dev_relative_change_percentage_L4.png');

% Bar Plot for Relative Differences LOAD6
figure;
set(gcf, 'Position', [200, 200, 800, 600], 'Color', 'w'); 
data = gazeChange6';
hbar = bar(data);
hbar.FaceColor = 'k';
set(gca, 'YLim', [min(data(:)) * 1.15 max(data(:)) * 1.25]);
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Change in Gaze [%]', 'FontName', 'Arial', 'FontSize', 20);
title('Relative Change in Gaze (FIXCROSS-BLANK) in WM load 6', 'FontName', 'Arial', 'FontSize', 20);

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/gaze/deviation/barplot/FCD_gaze_dev_relative_change_percentage_L6.png');
