%% Cutting of FCD EEG data
% Automatically finds all not converted .cnt files

%% EEGlab
clear
p = pwd;
cd /Volumes/methlab/4marius_bdf/eeglab
eeglab
close()
cd(p)

%% Define path, cut data and convert asc to mat files.
d = dir(strcat('/Volumes/methlab_data/FCD/data/*/', '*cnt'));
ids = {};
for f = 1 : size(d, 1)

    filePath = fullfile(d(f).folder, d(f).name);
    FCD_cutData(filePath)
    
    id = strsplit(d(f).name, '_');
    ids{f} = id{1};

    fprintf('Cutting of data for Subject %.3s done', ids{f})
end

%% Load and synchronize EEG & Eyelink
for id = 1 : length(ids) 
    ID = ids{id};

    filePath = fullfile('/Volumes/methlab_data/FCD/data', ID);
    d = dir([filePath, filesep, '*.asc']);
    
    if not(isempty(d))
        for f = 1 : size(d, 1)
            
            % convert ET asc to mat
            inputFile = fullfile(d(f).folder, d(f).name);
            
            % rename the files (EyeLink can't deal with long filenames, edf filenames has to be short)
            x = strsplit(d(f).name, '_');
            name = x{2};
            id = x{end-1};
            block = str2double(name(1));

            if isnan(block)
                if name(1) == 'R'
                    task = 'Resting';
                    eegfile = [id, '_Resting_EEG.mat'];
                    etfile = [id, '_Resting_ET.mat'];
                else
                    task = 'Training';
                    eegfile = '';
                end
            else
                task = 'FCD_Sternberg';
                etfile = [id, '_' task, '_block', num2str(block), '_task_ET.mat'];
            end

            outputFile = [d(f).folder filesep etfile];
            ET = parseeyelink(inputFile, outputFile);
        end
    end

    % Move asc files to archive
    d = dir([filePath, filesep, '*.asc']);
    for f = 1 : size(d, 1)
        source = fullfile(d(f).folder, d(f).name);
        destination = fullfile(fullfile(filePath, 'archive'));
        movefile(source,destination)
    end

    % Move edf files to archive
    d = dir([filePath, filesep, '*.edf']);
    for f = 1 : size(d, 1)
        source = fullfile(d(f).folder, d(f).name);
        destination = fullfile(fullfile(filePath, 'archive'));
        movefile(source,destination)
    end
end