clear
clc
close all

%% Setup
resdir = setup();
datadir = fullfile(resdir, 'data');

%% Get data ids
files = dir(fullfile(datadir, '*.mat'));
ids = strings(length(files), 1);
for i=1:length(files)
    [~, id, ~] = fileparts(files(i).name);
    ids(i) = id;
end

%% TODO: loop over ids
A1 = readPcd(fullfile(datadir, ids(39) + '.pcd'));
A2 = readPcd(fullfile(datadir, ids(40) + '.pcd'));
