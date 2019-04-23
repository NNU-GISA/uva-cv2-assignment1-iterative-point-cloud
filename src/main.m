clear
clc
close all

%% Setup
resdir = setup();
datadir = fullfile(resdir, 'data');

%% Get data ids
files = dir(fullfile(datadir, '*.mat'));
ids = strings(length(files), 1);
for i=1:length(files)
    [~, id, ~] = fileparts(files(i).name);
    ids(i) = id;
end

%% TODO: loop over ids
A1_normal = readPcd(fullfile(datadir, ids(1) + '_normal.pcd'));
A1_cloud = readPcd(fullfile(datadir, ids(1) + '.pcd'));
A2_normal = readPcd(fullfile(datadir, ids(11) + '_normal.pcd'));
A2_cloud = readPcd(fullfile(datadir, ids(11) + '.pcd'));

A1 = filter_nanormals(A1_cloud, A1_normal);
A2 = filter_nanormals(A2_cloud, A2_normal);
% for i = 1:100
%     A1_normal = readPcd(fullfile(datadir, ids(i) + '_normal.pcd'));
%     A1 = readPcd(fullfile(datadir, ids(i) + '.pcd'));
%     Filter_A1 = filter_nanormals(A1, A1_normal);
% end


%% Run ICP
%[R, t] = icp(A1, A2);




%%
%A3 = [A1 * R' + t; A2];
%visualize_cloud(A3);

%%

frame_step = 4;
point_step = 1;

start = 1;

max_iter = 250;
score_cutoff = 5;

A1 = loadA(datadir, ids(start));
data = [A1(1:point_step:end, :)];
% len(data) is currently number of steps in loop
%data = cell(0, fix(length(ids)/step) - int(~logical(mod(length(ids), step))));

for i = start+frame_step:frame_step:length(ids)%start - 1 + frame_step * 5%length(ids)
    A2 = loadA(datadir, ids(i));
    weights = ones(1, size(A1, 1));
    [R, t, scoreArray] = icp(A1, A2, 0.001, 'uniform-each', 5000, weights, max_iter);
%    if scoreArray(end) < score_cutoff
    data = [data * R' + t ; A2(1:point_step:end, :)];
    % data{fix(i/step)} = ;
    A1 = A2;  % difference between 3.1 and 3.2 is putting A2 or data here
%    end
    disp(i)
end

visualize_cloud(data);








%%
A1_normal = readPcd(fullfile(datadir, ids(2) + '_normal.pcd'));
A1_cloud =  readPcd(fullfile(datadir, ids(2) + '.pcd'));
A2_normal = readPcd(fullfile(datadir, ids(3) + '_normal.pcd'));
A2_cloud =  readPcd(fullfile(datadir, ids(3) + '.pcd'));
[A1, A1n] = filter_nanormals(A1_cloud, A1_normal);
[A2, A2n] = filter_nanormals(A2_cloud, A2_normal);

% % xml crap: never mind this!
% A1_cam = xmlread(fullfile(datadir, ids(2) + '_camera.xml'));
% A1_mat = load(fullfile(datadir, ids(2) + '.mat'));
% root = A1_mat.getDocumentElement();
% A1_intrinsic = root.getAttribute('intrinsic').getAttribute('data');
% A1_R =         root.getAttribute('R')        .getAttribute('data');
% A1_t =         root.getAttribute('t')        .getAttribute('data');

[R, t] = icp(A1, A2, 0.001, 'uniform', 400);

Ais = [];
Ains = [];
for i = 1:00
    Ai_normal = readPcd(fullfile(datadir, ids(i) + '_normal.pcd'));
    Ai =        readPcd(fullfile(datadir, ids(i) +        '.pcd'));
    % Filter_Ai = filter_nanormals(Ai, Ai_normal);
    [Ai_, Ain_] = filter_nanormals(Ai, A1_normal);
    Ais(:,:,i) = Ai_;
    Ains(:,:,i) = Ain_;
    % if prev_A
    %     [R(:,:,i), t(:,i)] = icp(prev_A, Filter_Ai, 0.001, 'uniform', 400);
    % end
    % prev_A = Filter_Ai;
end
% Run ICP


% normalize over totals
totals = sum(BoW, 1);
normalized = BoW ./ totals;
weights = sum(normalized, 2);


% generate normals vocabulary
vocabulary_size = 10;
[~, vocabulary] = kmeans(double(A1n), vocabulary_size, 'display', 'off', 'replicates', 1, 'maxiter', 100);
% create BoW histograms
BoW = [];
for i = 1:100
    Ai_normal = readPcd(fullfile(datadir, ids(i) + '_normal.pcd'));
    Ai =        readPcd(fullfile(datadir, ids(i) +        '.pcd'));
    [Ai_, Ain_] = filter_nanormals(Ai, Ai_normal);
    BoW_ = get_BoW(Ain_, vocabulary);
    BoW = cat(1, BoW, BoW_);
end

function [sample_weights] = get_weights(datadir, id)
% point selection by sub-sampling more from informative regions based on infrequent normals
% build vocab
vocabulary_size = 10;
[~, vocabulary] = kmeans(double(A1n), vocabulary_size, 'display', 'off', 'replicates', 1, 'maxiter', 100);
A_normal = readPcd(fullfile(datadir, id + '_normal.pcd'));
A =        readPcd(fullfile(datadir, id +       '.pcd'));
[A_, An_] = filter_nanormals(A, A_normal);
% BoW features
BoW_ = get_BoW(An_, vocabulary);
% normalize to penalize points with common features
totals = sum(BoW, 1);
normalized = BoW ./ totals;
sample_weights = sum(normalized, 2);
% calculate ICP using our new-found weighting
[R, t, scoreArray] = icp(A1, A2, 0.001, 'uniform', 400, sample_weights, 100);
% visualize original point cloud
f1 = visualize_cloud(A_);
saveas(f1, 'before-sampling.png');
% visualize our evidently improved rotated/translated one
A__ = A_ * R + t;
f2 = visualize_cloud(A__);
saveas(f2, 'interest-sampling.png');
end



%%

