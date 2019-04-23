clear
clc
close all

%% Setup
resdir = setup();

%% Params
doPlot = true;
n_iter_icp = 30;
n_iter_test = 3;
sigmaArray = [ 0 0.5 1 ];

% icp params
epsilon = 0.001;
sampling_strategy = 'uniform-each';
n_samples = 800;
sample_weights = 0;

%% Load test data
source = load(fullfile(resdir, 'source.mat'));
source = transpose(source.source);
target = load(fullfile(resdir, 'target.mat'));
target = transpose(target.target);

%% Run ICP
weights = zeros(1, length(source));
weights(1:800) = 1;
[R, t] = icp(source, target, epsilon, sampling_strategy, n_samples, sample_weights);

%% Test accuracy and time

resAcc = 0;
resTime = 0;

for i = 1:n_iter_test
    
    % run ICP and record run-time
    tic;
    [R, t] = icp(source, target, epsilon, ...
        sampling_strategy, n_samples, sample_weights, n_iter_icp);
    time = toc;
    
    % determine accuracy using RMS-error as a measure
    idx = match_points(source * R' + t, target);
    score = icp_eval(source, target(idx, :), R, t);
    acc = sqrt(score / length(source));
    
    % record data
    resAcc = resAcc + acc;
    resTime = resTime + time;
    
    % display progress
    disp(i);
    disp(R);
    disp(t);
    
end

resAcc = resAcc / n_iter_test;
resTime = resTime / n_iter_test;

disp(resAcc);
disp(resTime);

%% Test stability

resStabilityArray = zeros(1, n_iter_icp);

for i = 1:n_iter_test
    
    % TODO test stability
    
end

resStabilityArray = resStabilityArray / n_iter_test;

disp(resStabilityArray);

%% Test tolerance to noise

resNoiseArray = zeros(length(sigmaArray), n_iter_icp);

for j = 1:length(sigmaArray)
    for i = 1:n_iter_test
        
        % generate noise
        noise = normrnd(0, sigmaArray(j), 1, length(source));
        
        % run ICP
        [R, t, scoreArray] = icp(source + noise', target, epsilon, ...
            sampling_strategy, n_samples, sample_weights, n_iter_icp);
        
        % record scores
        resNoiseArray(j, :) = resNoiseArray(j, :) + sqrt(scoreArray / n_samples);
        
        disp('-----')
        
    end
end

resNoiseArray = resNoiseArray / n_iter_test;

disp(resNoiseArray);

