function [R, t] = icp(A1, A2, sampling_strategy, n_samples)
% ICP Iterative Closest Point algorithm.
% Given two point-clouds A1 (base) and A2 (target), ICP tries to find a spatial transformation that minimizes the distance (e.g. Root Mean Square (RMS)) between A1 and A2
% r and t are the rotation matrix and the translation vector in d dimensions, respectively. ψ is a one-to-one matching function that creates correspondences between the elements of A1 and A2. r and t that minimize above equation are used to define camera movement between A1 and A2.
% sampling_strategy: 'full', 'uniform', 'random'

[n1, d1] = size(A1);
[~, d2] = size(A2);

assert(d1 == d2, 'Input data must have same second dimension');

if nargin < 3
    sampling_strategy = 'full';
end
if nargin < 4
    n_samples = n1;
end

% initialize r and t
R = eye(d1);
t = zeros(1, d1);

% initialize p
if strcmp(sampling_strategy, 'full')
    p = A1;
elseif strcmp(sampling_strategy, 'uniform')
    p = randsample(A1, n_samples);
end

% initialize q
idx = match_points(p, A2);
q = A2(idx, :);

% initialize scores
prev_score = 1;
cur_score = 0;

while cur_score ~= prev_score
    
    % refine R and t using SVD (step 3)
%    [new_R, new_t] = estimate_transform(p, q);
%    R = R .* new_R;
%    t = t + new_t;
    
    % determine new p values
    if strcmp(sampling_strategy, 'full')
        p = A1;
    elseif strcmp(sampling_strategy, 'uniform')
        p = randsample(A1, n_samples);
    end
    p = p * R' - t;
    
    % determine new q values
    idx = match_points(p, A2);
    q = A2(idx, :);
    
    % score new transformation
    prev_score = cur_score;
    cur_score = eval(p, q);
    
    disp(cur_score);
    
end

return

r = R;
T = t;

% step 4: go to step 2 unless RMS is unchanged.
% TODO: track total r and t
step = 0;
old_distances = zeros(n1, 1);
min_distances = ones(n1, 1);
% ^ arbitrary initialization not equal to old_distances


tic;
while ~isequal(old_distances, min_distances)
    step = step + 1
    if sampling_strategy == 'random'
        p_ = randsample(A1, n);
    end
    p = p_ * r + t;
    old_distances = min_distances;
    [min_distances, min_idxs] = match_points(p, q);
    [r, t] = estimate_transform(p, q)
    R = R * r;
    T = T + t;
end
time = toc
step
end

% step 2: Find the closest points for each point in the base point set (A1) from the target point set (A2) using brute-force approach.
function idx = match_points(p, q)
    idx = zeros(1, size(p, 1));
    for i = 1:size(p, 1)
        d = dist(p(i, :), q');
        [~, j] = min(d,[],2);
        idx(i) = j;
    end
end

function score = eval(A1, A2)
    scores = vecnorm(A2 - A1, 2, 2);
    score = sum(scores, 1);
end

% TODO fix this (Error: This statement is not inside any function.)
%assert(isequal(find_closest(eye(2), eye(2)), [[0 0], [0 1]]));

% step 3: refine r and t using Singular Value Decomposition
% check https://igl.ethz.ch/projects/ARAP/svd_rot.pdf
function [r, t] = estimate_transform(p, q)
    % - compute the weighted centroids of both point sets
    p_hat = mean(p);
    q_hat = mean(q);
    % - compute the centered vectors
    X = p - p_hat;
    Y = q - q_hat;
    % - compute the d×d covariance matrix
    W = diag(repmat(1/n1, n1, 1));
    S = X' * W * Y;
    % - compute the singular value decomposition S=UΣVT
    [U, Sigma, V] = svd(S);
    determinant = det(V * U');
    r = V * diag(repmat(1, determinant, 1)) * U';
    % - compute the optimal translation
    t = q_hat - p_hat * r;
end

% TODO fix this (Error: This statement is not inside any function.)
%assert(isequal(estimate_transform(eye(2), eye(2)), [eye(2), [0 0]]));
