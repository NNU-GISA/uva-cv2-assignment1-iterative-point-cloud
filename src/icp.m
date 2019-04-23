function [R, t] = icp(A1, A2, epsilon, sampling_strategy, sampling_param)
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

% check sampling param for uniform sampling strategies
if strcmp(sampling_strategy, 'uniform') || strcmp(sampling_strategy, 'uniform-each')
    assert(nargin >= 5, 'No number of sampled points given');
    assert(sampling_param <= n1, 'Number of sampled points is larger than total amount of points');
end

% check sampling param for sampling strategy using informative regions
if strcmp(sampling_strategy, 'informative')
    assert(nargin >= 5, 'No point weights given');
    assert(length(sampling_param) == n1, 'Point weights do not match number of points in A1');
end

% initialize p for sampling strategies that initialize p once
if strcmp(sampling_strategy, 'all')
    init_p = A1;
elseif strcmp(sampling_strategy, 'uniform')
    idx1 = randsample(n1, sampling_param);
    init_p = A1(idx1, :);
end

% initialize r and t
R = eye(d1);
t = zeros(1, d1);

% initialize scores
prev_score = 1;
cur_score = 0;

while abs(cur_score - prev_score) > epsilon
    
    % determine new p values
    if strcmp(sampling_strategy, 'all') || strcmp(sampling_strategy, 'uniform')
        p = init_p;
    elseif strcmp(sampling_strategy, 'uniform-each')
        idx1 = randsample(n1, sampling_param);
        p = A1(idx1, :);
    elseif strcmp(sampling_strategy, 'informative')
        assert(false, 'NotImplementedError');
    end
    p = p * R' + t;
    
    % determine new q values
    idx2 = match_points(p, A2);
    q = A2(idx2, :);
    
    % refine R and t using SVD (step 3)
    [new_R, new_t] = estimate_transform(p, q);
    R = new_R * R;
    t = new_t + t;
    
    % score new transformation
    prev_score = cur_score;
    cur_score = icp_eval(p, q, new_R, new_t);
    
    disp(cur_score);
    
end
end

function idx = match_points(p, q)
idx = zeros(1, size(p, 1));
% determine closest point in q per point in p
% (1 at a time to avoid memory errors)
for i = 1:size(p, 1)
    d = dist(p(i, :), q');
    [~, j] = min(d, [], 2);
    idx(i) = j;
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
