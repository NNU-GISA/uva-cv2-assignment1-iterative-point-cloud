clear
clc
close all

%% Setup
resdir = setup();

%% Params
doPlot = true;
n_tests = 1;

%% Load test data
source = load(fullfile(resdir, 'source.mat'));
source = transpose(source.source);
target = load(fullfile(resdir, 'target.mat'));
target = transpose(target.target);

%% Run ICP
[R, t] = icp(source, target, 0.001, 'uniform-each', 800);









