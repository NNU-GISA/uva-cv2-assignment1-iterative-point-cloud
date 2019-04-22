function [R, t, idx] = icp(A1, A2, epsilon, sampling_strategy, n_samples)
% ICP Iterative Closest Point algorithm.
% Given two point-clouds A1 (base) and A2 (target), ICP tries to find a spatial transformation that minimizes the distance (e.g. Root Mean Square (RMS)) between A1 and A2
% r and t are the rotation matrix and the translation vector in d dimensions, respectively. ψ is a one-to-one matching function that creates correspondences between the elements of A1 and A2. r and t that minimize above equation are used to define camera movement between A1 and A2.
% sampling_strategy: 'full', 'uniform', 'random'

[n1, d1] = size(A1);
[~, d2] = size(A2);

assert(d1 == d2, 'Input data must have same second dimension');

if nargin < 3
    epsilon = 0;
end
if nargin < 4
    sampling_strategy = 'all';
end
if strcmp(sampling_strategy, 'all')
    n_samples = n1;
elseif nargin < 5
    n_samples = fix(n1 / 50 + 5);
end

assert(ismember(sampling_strategy, ["all", "uniform"]), 'Unknown sampling strategy');
assert(n_samples <= n1, 'Number of sampled points is larger than total amount of points');

% initialize r and t
R = eye(d1);
t = zeros(1, d1);

% initialize scores
prev_score = 1;
cur_score = 0;

while abs(cur_score - prev_score) > epsilon
    % determine new p values
    if strcmp(sampling_strategy, 'all') || strcmp(sampling_strategy, 'uniform')
        idx1 = randsample(n1, n_samples);
        p = A1(idx1, :);
    end
    p = p * R' + t;
    
    % determine new q values
    idx2 = match_points(p, A2);
    q = A2(idx2, :);
    
    % refine R and t using SVD (step 3)
    [new_R, new_t] = estimate_transform(p, q);
    R = R .* new_R;
    t = t + new_t;
    
    % score new transformation
    prev_score = cur_score;
    cur_score = eval(p, q, new_R, new_t);
    
%    break
%    disp(cur_score);
    
end

idx = match_points(A1 * R' + t, A2);

end

%{
function idx = match_points(p, q)
idx = zeros(1, size(p, 1));
for i = 1:size(p, 1)
    d = dist(p(i, :), q');
    [~, j] = min(d, [], 2);
    idx(i) = j;
end
end
%}

function idx = match_points(p, q)
n1 = size(p, 1);
n2 = size(q, 1);
idx = zeros(1, n1);
invalid = false(1, n2);
% Match without replacement
for i = 1:min(n1, n2)
    d = dist(p(i, :), q');
    d = d - max(d);
    d(invalid) = 1;
    [~, j] = min(d, [], 2);
    idx(i) = j;
    invalid(j) = true;
end
% Match leftovers with replacement
for i = n2+1:n1
    d = dist(p(i, :), q');
    [~, j] = min(d, [], 2);
    idx(i) = j;
end
end

function score = eval(A1, A2, R, t)
A3 = A1 * R' + t;
scores = vecnorm(A2 - A3, 2, 2);
score = sum(scores, 1);
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
[U, ~, VT] = svd(S);
V = VT';
detVU = det(V * U');
%disp(p)
%disp(q)
%disp('===')
%disp(V)
%disp(U')
disp(detVU)
%disp(V)
%disp(diag([ones(1, size(V, 2) - length(detVU)) detVU]))
R = V * diag([ones(1, size(V, 2) - length(detVU)) detVU]) * U';
% - compute the optimal translation
t = q_hat - p_hat * R';
end
