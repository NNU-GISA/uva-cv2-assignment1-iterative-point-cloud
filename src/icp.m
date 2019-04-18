function [R, T] = icp(A1, A2, sampling_strategy)
% ICP Iterative Closest Point algorithm.
% Given two point-clouds A1 (base) and A2 (target), ICP tries to find a spatial transformation that minimizes the distance (e.g. Root Mean Square (RMS)) between A1 and A2
% r and t are the rotation matrix and the translation vector in d dimensions, respectively. ψ is a one-to-one matching function that creates correspondences between the elements of A1 and A2. r and t that minimize above equation are used to define camera movement between A1 and A2.

% sampling_strategy

[n1, d1] = size(A1);
[n2, d2] = size(A2);

% step 1: initialize r and t
R = eye(d1);
T = zeros(1, d1);
r = R;
t = T;

p = sample(A1);
q = A2;

% step 4: go to step 2 unless RMS is unchanged.
% TODO: track total r and t
step = 0;
old_distances = zeros(n1, 1);
min_distances = ones(n1, 1);
% ^ arbitrary initialization not equal to old_distances

tic;
while ~isequal(old_distances, min_distances)
    step = step + 1
    p = p * r + t;
    old_distances = min_distances;
    [min_distances, min_idxs] = find_closest(p, q);
    [r, t] = estimate_transform(p, q)
    R = R * t;
    T = T .+ t;
end
time = toc
step
end

% step 2: Find the closest points for each point in the base point set (A1) from the target point set (A2) using brute-force approach.
function [min_distances, min_idxs] = find_closest(p, q)
    distances = zeros(n1, n2);
    for i = 1 : n1
        for j = 1 : n2
            distances(i, j) = rms(p(i, :), q(j, :));
        end
    end
    % TODO: confirm this only yields one point per point
    [min_distances, min_idxs] = min(distances);
    size(min_idxs)
end

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

% sample n points from a point cloud
% default: get all of them
function [A_] = sample(A, n)
    if nargin < 2
        [n, d] = size(A);
    end
    A_ = randsample(A, n);
end
