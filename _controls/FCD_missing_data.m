%% FCD check for missing data

%% Setup
clear
clc
close all
path = '/Volumes/methlab/Students/Arne/FCD/data/merged/';
dirs = dir(path);
folders = dirs([dirs.isdir] & ~ismember({dirs.name}, {'.', '..'}));
subjects = {folders.name};

%% Check missing data
clc
disp('MISSING FILES:')
for subj = 1 : length(subjects)
    for block = 1 : 6
        filePath = ['/Volumes/methlab/Students/Arne/FCD/data/merged/', char(subjects(subj)), filesep, char(subjects(subj)), '_EEG_ET_Sternberg_block', num2str(block), '_merged.mat'];
        fileName = [char(subjects(subj)), '_EEG_ET_Sternberg_block', num2str(block), '_merged.mat'];
if ~isfile(filePath)
            disp(fileName)
        end
    end
end