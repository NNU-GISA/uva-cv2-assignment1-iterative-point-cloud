clear
clc
close all

%% Setup
resdir = setup();

%% Params
doSave = false;

% As a test please verify that this returns a matrix of size 59596x4, but not something else.
assert(isequal(size(A1), [59596, 4]));

%% Load test data
source = load(fullfile(resdir, 'source.mat'));
source = transpose(source.source);
target = load(fullfile(resdir, 'target.mat'));
target = transpose(target.target);

%% Visualize test data
fig_src = visualize_cloud(source);
fig_trg = visualize_cloud(target);

%% Save results
if doSave
    saveas(fig_src, 'cloud_src.png', 'png');
    saveas(fig_trg, 'cloud_trg.png', 'png');
end

%%
[R, t] = icp(source, target);
R
t
