%% FCD Alpha Power Sternberg

%% Setup
clear
addpath('/Users/Arne/Documents/matlabtools/eeglab2024.1');
eeglab
clc
close all
addpath('/Volumes/methlab/Students/Arne/toolboxes')
path = '/Volumes/methlab/Students/Arne/FCD/data/features/';
dirs = dir(path);
folders = dirs([dirs.isdir] & ~ismember({dirs.name}, {'.', '..'}));
subjects = {folders.name};

%% Define channels
subj = 1;
datapath = strcat(path, subjects{subj}, '/eeg');
cd(datapath);
load('power_stern_fix.mat');
% Occipital channels
occ_channels = {};
for i = 1:length(powload2fix.label)
    label = powload2fix.label{i};
    if contains(label, {'O'})
        occ_channels{end+1} = label;
    end
end
channels = occ_channels;

%% Load data and calculate alpha power and IAF
alphaRange = [8 14];
powerIAF2fix = [];
powerIAF4fix = [];
powerIAF6fix = [];
powerIAF2 = [];
powerIAF4 = [];
powerIAF6 = [];
IAF_results = struct();

for subj = 1:length(subjects)
    datapath = strcat(path, subjects{subj}, '/eeg');
    cd(datapath);
    
    % Load fixation data
    load('power_stern_fix.mat');
    
    % Channel selection
    channelIdx = find(ismember(powload2fix.label, channels));
    
    % Extract power spectra for selected channels
    powspctrm2fix = mean(powload2fix.powspctrm(channelIdx, :), 1);
    powspctrm4fix = mean(powload4fix.powspctrm(channelIdx, :), 1);
    powspctrm6fix = mean(powload6fix.powspctrm(channelIdx, :), 1);

    % Find the indices corresponding to the alpha range
    alphaIndices = find(powload2fix.freq >= alphaRange(1) & powload2fix.freq <= alphaRange(2));
    
    % Calculate IAF for WM load 2
    alphaPower2fix = powspctrm2fix(alphaIndices);
    [~, maxIndex2fix] = max(alphaPower2fix);
    IAF2fix = powload2fix.freq(alphaIndices(maxIndex2fix));

    % Calculate IAF for WM load 4
    alphaPower4fix = powspctrm4fix(alphaIndices);
    [~, maxIndex4fix] = max(alphaPower4fix);
    IAF4fix = powload4fix.freq(alphaIndices(maxIndex4fix));

    % Calculate IAF for WM load 6
    alphaPower6fix = powspctrm6fix(alphaIndices);
    [~, maxIndex6fix] = max(alphaPower6fix);
    IAF6fix = powload6fix.freq(alphaIndices(maxIndex6fix));

    % Store the power values at the calculated IAFs
    powerIAF2fix = [powerIAF2fix, alphaPower2fix(maxIndex2fix)];
    powerIAF4fix = [powerIAF4fix, alphaPower4fix(maxIndex4fix)];
    powerIAF6fix = [powerIAF6fix, alphaPower6fix(maxIndex6fix)];
    pow2fix = alphaPower2fix(maxIndex2fix);
    pow4fix = alphaPower4fix(maxIndex4fix);
    pow6fix = alphaPower6fix(maxIndex6fix);

    % Load no-fixation data
    load('power_stern.mat');
    
    % Channel selection
    channelIdx = find(ismember(powload2.label, channels));
    
    % Extract power spectra for selected channels
    powspctrm2 = mean(powload2.powspctrm(channelIdx, :), 1);
    powspctrm4 = mean(powload4.powspctrm(channelIdx, :), 1);
    powspctrm6 = mean(powload6.powspctrm(channelIdx, :), 1);

    % Find the indices corresponding to the alpha range
    alphaIndices = find(powload2.freq >= alphaRange(1) & powload2.freq <= alphaRange(2));
    
    % Calculate IAF for WM load 2
    alphaPower2 = powspctrm2(alphaIndices);
    [~, maxIndex2] = max(alphaPower2);
    IAF2 = powload2.freq(alphaIndices(maxIndex2));

    % Calculate IAF for WM load 4
    alphaPower4 = powspctrm4(alphaIndices);
    [~, maxIndex4] = max(alphaPower4);
    IAF4 = powload4.freq(alphaIndices(maxIndex4));

    % Calculate IAF for WM load 6
    alphaPower6 = powspctrm6(alphaIndices);
    [~, maxIndex6] = max(alphaPower6);
    IAF6 = powload6.freq(alphaIndices(maxIndex6));

    % Store the power values at the calculated IAFs
    powerIAF2 = [powerIAF2, alphaPower2(maxIndex2)];
    powerIAF4 = [powerIAF4, alphaPower4(maxIndex4)];
    powerIAF6 = [powerIAF6, alphaPower6(maxIndex6)];
    pow2 = alphaPower2(maxIndex2);
    pow4 = alphaPower4(maxIndex4);
    pow6 = alphaPower6(maxIndex6);

    % % Store and print the results
    save alphaPower_IAF_sternberg IAF2 IAF4 IAF6 pow2 pow4 pow6 
    save alphaPower_IAF_sternberg_fix IAF2fix IAF4fix IAF6fix pow2fix pow4fix pow6fix 
    fprintf('Subject %s IAF (Incl. FixCross): load2: %f Hz (Power: %f), load4: %f Hz (Power: %f), load6: %f Hz (Power: %f) \n', subjects{subj}, IAF2fix, alphaPower2fix(maxIndex2fix), IAF4fix, alphaPower4fix(maxIndex4fix), IAF6fix, alphaPower6fix(maxIndex6fix));
    fprintf('Subject %s IAF (Excl. FixCross): load2: %f Hz (Power: %f), load4: %f Hz (Power: %f), load6: %f Hz (Power: %f) \n', subjects{subj}, IAF2, alphaPower2(maxIndex2), IAF4, alphaPower4(maxIndex4), IAF6, alphaPower6(maxIndex6));
end

%% Plot alpha power BOXPLOT
close all
figure;
set(gcf, 'Position', [0, 0, 1200, 900], 'Color', 'w');
colors = {'b', 'k', 'r'};
conditions = {'WM load 2', 'WM load 4', 'WM load 6'};
numSubjects = length(subjects);

% Collect data into a matrix for plotting
dataAlphaPowerFix = [powerIAF2fix; powerIAF4fix; powerIAF6fix]';
dataAlphaPower = [powerIAF2; powerIAF4; powerIAF6]';
median(dataAlphaPowerFix)
median(dataAlphaPower)

% Plot for alpha power
subplot(1, 2, 1);
hold on;
title('No Fixation')
% Boxplots
boxplot(dataAlphaPower, 'Colors', 'k', 'Symbol', '', 'Widths', 0.5);
for subj = 1:numSubjects
    plot(1:length(conditions), dataAlphaPower(subj, :), '-o', 'Color', [0.5, 0.5, 0.5], 'MarkerFaceColor', 'w');
end
% Scatter plot for individual points
scatterHandles = gobjects(1, length(conditions));
for condIdx = 1:length(conditions)
    scatterHandles(condIdx) = scatter(repelem(condIdx, numSubjects), dataAlphaPower(:, condIdx), 100, colors{condIdx}, 'filled', 'MarkerEdgeColor', 'k');
end
xlabel('Condition', 'FontName', 'Arial', 'FontSize', 25);
ylabel('Alpha Power at IAF [\muV^2/Hz]', 'FontName', 'Arial', 'FontSize', 25);
set(gca, 'XTick', 1:length(conditions), 'XTickLabel', conditions, 'FontSize', 20);
set(gca, 'LineWidth', 1.5);
legend(scatterHandles, conditions, 'FontName', 'Arial', 'FontSize', 20, 'Location', 'best');
set(gca, 'XLim', [0.5 3.5]);
hold off;

subplot(1, 2, 2);
hold on;
title('Fixation')
% Boxplots
boxplot(dataAlphaPowerFix, 'Colors', 'k', 'Symbol', '', 'Widths', 0.5);
for subj = 1:numSubjects
    plot(1:length(conditions), dataAlphaPowerFix(subj, :), '-o', 'Color', [0.5, 0.5, 0.5], 'MarkerFaceColor', 'w');
end
% Scatter plot for individual points
scatterHandles = gobjects(1, length(conditions));
for condIdx = 1:length(conditions)
    scatterHandles(condIdx) = scatter(repelem(condIdx, numSubjects), dataAlphaPowerFix(:, condIdx), 100, colors{condIdx}, 'filled', 'MarkerEdgeColor', 'k');
end
xlabel('Condition', 'FontName', 'Arial', 'FontSize', 25);
ylabel('Alpha Power at IAF [\muV^2/Hz]', 'FontName', 'Arial', 'FontSize', 25);
set(gca, 'XTick', 1:length(conditions), 'XTickLabel', conditions, 'FontSize', 20);
set(gca, 'LineWidth', 1.5);
legend(scatterHandles, conditions, 'FontName', 'Arial', 'FontSize', 20, 'Location', 'best');
title('Sternberg Alpha Power at IAF', 'FontName', 'Arial', 'FontSize', 30);
set(gca, 'XLim', [0.5 3.5]);
hold off;

% Save
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/alpha_power/boxplot/FCD_alpha_power_sternberg_boxplot.png');

%% Plot alpha power realtive change BARPLOT
% Define relative change calculation function
relative_change = @(x, y) (y - x) ./ x * 100;

% Calculate relative changes
relChangeNoFix_2to6 = relative_change(powerIAF2, powerIAF6);
relChangeFix_2to6 = relative_change(powerIAF2fix, powerIAF6fix);
relChangeNoFix_2to4 = relative_change(powerIAF2, powerIAF4);
relChangeFix_2to4 = relative_change(powerIAF2fix, powerIAF4fix);

% Prepare data for plotting
data_2to6 = [relChangeNoFix_2to6; relChangeFix_2to6]';
data_2to4 = [relChangeNoFix_2to4; relChangeFix_2to4]';
group = [ones(1, numSubjects), 2 * ones(1, numSubjects)]';
values_2to6 = data_2to6(:);
values_2to4 = data_2to4(:);

% Determine the y-axis limits based on both datasets
allData = [relChangeNoFix_2to6, relChangeFix_2to6, relChangeNoFix_2to4, relChangeFix_2to4];
yMin = min(allData)*1.05;
yMax = max(allData)*1.05;
yTicks = sort([0:-10:floor(yMin/10)*10, 10:10:ceil(yMax/10)*10]);

% Plot
close all
figure;
set(gcf, 'Position', [0, 0, 1800, 900], 'Color', 'w');

% Subplot for 2 to 4
subplot(1, 2, 1);
hold on;
b = bar(1:2, mean(data_2to4), 'FaceAlpha', 0.6, 'FaceColor', 'k');

xOffset = 0.15;
xNoFix = ones(1, numSubjects) + (rand(1, numSubjects) - 0.5) * xOffset;
xFix = 2 * ones(1, numSubjects) + (rand(1, numSubjects) - 0.5) * xOffset;
scatter(xNoFix, relChangeNoFix_2to4, 100, 'k', 'filled', 'MarkerEdgeColor', 'k');
scatter(xFix, relChangeFix_2to4, 100, 'k', 'filled', 'MarkerEdgeColor', 'k');

for subj = 1:numSubjects
    plot([xNoFix(subj), xFix(subj)], [relChangeNoFix_2to4(subj), relChangeFix_2to4(subj)], 'k-', 'LineWidth', 0.5);
end

yline(0, 'k--', 'LineWidth', 1.5);

set(gca, 'XTick', 1:2, 'XTickLabel', {'No FixCross', 'FixCross'}, 'FontSize', 20);
xlabel('', 'FontSize', 20);
ylabel('Relative Alpha Power Change [%]', 'FontSize', 20);
title('Change in Alpha Power (WM load 2 to 4)', 'FontSize', 25);
yticks(yTicks);
ylim([min(yTicks), max(yTicks)]);
hold off;

% Subplot for 2 to 6
subplot(1, 2, 2);
hold on;
b = bar(1:2, mean(data_2to6), 'FaceAlpha', 0.6, 'FaceColor', 'k');

xNoFix = ones(1, numSubjects) + (rand(1, numSubjects) - 0.5) * xOffset;
xFix = 2 * ones(1, numSubjects) + (rand(1, numSubjects) - 0.5) * xOffset;
scatter(xNoFix, relChangeNoFix_2to6, 100, 'k', 'filled', 'MarkerEdgeColor', 'k');
scatter(xFix, relChangeFix_2to6, 100, 'k', 'filled', 'MarkerEdgeColor', 'k');

for subj = 1:numSubjects
    plot([xNoFix(subj), xFix(subj)], [relChangeNoFix_2to6(subj), relChangeFix_2to6(subj)], 'k-', 'LineWidth', 0.5);
end

yline(0, 'k--', 'LineWidth', 1.5);

set(gca, 'XTick', 1:2, 'XTickLabel', {'No FixCross', 'FixCross'}, 'FontSize', 20);
xlabel('', 'FontSize', 20);
ylabel('Relative Alpha Power Change [%]', 'FontSize', 20);
title('Change in Alpha Power (WM load 2 to 6)', 'FontSize', 25);
yticks(yTicks);
ylim([min(yTicks), max(yTicks)]);
hold off;

% Save plot
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/alpha_power/barplot/FCD_alpha_power_relative_change_overall.png');

%% BARPLOT individual participants alpha values from NoFix to FIX INDIVLOADS 
close all
% Extract data for each condition and both NoFix and FixCross
noFix2 = dataAlphaPower(:, 1);
fixCross2 = dataAlphaPowerFix(:, 1);
noFix4 = dataAlphaPower(:, 2);
fixCross4 = dataAlphaPowerFix(:, 2);
noFix6 = dataAlphaPower(:, 3);
fixCross6 = dataAlphaPowerFix(:, 3);

% Bar Plot for LOAD 2
figure;
set(gcf, 'Position', [200, 200, 800, 600], 'Color', 'w'); 
data = [noFix2, fixCross2];
barWidth = 0.8;
hbar = bar(data, 'grouped', 'BarWidth', barWidth);
set(hbar(1), 'FaceColor', 'b'); % Blue for Blank
set(hbar(2), 'FaceColor', 'r'); % Red for Fix Cross
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Alpha Power', 'FontName', 'Arial', 'FontSize', 20);
title('Alpha Power for No Fix and Fix Cross (WM load 2)', 'FontName', 'Arial', 'FontSize', 20);
legend({'Blank', 'Fix Cross'}, 'FontName', 'Arial', 'FontSize', 15, 'Location', 'northeast');
grid on;

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/alpha_power/barplot/FCD_alpha_power_L2.png');

% Bar Plot for LOAD 4
figure;
set(gcf, 'Position', [200, 200, 800, 600], 'Color', 'w'); 
data = [noFix4, fixCross4];
hbar = bar(data, 'grouped', 'BarWidth', barWidth);
set(hbar(1), 'FaceColor', 'b'); % Blue for Blank
set(hbar(2), 'FaceColor', 'r'); % Red for Fix Cross
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Alpha Power', 'FontName', 'Arial', 'FontSize', 20);
title('Alpha Power for No Fix and Fix Cross (WM load 4)', 'FontName', 'Arial', 'FontSize', 20);
legend({'Blank', 'Fix Cross'}, 'FontName', 'Arial', 'FontSize', 15, 'Location', 'northeast');
grid on;

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/alpha_power/barplot/FCD_alpha_power_L4.png');

% Bar Plot for LOAD 6
figure;
set(gcf, 'Position', [200, 200, 800, 600], 'Color', 'w'); 
data = [noFix6, fixCross6];
hbar = bar(data, 'grouped', 'BarWidth', barWidth);
set(hbar(1), 'FaceColor', 'b'); % Blue for Blank
set(hbar(2), 'FaceColor', 'r'); % Red for Fix Cross
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Alpha Power', 'FontName', 'Arial', 'FontSize', 20);
title('Alpha Power for No Fix and Fix Cross (WM load 6)', 'FontName', 'Arial', 'FontSize', 20);
legend({'Blank', 'Fix Cross'}, 'FontName', 'Arial', 'FontSize', 15, 'Location', 'northeast');
grid on;

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/alpha_power/barplot/FCD_alpha_power_L6.png');

%% BARPLOT individual participants percentage changes from NoFix to FIX 
close all
for subs = 1:length(subjects)
    powerChange2(subs) = (dataAlphaPowerFix(subs, 1) - dataAlphaPower(subs, 1)) / dataAlphaPowerFix(subs, 1) * 100;
    powerChange4(subs) = (dataAlphaPowerFix(subs, 2) - dataAlphaPower(subs, 2)) / dataAlphaPowerFix(subs, 2) * 100;
    powerChange6(subs) = (dataAlphaPowerFix(subs, 3) - dataAlphaPower(subs, 3)) / dataAlphaPowerFix(subs, 3) * 100;
end

% Bar Plot for Relative Differences
figure;
set(gcf, 'Position', [200, 200, 1400, 600], 'Color', 'w'); 
data = [powerChange2', powerChange4', powerChange6'];
colors = {'b', 'k', 'r'};
hbar = bar(data);
for k = 1:length(hbar)
    hbar(k).FaceColor = colors{k};
end
set(gca, 'YLim', [min(data(:)) * 1.15 max(data(:)) * 1.25]);
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Change in Alpha Power [%]', 'FontName', 'Arial', 'FontSize', 20);
title('Relative Change in Alpha Power from BLANK to FIXCROSS', 'FontName', 'Arial', 'FontSize', 25);
legend(conditions, 'FontName', 'Arial', 'FontSize', 15, 'Location', 'southeast');

medians = [median(powerChange2), median(powerChange4), median(powerChange6)];
means = [mean(powerChange2), mean(powerChange4), mean(powerChange6)];
for i = 1:3
    text(i+3, -100, sprintf('Median: %.1f%%', medians(i)), 'FontSize', 15, 'FontName', 'Arial', 'Color', colors{i});
    text(i+3, -105, sprintf('Mean: %.1f%%', means(i)), 'FontSize', 15, 'FontName', 'Arial', 'Color', colors{i});
end

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/alpha_power/barplot/FCD_alpha_power_relative_change.png');

%% BARPLOT individual participants percentage changes from NoFix to FIX INDIVLOADS
close all
% Bar Plot for Relative Differences LOAD2
figure;
set(gcf, 'Position', [200, 200, 800, 600], 'Color', 'w'); 
data = powerChange2';
hbar = bar(data);
hbar.FaceColor = 'k';
set(gca, 'YLim', [min(data(:)) * 1.15 max(data(:)) * 1.25]);
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Change in Alpha Power [%]', 'FontName', 'Arial', 'FontSize', 20);
title('Relative Change in Alpha Power (FIXCROSS-BLANK) in WM load 2', 'FontName', 'Arial', 'FontSize', 20);

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/alpha_power/barplot/FCD_alpha_power_relative_change_L2.png');

% Bar Plot for Relative Differences LOAD4
figure;
set(gcf, 'Position', [200, 200, 800, 600], 'Color', 'w'); 
data = powerChange4';
hbar = bar(data);
hbar.FaceColor = 'k';
set(gca, 'YLim', [min(data(:)) * 1.15 max(data(:)) * 1.25]);
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Change in Alpha Power [%]', 'FontName', 'Arial', 'FontSize', 20);
title('Relative Change in Alpha Power (FIXCROSS-BLANK) in WM load 4', 'FontName', 'Arial', 'FontSize', 20);

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/alpha_power/barplot/FCD_alpha_power_relative_change_L4.png');

% Bar Plot for Relative Differences LOAD6
figure;
set(gcf, 'Position', [200, 200, 800, 600], 'Color', 'w'); 
data = powerChange6';
hbar = bar(data);
hbar.FaceColor = 'k';
set(gca, 'YLim', [min(data(:)) * 1.15 max(data(:)) * 1.25]);
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Change in Alpha Power [%]', 'FontName', 'Arial', 'FontSize', 20);
title('Relative Change in Alpha Power (FIXCROSS-BLANK) in WM load 6', 'FontName', 'Arial', 'FontSize', 20);

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/alpha_power/barplot/FCD_alpha_power_relative_change_L6.png');

%% BARPLOT individual participants absolute changes from NoFix to FIX INDIVLOADS
close all
for subs = 1:length(subjects)
    powChangeAbs2(subs) = (dataAlphaPowerFix(subs, 1) - dataAlphaPower(subs, 1));
    powChangeAbs4(subs) = (dataAlphaPowerFix(subs, 2) - dataAlphaPower(subs, 2));
    powChangeAbs6(subs) = (dataAlphaPowerFix(subs, 3) - dataAlphaPower(subs, 3));
end

% Bar Plot for Relative Differences LOAD2
figure;
set(gcf, 'Position', [200, 200, 800, 600], 'Color', 'w'); 
data = powChangeAbs2';
hbar = bar(data);
hbar.FaceColor = 'k';
set(gca, 'YLim', [min(data(:)) * 1.15 max(data(:)) * 1.25]);
ylim([-1 1])
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Change in Alpha Power', 'FontName', 'Arial', 'FontSize', 20);
title('Change in Alpha Power (FIXCROSS-BLANK) in WM load 2', 'FontName', 'Arial', 'FontSize', 20);

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/alpha_power/barplot/FCD_alpha_power_abs_change_L2.png');

% Bar Plot for Relative Differences LOAD4
figure;
set(gcf, 'Position', [200, 200, 800, 600], 'Color', 'w'); 
data = powChangeAbs4';
hbar = bar(data);
hbar.FaceColor = 'k';
set(gca, 'YLim', [min(data(:)) * 1.15 max(data(:)) * 1.25]);
ylim([-1 1])
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Change in Alpha Power', 'FontName', 'Arial', 'FontSize', 20);
title('Change in Alpha Power (FIXCROSS-BLANK) in WM load 4', 'FontName', 'Arial', 'FontSize', 20);

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/alpha_power/barplot/FCD_alpha_power_abs_change_L4.png');

% Bar Plot for Relative Differences LOAD6
figure;
set(gcf, 'Position', [200, 200, 800, 600], 'Color', 'w'); 
data = powChangeAbs6';
hbar = bar(data);
hbar.FaceColor = 'k';
set(gca, 'YLim', [min(data(:)) * 1.15 max(data(:)) * 1.25]);
% ylim([-1 1])
xlabel('Subject', 'FontName', 'Arial', 'FontSize', 20);
ylabel('Change in Alpha Power', 'FontName', 'Arial', 'FontSize', 20);
title('Change in Alpha Power (FIXCROSS-BLANK) in WM load 6', 'FontName', 'Arial', 'FontSize', 20);

% Save the figure
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/alpha_power/barplot/FCD_alpha_power_abs_change_L6.png');


%% Plot alpha power POWERSPECTRUM - INDIVIDUAL
close all
colors = {'b', 'k', 'r'};
conditions = {'WM load 2', 'WM load 4', 'WM load 6'};
numSubjects = length(subjects);

% Load powerspctrm data and compute individual averages
for subj = 1:numSubjects
    close all
    datapath = strcat(path,subjects{subj}, '/eeg');
    cd(datapath)
    load power_stern_fix
    powl2fix{subj} = powload2fix;
    powl4fix{subj} = powload4fix;
    powl6fix{subj} = powload6fix;
    load power_stern
    powl2{subj} = powload2;
    powl4{subj} = powload4;
    powl6{subj} = powload6;

    % Plotting for each subject
    figure;
    set(gcf, 'Position', [0, 0, 1600, 800], 'Color', 'w');

    % No Fixation plots
    subplot(1, 2, 1);
    hold on;
    plot(powl2{subj}.freq, mean(powl2{subj}.powspctrm, 1), 'b', 'LineWidth', 1);
    l2ebar = shadedErrorBar(powl2{subj}.freq, mean(powl2{subj}.powspctrm, 1), std(powl2{subj}.powspctrm)/sqrt(size(powl2{subj}.powspctrm, 1)), {'b', 'markerfacecolor', 'b'}, 1);
    
    plot(powl4{subj}.freq, mean(powl4{subj}.powspctrm, 1), 'k', 'LineWidth', 1);
    l4ebar = shadedErrorBar(powl4{subj}.freq, mean(powl4{subj}.powspctrm, 1), std(powl4{subj}.powspctrm)/sqrt(size(powl4{subj}.powspctrm, 1)), {'k', 'markerfacecolor', 'k'}, 1);
    
    plot(powl6{subj}.freq, mean(powl6{subj}.powspctrm, 1), 'r', 'LineWidth', 1);
    l6ebar = shadedErrorBar(powl6{subj}.freq, mean(powl6{subj}.powspctrm, 1), std(powl6{subj}.powspctrm)/sqrt(size(powl6{subj}.powspctrm, 1)), {'r', 'markerfacecolor', 'r'}, 1);
    hold off;
    title(['Subject ' num2str(subjects{subj}) ' - Alpha Power Spectrum (No Fixation)'], 'FontSize', 20);
    xlabel('Frequency [Hz]', 'FontSize', 15);
    ylabel('Power [\muV^2/Hz]', 'FontSize', 15);
    legend([l2ebar.mainLine, l4ebar.mainLine, l6ebar.mainLine], {'WM load 2', 'WM load 4', 'WM load 6'}, 'FontName', 'Arial', 'FontSize', 20);

    % Fixation plots
    subplot(1, 2, 2);
    hold on;
    plot(powl2fix{subj}.freq, mean(powl2fix{subj}.powspctrm, 1), 'b', 'LineWidth', 1);
    l2ebar = shadedErrorBar(powl2fix{subj}.freq, mean(powl2fix{subj}.powspctrm, 1), std(powl2fix{subj}.powspctrm)/sqrt(size(powl2fix{subj}.powspctrm, 1)), {'b', 'markerfacecolor', 'b'}, 1);
    
    plot(powl4fix{subj}.freq, mean(powl4fix{subj}.powspctrm, 1), 'k', 'LineWidth', 1);
    l4ebar = shadedErrorBar(powl4fix{subj}.freq, mean(powl4fix{subj}.powspctrm, 1), std(powl4fix{subj}.powspctrm)/sqrt(size(powl4fix{subj}.powspctrm, 1)), {'k', 'markerfacecolor', 'k'}, 1);
    
    plot(powl6fix{subj}.freq, mean(powl6fix{subj}.powspctrm, 1), 'r', 'LineWidth', 1);
    l6ebar = shadedErrorBar(powl6fix{subj}.freq, mean(powl6fix{subj}.powspctrm, 1), std(powl6fix{subj}.powspctrm)/sqrt(size(powl6fix{subj}.powspctrm, 1)), {'r', 'markerfacecolor', 'r'}, 1);
    hold off;
    title(['Subject ' num2str(subjects{subj}) ' - Alpha Power Spectrum (Fixation)'], 'FontSize', 20);
    xlabel('Frequency [Hz]', 'FontSize', 15);
    ylabel('Power [\muV^2/Hz]', 'FontSize', 15);
    legend([l2ebar.mainLine, l4ebar.mainLine, l6ebar.mainLine], {'WM load 2', 'WM load 4', 'WM load 6'}, 'FontName', 'Arial', 'FontSize', 20);

    % Save
    savepath_indiv = strcat('/Volumes/methlab/Students/Arne/FCD/figures/eeg/alpha_power/powspctrm/', num2str(subjects{subj}));
    mkdir(savepath_indiv)
    saveas(gcf, strcat(savepath_indiv, '/', num2str(subjects{subj}), '_FCD_alpha_power_sternberg_powspctrm_indiv.png'))
end

%% Plot alpha power POWERSPECTRUM - GRAND AVERAGE
close all
figure;
set(gcf, 'Position', [0, 0, 1600, 800], 'Color', 'w');
colors = {'b', 'k', 'r'};
conditions = {'WM load 2', 'WM load 4', 'WM load 6'};
numSubjects = length(subjects);

% Load powerspctrm data
for subj = 1:length(subjects)
    datapath = strcat(path,subjects{subj}, '/eeg');
    cd(datapath)
    load power_stern_fix
    powl2fix{subj} = powload2fix;
    powl4fix{subj} = powload4fix;
    powl6fix{subj} = powload6fix;
    load power_stern
    powl2{subj} = powload2;
    powl4{subj} = powload4;
    powl6{subj} = powload6;
end

% Compute grand avg
load('/Volumes/methlab/Students/Arne/toolboxes/headmodel/layANThead.mat');
gapow2fix = ft_freqgrandaverage([],powl2fix{:});
gapow4fix = ft_freqgrandaverage([],powl4fix{:});
gapow6fix = ft_freqgrandaverage([],powl6fix{:});
gapow2 = ft_freqgrandaverage([],powl2{:});
gapow4 = ft_freqgrandaverage([],powl4{:});
gapow6 = ft_freqgrandaverage([],powl6{:});

% Plot No Fixation
subplot(1, 2, 1);
cfg = [];
cfg.channel = channels;
cfg.figure = 'gcf';
cfg.linecolor = 'bkr';
cfg.linewidth = 1;
ft_singleplotER(cfg,gapow2,gapow4,gapow6);
hold on;

% Add shadedErrorBar
addpath('/Volumes/methlab/Students/Arne/toolboxes/')
channels_seb = ismember(gapow2.label, cfg.channel);
l2ebar = shadedErrorBar(gapow2.freq, mean(gapow2.powspctrm(channels_seb, :), 1), std(gapow2.powspctrm(channels_seb, :))/sqrt(size(gapow2.powspctrm(channels_seb, :), 1)), {'b', 'markerfacecolor', 'b'});
l4ebar = shadedErrorBar(gapow4.freq, mean(gapow4.powspctrm(channels_seb, :), 1), std(gapow4.powspctrm(channels_seb, :))/sqrt(size(gapow4.powspctrm(channels_seb, :), 1)), {'k', 'markerfacecolor', 'k'});
l6ebar = shadedErrorBar(gapow6.freq, mean(gapow6.powspctrm(channels_seb, :), 1), std(gapow6.powspctrm(channels_seb, :))/sqrt(size(gapow6.powspctrm(channels_seb, :), 1)), {'r', 'markerfacecolor', 'r'});
transparency = 0.25;
set(l2ebar.patch, 'FaceAlpha', transparency);
set(l4ebar.patch, 'FaceAlpha', transparency);
set(l6ebar.patch, 'FaceAlpha', transparency);

% Adjust plotting
set(gcf,'color','w');
set(gca,'Fontsize',20);
[~, channel_idx] = ismember(channels, gapow2.label);
channel_idx = channel_idx(channel_idx>0);
freq_idx = find(gapow2.freq >= 8 & gapow2.freq <= 14);
max_spctrm = max([mean(gapow2.powspctrm(channel_idx, freq_idx), 2); mean(gapow4.powspctrm(channel_idx, freq_idx), 2); mean(gapow6.powspctrm(channel_idx, freq_idx), 2)]);
ylim([0 max_spctrm*1.4])
box on
xlabel('Frequency [Hz]');
ylabel('Power [\muV^2/Hz]');
legend([l2ebar.mainLine, l4ebar.mainLine, l6ebar.mainLine], {'WM load 2', 'WM load 4', 'WM load 6'}, 'FontName', 'Arial', 'FontSize', 20);
title('Sternberg Power Spectrum (No Fixation)', 'FontSize', 30);
hold off;

% Plot Fixation
subplot(1, 2, 2);
cfg = [];
cfg.channel = channels;
cfg.figure = 'gcf';
cfg.linecolor = 'bkr';
cfg.linewidth = 1;
ft_singleplotER(cfg,gapow2fix,gapow4fix,gapow6fix);
hold on;

% Add shadedErrorBar
addpath('/Volumes/methlab/Students/Arne/toolboxes/')
channels_seb = ismember(gapow2fix.label, cfg.channel);
l2ebar = shadedErrorBar(gapow2fix.freq, mean(gapow2fix.powspctrm(channels_seb, :), 1), std(gapow2fix.powspctrm(channels_seb, :))/sqrt(size(gapow2fix.powspctrm(channels_seb, :), 1)), {'b', 'markerfacecolor', 'b'});
l4ebar = shadedErrorBar(gapow4fix.freq, mean(gapow4fix.powspctrm(channels_seb, :), 1), std(gapow4fix.powspctrm(channels_seb, :))/sqrt(size(gapow4fix.powspctrm(channels_seb, :), 1)), {'k', 'markerfacecolor', 'k'});
l6ebar = shadedErrorBar(gapow6fix.freq, mean(gapow6fix.powspctrm(channels_seb, :), 1), std(gapow6fix.powspctrm(channels_seb, :))/sqrt(size(gapow6fix.powspctrm(channels_seb, :), 1)), {'r', 'markerfacecolor', 'r'});
transparency = 0.25;
set(l2ebar.patch, 'FaceAlpha', transparency);
set(l4ebar.patch, 'FaceAlpha', transparency);
set(l6ebar.patch, 'FaceAlpha', transparency);

% Adjust plotting
set(gcf,'color','w');
set(gca,'Fontsize',20);
[~, channel_idx] = ismember(channels, gapow2fix.label);
channel_idx = channel_idx(channel_idx>0);
freq_idx = find(gapow2fix.freq >= 8 & gapow2fix.freq <= 14);
max_spctrm = max([mean(gapow2fix.powspctrm(channel_idx, freq_idx), 2); mean(gapow4fix.powspctrm(channel_idx, freq_idx), 2); mean(gapow6fix.powspctrm(channel_idx, freq_idx), 2)]);
ylim([0 max_spctrm*1.3])
box on
xlabel('Frequency [Hz]');
ylabel('Power [\muV^2/Hz]');
legend([l2ebar.mainLine, l4ebar.mainLine, l6ebar.mainLine], {'WM load 2', 'WM load 4', 'WM load 6'}, 'FontName', 'Arial', 'FontSize', 20);
title('Sternberg Power Spectrum (Fixation)', 'FontSize', 30);
hold off;

% Save
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/alpha_power/powspctrm/FCD_alpha_power_sternberg_powspctrm.png');

%% Plot alpha power TOPOS
close all;
clc;
cfg = [];
load('/Volumes/methlab/Students/Arne/toolboxes/headmodel/layANThead.mat');
cfg.layout = layANThead;
allchannels = cfg.layout.label;
cfg.layout = layANThead;
cfg.channel = allchannels(1:end-2);
cfg.channel = cfg.channel(~strcmp(cfg.channel, 'M2'));
cfg.channel = cfg.channel(~strcmp(cfg.channel, 'M1'));
cfg.marker = 'off';
cfg.highlight = 'on';
cfg.highlightchannel = channels;
cfg.highlightsymbol = '.';
cfg.highlightsize = 10;
cfg.figure = 'gcf';
cfg.marker = 'off';
addpath('/Users/Arne/Documents/matlabtools/customcolormap/')
cmap = customcolormap([0 0.5 1], [0.8 0 0; 1 0.5 0; 1 1 1]);
cfg.colormap = cmap;
cfg.gridscale = 300;
cfg.comment = 'no';
cfg.xlim = [8 14];
[~, channel_idx] = ismember(channels, gapow2.label);
freq_idx = find(gapow2.freq >= 8 & gapow2.freq <= 14);
max_spctrm = max([mean(gapow2.powspctrm(channel_idx, freq_idx), 2); mean(gapow4.powspctrm(channel_idx, freq_idx), 2); mean(gapow6.powspctrm(channel_idx, freq_idx), 2)]);
cfg.zlim = [0 max_spctrm];

% Plot WM load 2 No Fixation
subplot(2, 3, 1);
ft_topoplotER(cfg, gapow2); 
title('WM load 2 (No Fixation)', 'FontSize', 20);
cb = colorbar; 
set(cb, 'FontSize', 20);
ylabel(cb, 'log(Power [\muV^2/Hz])', 'FontSize', 25);

% Plot WM load 2 Fixation
subplot(2, 3, 4);
ft_topoplotER(cfg, gapow2fix); 
title('WM load 2 (Fixation)', 'FontSize', 20);
cb = colorbar; 
set(cb, 'FontSize', 20);
ylabel(cb, 'log(Power [\muV^2/Hz])', 'FontSize', 25);

% Plot WM load 4 No Fixation
subplot(2, 3, 2);
ft_topoplotER(cfg, gapow4); 
title('WM load 4 (No Fixation)', 'FontSize', 20);
cb = colorbar; 
set(cb, 'FontSize', 20);
ylabel(cb, 'log(Power [\muV^2/Hz])', 'FontSize', 25);

% Plot WM load 4 Fixation
subplot(2, 3, 5);
ft_topoplotER(cfg, gapow4fix); 
title('WM load 4 (Fixation)', 'FontSize', 20);
cb = colorbar; 
set(cb, 'FontSize', 20);
ylabel(cb, 'log(Power [\muV^2/Hz])', 'FontSize', 25);

% Plot WM load 6 No Fixation
subplot(2, 3, 3);
ft_topoplotER(cfg, gapow6); 
title('WM load 6 (No Fixation)', 'FontSize', 20);
cb = colorbar; 
set(cb, 'FontSize', 20);
ylabel(cb, 'log(Power [\muV^2/Hz])', 'FontSize', 25);

% Plot WM load 6 Fixation
subplot(2, 3, 6);
ft_topoplotER(cfg, gapow6fix); 
title('WM load 6 (Fixation)', 'FontSize', 20);
cb = colorbar; 
set(cb, 'FontSize', 20);
ylabel(cb, 'log(Power [\muV^2/Hz])', 'FontSize', 25);

% Save
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/alpha_power/topos/FCD_alpha_power_sternberg_topo.png');

%% Plot alpha power TOPOS DIFFERENCE
close all
clc

% Calculate the difference between the conditions (WM load 6 - WM load 2)
ga_diff = gapow6;
ga_diff.powspctrm = gapow6.powspctrm - gapow2.powspctrm;
ga_diff_fix = gapow6fix;
ga_diff_fix.powspctrm = gapow6fix.powspctrm - gapow2fix.powspctrm;

% Plot
figure('Color', 'w');
set(gcf, 'Position', [0, 0, 1600, 800]);

subplot(1, 2, 1);
cfg = [];
load('/Volumes/methlab/Students/Arne/toolboxes/headmodel/layANThead.mat');
cfg.layout = layANThead;
allchannels = cfg.layout.label;
cfg.layout = layANThead;
cfg.channel = allchannels(1:end-2);
cfg.channel = cfg.channel(~strcmp(cfg.channel, 'M2'));
cfg.channel = cfg.channel(~strcmp(cfg.channel, 'M1'));
cfg.marker = 'off';
cfg.highlight = 'on';
cfg.highlightchannel = channels;
cfg.highlightsymbol = '.';
cfg.highlightsize = 10;
cfg.figure = 'gcf';
cfg.marker = 'off';
addpath('/Volumes/methlab/Students/Arne/toolboxes/colormaps');
% cmap = cbrewer('div', 'RdBu', 100);
% cmap = max(min(cmap, 1), 0);
% cmap = flipud(cmap);
% cfg.colormap = cmap;
cb = colorbar;
cfg.gridscale = 300;
cfg.comment = 'no';
cfg.xlim = [8 14];
cfg.zlim = 'maxabs';
set(cb, 'FontSize', 20); 
ylabel(cb, 'Power [\muV^2/Hz]', 'FontSize', 25); 
title('Sternberg Task Alpha Power Difference (WM load 6 - WM load 2, No Fixation)', 'FontSize', 25);
ft_topoplotER(cfg, ga_diff);

subplot(1, 2, 2);
title('Sternberg Task Alpha Power Difference (WM load 6 - WM load 2, Fixation)', 'FontSize', 25);
ft_topoplotER(cfg, ga_diff_fix);

% Save
saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/eeg/alpha_power/topos/FCD_alpha_power_sternberg_topo_diff.png');