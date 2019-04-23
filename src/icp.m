function [R, t, scoreArray] = icp(A1, A2, epsilon, sampling_strategy, n_samples, sample_weights, max_iter)
% ICP Iterative Closest Point algorithm.
% Given two point-clouds A1 (base) and A2 (target), ICP tries to find a spatial transformation that minimizes the distance (e.g. Root Mean Square (RMS)) between A1 and A2
% r and t are the rotation matrix and the translation vector in d dimensions, respectively. ψ is a one-to-one matching function that creates correspondences between the elements of A1 and A2. r and t that minimize above equation are used to define camera movement between A1 and A2.
% sampling_strategy: 'full', 'uniform', 'random'

[n1, d1] = size(A1);
[~, d2] = size(A2);

assert(d1 == d2, 'Input data must have same second dimension');

if nargin < 3
    epsilon = 0.001;
end
if nargin < 4
    sampling_strategy = 'all';
end

% check if sampling strategy is valid
assert(ismember(sampling_strategy, ["all", "uniform", "uniform-each", "informative"]), ...
    'Unknown sampling strategy');

% check number of samples for sampling strategies that are not 'all'
if ~strcmp(sampling_strategy, 'all')
    assert(nargin >= 5, 'No number of sampled points given');
    assert(n_samples <= n1, 'Number of sampled points is larger than total amount of points');
end

% check weigths for sampling strategy using informative regions
if strcmp(sampling_strategy, 'informative')
    assert(nargin >= 6, 'No point weights given');
    assert(length(sample_weights) == n1, 'Point weights do not match number of points in A1');
end

% initialize p for sampling strategies that initialize p once
if strcmp(sampling_strategy, 'all')
    init_p = A1;
elseif strcmp(sampling_strategy, 'uniform')
    idx1 = randsample(n1, n_samples);
    init_p = A1(idx1, :);
end

% initialize r and t
R = eye(d1);
t = zeros(1, d1);

% initialize score
cur_score = 0;

doWhile = true;

scoreArray = [];
n_iter = 0;

while doWhile
    
    % determine new p values
    if strcmp(sampling_strategy, 'all') || strcmp(sampling_strategy, 'uniform')
        p = init_p;
    elseif strcmp(sampling_strategy, 'uniform-each')
        idx1 = randsample(n1, n_samples);
        p = A1(idx1, :);
    elseif strcmp(sampling_strategy, 'informative')
        idx1 = randsample(n1, n_samples, true, sample_weights);
        p = A1(idx1, :);
    end
    p = p * R' + t;
    
    % determine new q values
    idx2 = knnsearch(A2, p);
    q = A2(idx2, :);
    
    % refine R and t using SVD (step 3)
    [new_R, new_t] = estimate_transform(p, q);
    R = new_R * R;
    t = new_t + t;
    
    % score new transformation
    prev_score = cur_score;
    cur_score = icp_eval(p, q, new_R, new_t);
    
    scoreArray = [scoreArray cur_score];
    n_iter = n_iter + 1;
    
    % display score for this iteration
    disp(cur_score);
    
    if nargin >= 7
        doWhile = n_iter < max_iter;
    else
        doWhile = abs(cur_score - prev_score) > epsilon;
    end
    
end
end

% step 3: refine r and t using Singular Value Decomposition
% check https://igl.ethz.ch/projects/ARAP/svd_rot.pdf
function [R, t] = estimate_transform(p, q)
% - compute the (not weighted) centroids of both point sets
p_hat = mean(p, 1);
q_hat = mean(q, 1);
% - compute the centered vectors
X = p - p_hat;
Y = q - q_hat;
% - compute the d×d covariance matrix
S = X' * Y;
% - compute the singular value decomposition S=UΣVT
[U, ~, V] = svd(S);
detVU = det(V * U');
R = V * diag([ones(1, size(V, 2) - length(detVU)) detVU]) * U';
% - compute the optimal translation
t = q_hat - p_hat * R';
end
