%% Merge ET and EEG data
% Use data after AUTOMAGIC
% Training ET will be omitted

%% Setup
clear
% addpath('/Users/Arne/Documents/matlabtools/eeglab2024.0');
addpath /Volumes/methlab/4marius_bdf/eeglab % for pop_importeyetracker (EYE-EEG)
eeglab
clc
close all
path = '/Volumes/methlab/Students/Arne/FCD/data/automagic/';
dirs = dir(path);
folders = dirs([dirs.isdir] & ~ismember({dirs.name}, {'.', '..'}));
subjectIDs = {folders.name};

%% Merge data
tic;
for subjects = 1 : length(subjectIDs)
    subjectID = subjectIDs(subjects);
    % Check if subject files have already been merged
    if isempty(dir(['/Volumes/methlab/Students/Arne/FCD/data/merged/', char(subjectID), filesep, char(subjectID), '*_merged.mat']))
        % Load and synchronize EEG & Eyelink
        % convert asci to mat - use the parseeyelink that is changed by Dawid (line 284) should be:
        % test  = regexp(et.messages,'MSG\s+(\d+)\s+(.*)','tokens')'; => MSG not INPUT
        filePathET = ['/Volumes/methlab_data/FCD/data/', char(subjectID)];
        filePathEEG = ['/Volumes/methlab/Students/Arne/FCD/data/automagic/',  char(subjectID)];
        resultFolder = ['/Volumes/methlab/Students/Arne/FCD/data/merged/', char(subjectID)];
        mkdir(resultFolder)
        dEEG = dir([filePathEEG, filesep, '*ip*EEG.mat']);
        dET = dir([filePathET, filesep, '*ET.mat']);

        for files = 1 : 6
            try % Do not process missing blocks
                ETnameShort = dET(files).name(1:end-7);
                ETname = dET(files).name;

                idxEEG = contains({dEEG.name}, ETnameShort);

                EEGname = dEEG(idxEEG).name;

                load(fullfile(dEEG(idxEEG).folder, EEGname));
                ETfile = fullfile(dET(1).folder, ETname);

                fileTaskName = strsplit(EEGname, '_');
                task = sprintf('%s', char(fileTaskName(3)), '_', char(fileTaskName(4)));
                if ~strcmp(task, 'Resting_EEG.mat')
                    block = sprintf('%s', char(fileTaskName(5)));
                    block = block(6:end);
                end

                %% Define start and end triggers
                % Resting
                if strcmp(task, 'Resting_EEG.mat')
                    startTrigger = 10;
                    endTrigger = 90;
                else
                    startTriggers = 31:38;
                    endTriggers = 41:48;
                    startTriggersCell = arrayfun(@num2str, 31:38, 'UniformOutput', 0);

                    startTrigger = startTriggers(ismember(startTriggersCell, {EEG.event.type}));
                    endTrigger = endTriggers(ismember(startTriggersCell, {EEG.event.type}));
                end
                % End trigger
                endTrigger = startTrigger + 10;
                %% Merge files
                EEG = pop_importeyetracker(EEG, ETfile,[startTrigger endTrigger],[2 3 4],{'L_GAZE_X', 'L_GAZE_Y', 'L_AREA'},1,1,1,0);
                %% Save to disk
                % NAME = EEGblock1merged (Sternberg), EEGRestingEOmerged, EEG1backmerged
                if strcmp(task, 'Resting_EEG.mat') == 1
                    fileName = [char(subjectID) '_EEG_ET_RestingEO_merged'];
                elseif strcmp(task, 'FCD_Sternberg') == 1
                    fileName = [char(subjectID) '_EEG_ET_Sternberg_block' num2str(block) '_merged'];
                end
                save(fullfile(resultFolder, fileName), 'EEG', '-v7.3')
                if strcmp(task, 'Resting_EEG.mat') == 1
                    disp(['FCD' char(subjectID) ': Resting done' ])
                else
                    step = sprintf('%s', char(fileTaskName(4)), '_', char(fileTaskName(5)));
                    disp(['FCD' char(subjectID) ': ' step ' done' ])
                end
            end
        end
    end
end
toc
