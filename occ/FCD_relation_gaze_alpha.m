%% Gaze Variability for STERNBERG SIM
clear
clc
close all
path = '/Volumes/methlab/Students/Arne/FCD/data/features/';
dirs = dir(path);
folders = dirs([dirs.isdir] & ~ismember({dirs.name}, {'.', '..'}));
subjects = {folders.name};

%% Load EEG data
for subj = 1:length(subjects)
    datapath = strcat(path, subjects{subj}, '/eeg');
    cd(datapath);
    load('alphaPower_IAF_sternberg.mat');
    l2pow{subj} = pow2;
    l4pow{subj} = pow4;
    l6pow{subj} = pow6;

    load('alphaPower_IAF_sternberg_fix.mat');
    l2powfix{subj} = pow2fix;
    l4powfix{subj} = pow4fix;
    l6powfix{subj} = pow6fix;
end

% Compute alpha power difference from WM load 2 to 6
deltaAlpha = (cell2mat(l6pow) - cell2mat(l2pow)) ./ cell2mat(l2pow) * 100;
deltaAlphafix = (cell2mat(l6powfix) - cell2mat(l2powfix)) ./ cell2mat(l2powfix) * 100;

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

% Compute gaze difference from WM load 2 to 6
deltaGaze = (cell2mat(l6gazedev) - cell2mat(l2gazedev)) ./ cell2mat(l2gazedev) * 100;
deltaGazefix = (cell2mat(l6gazedevfix) - cell2mat(l2gazedevfix)) ./ cell2mat(l2gazedevfix) * 100;

%% Relation with EEG alpha differences (DELTA Alpha vs. DELTA ET)
close all
% Create a scatter plot with axes switched and using percentage changes
figure('Color','w');
set(gcf, "Position", [200, 100, 1800, 600])
title('Association of Change in Alpha Power and Gaze from WM load 2 to 6');
subplot(1, 2, 1);
scatter(deltaGaze, deltaAlpha, 100 ,'filled', 'MarkerFaceColor', 'k');
xlabel('\Delta Gaze Deviation [%]', 'FontSize', 30);
ylabel('\Delta Alpha Power [%]', 'FontSize', 30);

% Find max absolute values for x and y axes
maxAbsX = max(abs(deltaGaze));
maxAbsY = max(abs(deltaAlpha));

% Set x and y axis limits
xlim([-maxAbsX*1.05, maxAbsX*1.05]);
ylim([-maxAbsY*1.05, maxAbsY*1.05]);

% Add a transparent grey box for x>0 and y<0
hold on;
patch([0 maxAbsX*1.05 maxAbsX*1.05 0], [0 0 -maxAbsY*1.05 -maxAbsY*1.05], [0.5 0.5 0.5], 'FaceAlpha', 0.3);
patch([-maxAbsX*1.05 0 0 -maxAbsX*1.05], [maxAbsY*1.05 maxAbsY*1.05 0 0], [0.5 0.5 0.5], 'FaceAlpha', 0.3);
ax = gca;
ax.FontSize = 20; % Set the tick label font size to 20
box on;
hold off;

% Create a scatter plot with axes switched and using percentage changes
% figure('Color','w');
subplot(1, 2, 2);
scatter(deltaGazefix, deltaAlphafix, 100 ,'filled', 'MarkerFaceColor', 'k');
xlabel('\Delta Gaze Deviation [%]', 'FontSize', 30);
ylabel('\Delta Alpha Power [%]', 'FontSize', 30);

% Find max absolute values for x and y axes
maxAbsX = max(abs(deltaGazefix));
maxAbsY = max(abs(deltaAlphafix));

% Set x and y axis limits
xlim([-maxAbsX*1.05, maxAbsX*1.05]);
ylim([-maxAbsY*1.05, maxAbsY*1.05]);

% Add a transparent grey box for x>0 and y<0
hold on;
patch([0 maxAbsX*1.05 maxAbsX*1.05 0], [0 0 -maxAbsY*1.05 -maxAbsY*1.05], [0.5 0.5 0.5], 'FaceAlpha', 0.3);
patch([-maxAbsX*1.05 0 0 -maxAbsX*1.05], [maxAbsY*1.05 maxAbsY*1.05 0 0], [0.5 0.5 0.5], 'FaceAlpha', 0.3);
ax = gca;
ax.FontSize = 20; % Set the tick label font size to 20
box on;
hold off;

saveas(gcf, '/Volumes/methlab/Students/Arne/FCD/figures/occ/FCD_relation_gaze_alpha.png');
