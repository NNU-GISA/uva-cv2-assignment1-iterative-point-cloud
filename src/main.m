clear
clc
close all

%%
resdir = setup();

%%
A = readPcd(fullfile(resdir, 'data/0000000038.pcd'));

%% Load test data
source = load(fullfile(resdir, 'source.mat'));
source = transpose(source.source);
target = load(fullfile(resdir, 'target.mat'));
target = transpose(target.target);

%% Visualize test data
figure();
source_struct = struct();
source_struct.x = source(:, 1);
source_struct.y = source(:, 2);
source_struct.z = source(:, 3);
fscatter3(source_struct);

figure();
source_struct = struct();
source_struct.x = source(:, 1);
source_struct.y = source(:, 2);
source_struct.z = source(:, 3);
fscatter3(source_struct);

%%
[R, t] = icp();


