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
weights = zeros(1, length(source));
weights(1:800) = 1;
[R, t] = icp(source, target, 0.001, 'informative', 400, weights);









