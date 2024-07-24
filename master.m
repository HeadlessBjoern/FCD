%% Master script for the FCD study

% - Resting EEG
% - Sternberg training (10 trials)
% - Sternberg actual task (6 blocks x 50 trials)

%% General settings, screens and paths

% Set up MATLAB workspace
clear all;
close all;
clc;
rootFilepath = pwd; % Retrieve the present working directory

% Define paths
PPDEV_PATH = '/home/methlab/Documents/MATLAB/ppdev-mex-master'; % For sending EEG triggers
DATA_PATH = '/home/methlab/Desktop/FCD_data'; % Folder to save data
FUNS_PATH = '/home/methlab/Desktop/FCD' ; % Folder with all functions

mkdir(DATA_PATH) % Make data dir, if doesn't exist yet
addpath(FUNS_PATH) % Add path to folder with functions
screenSettings % Manage screens

%% Collect ID and Age
dialogID;

%% Protect Matlab code from participant keyboard input
ListenChar(2);

%% Resting state EEG
if ~isfile([DATA_PATH, '/', num2str(subjectID), '/', num2str(subjectID), '_Resting.mat'])
    Resting_EEG;
end

%% Execute Sternberg Task
disp(['Subject ' num2str(subjectID) ': RUNNING STERNBERG TASK...']);

% Training phase
TASK = 'FCD_Sternberg';
BLOCK = 0;
TRAINING = 1;
trainingFile = [num2str(subjectID), '_', TASK, '_block0_training.mat'];
if isfile([DATA_PATH, '/', num2str(subjectID), '/', trainingFile])
    percentTotalCorrect = 60;
else
    percentTotalCorrect = 0;
end

while percentTotalCorrect < 59
    disp([TASK, ' Training TASK...']);
    eval(TASK); % Run the task
    BLOCK = BLOCK + 1;
end

% Actual task
TRAINING = 0;
blockCount = 6;
start = 1;
for i = blockCount:-1:1
    if isfile([DATA_PATH, '/', num2str(subjectID), '/', [num2str(subjectID), '_', TASK, '_block', num2str(i), '_task.mat']])
        start = i + 1;
        break;
    end
end

for BLOCK = start:blockCount
    disp([TASK, ' STARTING...']);
    eval(TASK); % Run the task
end

%% Allow keyboard input into Matlab code
ListenChar(0);

%% Display total reward
cash;