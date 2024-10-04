%% FCD Preprocessing for Sternberg task
% Add EEGLAB temporarily to segment data
% later on it needs to be removed from matlab path to avoid collision with FT

%% Setup
clear
addpath('/Users/Arne/Documents/matlabtools/eeglab2024.1');
eeglab
clc
close all
path = '/Volumes/methlab/Students/Arne/FCD/data/merged/';
dirs = dir(path);
folders = dirs([dirs.isdir] & ~ismember({dirs.name}, {'.', '..'}));
subjects = {folders.name};

%% ONLY PERFORM COMPUTATION ON NEW SUBJECT FILES
onlyNewFiles = 0;
if onlyNewFiles == 1
    newSubs = {};
    for subj = 1:length(subjects)
        if isempty(dir(['/Volumes/methlab/Students/Arne/FCD/data/features/', subjects{subj}, filesep, 'eeg']))
            newSubs{end+1} = subjects{subj};
        end
    end
    subjects = newSubs;
end

tic;
%% Read data, segment and convert to FieldTrip data structure
for subj = 1:length(subjects)
    clearvars -except subjects subj path
    datapath = strcat(path,subjects{subj});
    cd(datapath)

    %% Read blocks
    for block = 1:6
        try % Do not load emtpy blocks
            load(strcat(subjects{subj}, '_EEG_ET_Sternberg_block',num2str(block),'_merged.mat'))
            alleeg{block} = EEG;
            clear EEG
            fprintf('Subject FCD %.3s (%.3d/%.3d): Block %.1d loaded \n', subjects{subj}, subj, length(subjects), block)
        end
    end

    %% EXCLUDE TRIALS WITHOUT FIX CROSS IN RETENTION
    for block = 1:6
        try % Do not check empty blocks
            for evnt = 4:length(alleeg{block}.event) % Start from the 4th event to avoid index out of bounds
                if strcmp(alleeg{block}.event(evnt).type, '52')
                    % Check if any of the three preceding events are '16'
                    % (fixation cross in sternberg retention)
                    % use '~' before 'any' for blank retention trials
                    if any(strcmp({alleeg{block}.event(evnt-1).type, alleeg{block}.event(evnt-2).type, alleeg{block}.event(evnt-3).type}, '16'))
                        alleeg{block}.event(evnt).type = '92';
                    end
                elseif strcmp(alleeg{block}.event(evnt).type, '54')
                    if any(strcmp({alleeg{block}.event(evnt-1).type, alleeg{block}.event(evnt-2).type, alleeg{block}.event(evnt-3).type}, '16'))
                        alleeg{block}.event(evnt).type = '94';
                    end
                elseif strcmp(alleeg{block}.event(evnt).type, '56')
                    if any(strcmp({alleeg{block}.event(evnt-1).type, alleeg{block}.event(evnt-2).type, alleeg{block}.event(evnt-3).type}, '16'))
                        alleeg{block}.event(evnt).type = '96';
                    end
                end
            end
        end
    end

    % Segment FIXATION CROSS data by conditions
    for block = 1:6
        try % Do not segment empty blocks
            EEGl2fix = pop_epoch(alleeg{block},{'92'},[-2 3.5]);
            EEGl4fix = pop_epoch(alleeg{block},{'94'},[-2 3.5]);
            EEGl6fix = pop_epoch(alleeg{block},{'96'},[-2 3.5]);
            data2fix{block} = eeglab2fieldtrip(EEGl2fix, 'raw');
            data4fix{block} = eeglab2fieldtrip(EEGl4fix, 'raw');
            data6fix{block} = eeglab2fieldtrip(EEGl6fix, 'raw');
            % Compute and save ET-EVENTS
            sacc2fix{block} = sum(strcmp({EEGl2fix.event.type}, 'L_saccade'));
            sacc4fix{block} = sum(strcmp({EEGl4fix.event.type}, 'L_saccade'));
            sacc6fix{block} = sum(strcmp({EEGl6fix.event.type}, 'L_saccade'));
            fix2fix{block} = sum(strcmp({EEGl2fix.event.type}, 'L_fixation'));
            fix4fix{block} = sum(strcmp({EEGl4fix.event.type}, 'L_fixation'));
            fix6fix{block} = sum(strcmp({EEGl6fix.event.type}, 'L_fixation'));
            blink2fix{block} = sum(strcmp({EEGl2fix.event.type}, 'L_blink'));
            blink4fix{block} = sum(strcmp({EEGl4fix.event.type}, 'L_blink'));
            blink6fix{block} = sum(strcmp({EEGl6fix.event.type}, 'L_blink'));
        end
    end

    % Segment NON FIXATION CROSS data by conditions
    for block = 1:6
        try % Do not segment empty blocks
            EEGl2 = pop_epoch(alleeg{block},{'52'},[-2 3.5]);
            EEGl4 = pop_epoch(alleeg{block},{'54'},[-2 3.5]);
            EEGl6 = pop_epoch(alleeg{block},{'56'},[-2 3.5]);
            data2{block} = eeglab2fieldtrip(EEGl2, 'raw');
            data4{block} = eeglab2fieldtrip(EEGl4, 'raw');
            data6{block} = eeglab2fieldtrip(EEGl6, 'raw');
            % Compute and save ET-EVENTS
            sacc2{block} = sum(strcmp({EEGl2.event.type}, 'L_saccade'));
            sacc4{block} = sum(strcmp({EEGl4.event.type}, 'L_saccade'));
            sacc6{block} = sum(strcmp({EEGl6.event.type}, 'L_saccade'));
            fix2{block} = sum(strcmp({EEGl2.event.type}, 'L_fixation'));
            fix4{block} = sum(strcmp({EEGl4.event.type}, 'L_fixation'));
            fix6{block} = sum(strcmp({EEGl6.event.type}, 'L_fixation'));
            blink2{block} = sum(strcmp({EEGl2.event.type}, 'L_blink'));
            blink4{block} = sum(strcmp({EEGl4.event.type}, 'L_blink'));
            blink6{block} = sum(strcmp({EEGl6.event.type}, 'L_blink'));
        end
    end

    % Save ET-EVENTS
    org = pwd;
    savepath = strcat('/Volumes/methlab/Students/Arne/FCD/data/features/',subjects{subj}, '/gaze/');
    mkdir(savepath)
    cd(savepath)
    save saccades sacc2 sacc4 sacc6 sacc2fix sacc4fix sacc6fix 
    save fixations fix2 fix4 fix6 fix2fix fix4fix fix6fix
    save blinks blink2 blink4 blink6 blink2fix blink4fix blink6fix
    cd(pwd);

    %% Equalize labels
    update_labels(data2fix);
    update_labels(data4fix);
    update_labels(data6fix);
    update_labels(data2);
    update_labels(data4);
    update_labels(data6);

    %% Remove empty blocks
    data2fix = data2fix(~cellfun('isempty', data2fix));
    data4fix = data4fix(~cellfun('isempty', data4fix));
    data6fix = data6fix(~cellfun('isempty', data6fix));
    data2 = data2(~cellfun('isempty', data2));
    data4 = data4(~cellfun('isempty', data4));
    data6 = data6(~cellfun('isempty', data6));

    %% Append data for conditions
    cfg = [];
    cfg.keepsampleinfo = 'no';
    data2fix = ft_appenddata(cfg,data2fix{:});
    data4fix = ft_appenddata(cfg,data4fix{:});
    data6fix = ft_appenddata(cfg,data6fix{:});
    data2 = ft_appenddata(cfg,data2{:});
    data4 = ft_appenddata(cfg,data4{:});
    data6 = ft_appenddata(cfg,data6{:});

    %% Add trialinfo
    data2fix.trialinfo = ones(1,length(data2fix.trial))*92';
    data4fix.trialinfo = ones(1,length(data4fix.trial))*94';
    data6fix.trialinfo = ones(1,length(data6fix.trial))*96';
    data2.trialinfo = ones(1,length(data2.trial))*52';
    data4.trialinfo = ones(1,length(data4.trial))*54';
    data6.trialinfo = ones(1,length(data6.trial))*56';

    %% Append
    cfg = [];
    cfg.keepsampleinfo = 'no';
    datafix = ft_appenddata(cfg,data2fix,data4fix,data6fix);
    trialinfo = [data2fix.trialinfo,data4fix.trialinfo,data6fix.trialinfo];
    datafix.trialinfo = trialinfo';
    datafix.cfg =[ ];
    cfg = [];
    cfg.keepsampleinfo = 'no';
    data = ft_appenddata(cfg,data2,data4,data6);
    trialinfo = [data2.trialinfo,data4.trialinfo,data6.trialinfo];
    data.trialinfo = trialinfo';
    data.cfg =[ ];

    %% Get EyeTracking data
    cfg = [];
    cfg.channel = {'L-GAZE-X'  'L-GAZE-Y' 'L-AREA'};
    dataetfix = ft_selectdata(cfg,datafix);
    dataet = ft_selectdata(cfg,data);

    %% Get EEG data (excl. ET and EOG data)
    cfg = [];
    cfg.channel = {'all' '-B*' '-HEOGR' '-HEOGL', '-VEOGU', '-VEOGL' ,'-L-GAZE-X' , '-L-GAZE-Y' , '-L-AREA'};
    datafix = ft_selectdata(cfg,datafix);
    data = ft_selectdata(cfg,data);

    %% Resegment data to avoid filter ringing
    cfg = [];
    dataTFRfix = ft_selectdata(cfg,datafix); % TRF data long
    dataTFR = ft_selectdata(cfg,data); % TRF data long
    cfg = [];
    cfg.latency = [1 2]; % Time window for Sternberg task
    datafix = ft_selectdata(cfg,datafix); % EEG data
    dataetfix = ft_selectdata(cfg,dataetfix); % ET data
    data = ft_selectdata(cfg,data); % EEG data
    dataet = ft_selectdata(cfg,dataet); % ET data

    %% Re-reference data to average or common reference
    cfg = [];
    cfg.reref   = 'yes';
    cfg.refchannel = 'all';
    datafix = ft_preprocessing(cfg,datafix);
    data = ft_preprocessing(cfg,data);

    %% Save data
    savepath = strcat('/Volumes/methlab/Students/Arne/FCD/data/features/',subjects{subj}, '/eeg/');
    mkdir(savepath)
    cd(savepath)
    save dataEEG_sternberg_fix datafix
    save dataEEG_sternberg data
    save dataEEG_TFR_sternberg_fix dataTFRfix
    save dataEEG_TFR_sternberg dataTFR
    savepathET = strcat('/Volumes/methlab/Students/Arne/FCD/data/features/',subjects{subj}, '/gaze/');
    mkdir(savepathET)
    cd(savepathET)
    save dataET_sternberg_fix dataetfix
    save dataET_sternberg dataet
    clc
    if subj == length(subjects)
        disp(['Subject FCD ' num2str(subjects{subj})  ' (' num2str(subj) '/' num2str(length(subjects)) ') done. PREPROCESSING FINALIZED.'])
    else
        disp(['Subject FCD ' num2str(subjects{subj})  ' (' num2str(subj) '/' num2str(length(subjects)) ') done. Loading next subject...'])
    end
end
toc

%% Function to update labels
function update_labels(data)
blocks = size(data);
for block = 1:blocks
    if isempty(data{block})
        break;
    else
        try
            for i = 1:blocks
                if ~isempty(data{i}.label)
                    data{block}.label = data{i}.label;
                    break;
                end
            end
        catch
            warning('Error occurred while processing block %d in data structure.', block);
        end
    end
end
end