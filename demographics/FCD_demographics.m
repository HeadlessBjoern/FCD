%% FCD Demographics

% Extracted Variables
%   Age from Date of Birth
%   Gender
%   Handedness
%   Educational Level

%% Setup
clear
clc
close all

%% Read data
tbl = readtable('/Volumes/methlab_vp/FCD/FCD - VPs.xlsx', 'VariableNamingRule','modify');
tbl = tbl(1:101, {'ID', 'Geschlecht', 'Geburtsdatum', 'H_ndigkeit'});

%% Age
% Define the current date
current_date = datetime('today');
% Calculate the age
age = years(current_date - tbl.Geburtsdatum);
% Replace NaN ages with empty arrays
age(isnan(age)) = [];
age_mean = mean(age);
age_std = std(age);
fprintf('Mean age: %.2f years | Std age: %.2f years \n', age_mean, age_std)
%% Gender
gender_counts = groupsummary(tbl, 'Geschlecht');
if isempty(gender_counts{1, 1}{1}) 
    gender_counts = gender_counts(2:3, :);
end
gender_percentage = (gender_counts.GroupCount / sum(gender_counts.GroupCount)) * 100;
disp(table(gender_counts.Geschlecht, gender_percentage, 'VariableNames', {'Gender', 'Percentage'}));

%% Handedness
handedness_counts = groupsummary(tbl, 'H_ndigkeit');
if isempty(handedness_counts{1, 1}{1}) 
    handedness_counts = handedness_counts(2:3, :);
end
handedness_percentage = (handedness_counts.GroupCount / sum(handedness_counts.GroupCount)) * 100;
disp(table(handedness_counts.H_ndigkeit, handedness_percentage, 'VariableNames', {'Handedness', 'Percentage'}));


