function  cutData(filePath)

% ANT EEG data comes in 1 file containig all tasks (e.g. Resting, CDA,
% etc.). This function cuts the data into distinct tasks, saves the tasks
% to .mat files and moves the original file to filePath/Archiv

% EEGlab with 'pop_loadeep_v4' required

% load the data
[EEGorig, command] = pop_loadeep_v4(filePath);

% extract path and filename
p = strsplit(filePath, filesep);
filePath = fullfile(filesep, p{1:end-1});
fileName = p{end};
p = strsplit(fileName, '_');
subjectID = p{1};

% remove photodiode data and save to a file
diode = pop_select(EEGorig, 'channel', [129]);
task = [subjectID, '_Photodiode.mat'];
save(fullfile(filePath, task), 'diode', '-v7.3')

% exclude photodiode data
if EEGorig.nbchan > 128
    EEGorig = pop_select(EEGorig, 'nochannel', [129:EEGorig.nbchan]);
end

% add Ref channel and data, and load channel location file
EEGorig.data(129, :) = 0;
EEGorig.nbchan = 129;
EEGorig.chanlocs(129).labels = 'CPz';                
locspath = 'standard_1005.elc';
EEGorig = pop_chanedit(EEGorig, 'lookup', locspath);

%% Find start and end triggers of each task

% Resting
i10 = find(ismember({EEGorig.event.type}, '10')); % Start
i90 = find(ismember({EEGorig.event.type}, '90')); % End

% Sternberg block 1
i31 = find(ismember({EEGorig.event.type}, '31'));
i41 = find(ismember({EEGorig.event.type}, '41'));

% Sternberg block 2
i32 = find(ismember({EEGorig.event.type}, '32'));
i42 = find(ismember({EEGorig.event.type}, '42'));

% Sternberg block 3
i33 = find(ismember({EEGorig.event.type}, '33'));
i43 = find(ismember({EEGorig.event.type}, '43'));

% Sternberg block 4
i34 = find(ismember({EEGorig.event.type}, '34'));
i44 = find(ismember({EEGorig.event.type}, '44'));

% Sternberg block 5
i35 = find(ismember({EEGorig.event.type}, '35'));
i45 = find(ismember({EEGorig.event.type}, '45'));

% Sternberg block 6
i36 = find(ismember({EEGorig.event.type}, '36'));
i46 = find(ismember({EEGorig.event.type}, '46'));

%% Cut

% Resting  
try
    EEG = pop_select(EEGorig, 'point', [EEGorig.event(i10(1)).latency, EEGorig.event(i90(1)).latency]);
    task = [subjectID, '_Resting_EEG.mat'];
    % save to a file
    save(fullfile(filePath, task), 'EEG', '-v7.3')
catch ME
    ME.message
    warning('Resting is missing...')
end

% Block 1
try
    EEG = pop_select(EEGorig, 'point', [EEGorig.event(i31(end)).latency, EEGorig.event(i41(end)).latency]);
    task = [subjectID, '_FCD_Sternberg', '_block1_task', '_EEG.mat'];
    % save to a file
    save(fullfile(filePath, task), 'EEG', '-v7.3')
catch ME
    ME.message
    warning('Block 1 is missing...')
end

% Block 2
try
    EEG = pop_select(EEGorig, 'point', [EEGorig.event(i32(end)).latency, EEGorig.event(i42(end)).latency]);
    task = [subjectID, '_FCD_Sternberg', '_block2_task', '_EEG.mat'];
    % save to a file
    save(fullfile(filePath, task), 'EEG', '-v7.3')
catch ME
    ME.message
    warning('Block 2 is missing...')
end

% Block 3
try
    EEG = pop_select(EEGorig, 'point', [EEGorig.event(i33(end)).latency, EEGorig.event(i43(end)).latency]);
    task = [subjectID, '_FCD_Sternberg', '_block3_task', '_EEG.mat'];
    % save to a file
    save(fullfile(filePath, task), 'EEG', '-v7.3')
catch ME
    ME.message
    warning('Block 3 is missing...')
end

% Block 4
try
    EEG = pop_select(EEGorig, 'point', [EEGorig.event(i34(end)).latency, EEGorig.event(i44(end)).latency]);
    task = [subjectID, '_FCD_Sternberg', '_block4_task', '_EEG.mat'];
    % save to a file
    save(fullfile(filePath, task), 'EEG', '-v7.3')
catch ME
    ME.message
    warning('Block 4 is missing...')
end

% Block 5
try
    EEG = pop_select(EEGorig, 'point', [EEGorig.event(i35(end)).latency, EEGorig.event(i45(end)).latency]);
    task = [subjectID, '_FCD_Sternberg', '_block5_task', '_EEG.mat'];
    % save to a file
    save(fullfile(filePath, task), 'EEG', '-v7.3')
catch ME
    ME.message
    warning('Block 5 is missing...')
end

% Block 6
try
    EEG = pop_select(EEGorig, 'point', [EEGorig.event(i36(end)).latency, EEGorig.event(i46(end)).latency]);
    task = [subjectID, '_FCD_Sternberg', '_block6_task', '_EEG.mat'];
    % save to a file
    save(fullfile(filePath, task), 'EEG', '-v7.3')
catch ME
    ME.message
    warning('Block 6 is missing...')
end

% mkdir archive and move the orig files there
source = fullfile(filePath, fileName);
destination = fullfile(fullfile(filePath, 'archive'));
mkdir(destination)
movefile(source,destination) % .cnt file
source = fullfile(filePath, [fileName(1:end-4), '.evt']);
movefile(source,destination) % .evt file
source = fullfile(filePath, [fileName(1:end-4), '.seg']);
movefile(source,destination) % .seg file

% end function
end