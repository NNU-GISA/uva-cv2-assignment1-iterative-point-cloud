function [R, t] = icp(A1, A2, sampling_strategy)
% ICP Iterative Closest Point algorithm.
% Given two point-clouds A1 (base) and A2 (target), ICP tries to find a spatial transformation that minimizes the distance (e.g. Root Mean Square (RMS)) between A1 and A2
% R and t are the rotation matrix and the translation vector in d dimensions, respectively. ψ is a one-to-one matching function that creates correspondences between the elements of A1 and A2. R and t that minimize above equation are used to define camera movement between A1 and A2.

% sampling_strategy

[n1, d1] = size(A1);
[n2, d2] = size(A2);

% step 1: initialize R and t
R = eye(d1);
t = zeros(n1, d1);

p = sample(A1);
q = A2;

% step 4: go to step 2 unless RMS is unchanged.
% TODO: track total R and t
step = 0;
old_distances = zeros(n1, 1);
min_distances = ones(n1, 1);
% ^ arbitrary initialization not equal to old_distances

tic;
while ~isequal(old_distances, min_distances)
    step = step + 1
    p = p * R + t;
    old_distances = min_distances;
    [min_distances, min_idxs] = find_closest(p, q);
    [R, t] = estimate_transform(p, q)
end
time = toc
step
end

% step 2: Find the closest points for each point in the base point set (A1) from the target point set (A2) using brute-force approach.
function idx = find_closest(p, q)
    d = dist(p, q');
    [~, idx] = min(d,[],2);
end

% step 3: refine R and t using Singular Value Decomposition
% check https://igl.ethz.ch/projects/ARAP/svd_rot.pdf
function [R, t] = estimate_transform()
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
    R = V * diag(repmat(1, determinant, 1)) * U';
    % - compute the optimal translation
    t = q_hat - p_hat * R;
end

% sample n points from a point cloud
% default: get all of them
function [A_] = sample(A, n)
    if nargin < 2
        [n, d] = size(A);
    end
    A_ = randsample(A, n);
end
