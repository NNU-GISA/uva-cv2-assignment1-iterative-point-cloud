clear
clc
close all

%% Setup
resdir = setup();
datadir = fullfile(resdir, 'data');

%% Params
n_iter_test = 5;
sigmaArray = [ 0 0.05 0.1 0.15 ];  % used to generate noise

% test rotation matrix (10 degrees around the z-axis)
rad = 30 * pi / 180;
test_R = [...
     cos(rad) sin(rad)  0   0 ; ...
    -sin(rad) cos(rad)  0   0 ; ...
        0        0      1   0 ; ...
        0        0      0   1 ; ...
    ];

% test translation vector
test_t = [ 0.025 0.050 0.100 0 ];

% test data
A1 = loadA(datadir, "0000000000");
sample_weights = ones(1, size(A1, 1));  % TODO use get_weights function
A2 = A1(randperm(size(A1, 1)), :) * test_R' + test_t;

% icp params
epsilon = 0.001;
sampling_strategies = ["all", "uniform", "uniform-each", "informative"];
n_samples = 5000;
n_iter_icp = 40;
force_iter = true;

n_strategies = length(sampling_strategies); 

%% Visualize test data and its transformation
visualize_cloud([A1 ; A2]);

%% Test accuracy and time

resAccArray = zeros(1, n_strategies);
resTimeArray = zeros(1, n_strategies);
resScoreArray = zeros(n_strategies, n_iter_icp);
for k = 1:n_strategies
    for i = 1:n_iter_test

        % run ICP and record run-time
        tic;
        [R, t, scoreArray] = icp(A1, A2, epsilon, sampling_strategies(k), ...
            n_samples, sample_weights, n_iter_icp, force_iter);
        time = toc;

        % determine accuracy using RMS-error as a measure
        idx = knnsearch(A2, A1 * R' + t);
        score = icp_eval(A1, A2(idx, :), R, t);
        acc = sqrt(score / length(A1));

        % record data
        resAccArray(k) = resAccArray(k) + acc;
        resTimeArray(k) = resTimeArray(k) + time;
        if strcmp(sampling_strategies(k), "all")
            scoreArray = scoreArray ./ length(A1);
        else
            scoreArray = scoreArray ./ n_samples;
        end
        resScoreArray(k, :) = resScoreArray(k, :) + sqrt(scoreArray);

    end
end
    
% average data
resAccArray = resAccArray ./ n_iter_test;
resTimeArray = resTimeArray ./ n_iter_test;
resScoreArray = resScoreArray ./ n_iter_test;

% output data
for k = 1:n_strategies
    str = sprintf('Accuracy `%s`: %d', sampling_strategies(k), resAccArray(k));
    disp(str);
end
for k = 1:n_strategies
    str = sprintf('Time `%s`: %d', sampling_strategies(k), resTimeArray(k));
    disp(str);
end
create_plot(resScoreArray, sampling_strategies, '#iterations', 'RMS error', 'RMS error over #iterations');
%% Test stability

resStabilityArray = zeros(1, n_iter_icp);

n = 10;

resStabilityArray = zeros(1, n);

scalar_factor = linspace(1,3,n);

% NOTES:
%
% for k=1:n_strategies
% for l=1:<number of times per sampled matrix>
% for j=1:n_magnitudes
% for i=1:n_iter_test
%
% run icp as: [R, t, scoreArray] = icp(A1, A2, epsilon, sampling_strategies(k), ...
%                     n_samples, sample_weights, n_iter_icp, force_iter);
% source and target changed to A1 and A2
% plotting can be done using create_plot (at the bottom of this file)
% you probably want to recompute the score over the entire dataset just
% like was done for accuracy (line 61,62,63)

%{

for i = 1:n
    
%      R = [1,-0.00292012801766150,-0.0827472646167709,0;
%          0.00287620088601331,1,-0.000650057579013490,0;
%          0.0827488031192036,0.000409827711611413,1,0;
%          0,0,0,1];
%      t = [0.0771391744749337,0.000660309677121065,0.00207824512811228,0];
    
     R = [1,-0.00292012801766150,-0.0827472646167709;
         0.00287620088601331,1,-0.000650057579013490;
         0.0827488031192036,0.000409827711611413,1];
     t = [0.0771391744749337,0.000660309677121065,0.00207824512811228];
    
    R_a = R.*scalar_factor(i);
    t_a = t.*scalar_factor(i);
    
    augmented_source = source * R_a' + t_a;
    
    [R, t, scoreArray] = icp(source, augmented_source);
    
    resStabilityArray(i) = scoreArray(end);
    
    
end

plot(linspace(1,3,n), resStabilityArray)
title('Stability')
ylabel('RMSE')
xlabel('Changes in magnitude')

resStabilityArray = resStabilityArray / n_iter_test;

disp(resStabilityArray);
%}

%% Test tolerance to noise

resNoiseArray = zeros(n_strategies, length(sigmaArray), n_iter_test, n_iter_icp);

for k = 1:n_strategies
    for j = 1:length(sigmaArray)
        for i = 1:n_iter_test

            % generate noise
            noise = normrnd(0, sigmaArray(j), 1, length(A1));

            % run ICP
            [R, t, scoreArray] = icp(A1 + noise', A2, epsilon, sampling_strategies(k), ...
                n_samples, sample_weights, n_iter_icp, force_iter);

            % record scores
            if strcmp(sampling_strategies(k), "all")
                scoreArray = scoreArray ./ length(A1);
            else
                scoreArray = scoreArray ./ n_samples;
            end
            resNoiseArray(k, j, i, :) = resNoiseArray(k, j, i, :) + reshape(sqrt(scoreArray), 1, 1, 1, n_iter_icp);

        end
    end
end

%% output data (Tolerance to Noise)
for j = 1:length(sigmaArray)
    resNoiseDat = reshape(resNoiseArray(:, j, :, :), n_strategies, n_iter_test, n_iter_icp);
    resNoiseMean = reshape(mean(resNoiseDat, 2), n_strategies, n_iter_icp);
    resNoiseVar = reshape(var(resNoiseDat, 1, 2), n_strategies, n_iter_icp);
    resNoiseAbsVar = abs(resNoiseVar);
    
    figure();
    hold on;
    for k = 1:size(sampling_strategies, 2)
        errorbar([1:size(resNoiseMean(k, :), 2)] + (k-1)*0.15, resNoiseMean(k, :), -resNoiseAbsVar(k, :), resNoiseAbsVar(k, :), 'horizontal');
    end
    hold off;
    xlabel("#iterations");
    ylabel("RMS error");
    title_str = sprintf('Tolerance to noise (sigma=%.2f)', sigmaArray(j));
    title(title_str);
    legend(sampling_strategies);
    grid on;    
    
end

%% Plotting function

function create_plot(data, sampling_strategies, xlabel_str, ylabel_str, title_str)
figure();
hold on;
for k = 1:size(sampling_strategies, 2)
    plot(1:size(data(k, :), 2), data(k, :));
end
hold off;
xlabel(xlabel_str);
ylabel(ylabel_str);
title(title_str);
legend(sampling_strategies);
grid on;
end

