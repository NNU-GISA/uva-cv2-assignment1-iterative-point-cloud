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

%%
A1 = readPcd(fullfile(datadir, ids(39) + '.pcd'));
A2 = readPcd(fullfile(datadir, ids(40) + '.pcd'));

% As a test please verify that this returns a matrix of size 59596x4, but not something else.
assert(isequal(size(A1), [59596, 4]))

%%
source = load(fullfile(resdir, 'source.mat'));
target = load(fullfile(resdir, 'target.mat'));
A1 = transpose(source.source);
A2 = transpose(target.target);

[R, t] = icp(A1, A2);
R
t
