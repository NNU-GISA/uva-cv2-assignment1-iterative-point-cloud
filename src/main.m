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

step=2;

A1 = loadA(datadir, ids(1));
% len(data) is currently number of steps in loop
%data = cell(0, fix(length(ids)/step) - int(~logical(mod(length(ids), step))));
data = [A1(1:50:end, :)];

for i = 1+step:step:length(ids)
    A2 = loadA(datadir, ids(i));
    [R, t] = icp(A1, A2, 0.001, 'uniform-each', 1000);
    data = [data * R' + t ; A2(1:50:end, :)];
%    data{fix(i/step)} = ;
    A1 = data;  % difference between 3.1 and 3.2 is putting A2 or data here
    disp(i)
end
visualize_cloud(data);


function A = loadA(datadir, id)
A_normal = readPcd(fullfile(datadir, id + '_normal.pcd'));
A_cloud = readPcd(fullfile(datadir, id + '.pcd'));
A = filter_nanormals(A_cloud, A_normal);
end

A1_normal = readPcd(fullfile(datadir, ids(2) + '_normal.pcd'));
A1_cloud =  readPcd(fullfile(datadir, ids(2) + '.pcd'));
A2_normal = readPcd(fullfile(datadir, ids(3) + '_normal.pcd'));
A2_cloud =  readPcd(fullfile(datadir, ids(3) + '.pcd'));
A1 = filter_nanormals(A1_cloud, A1_normal);
A2 = filter_nanormals(A2_cloud, A2_normal);

A1_cam = xmlread(fullfile(datadir, ids(2) + '_camera.xml'));
A1_mat = load(fullfile(datadir, ids(2) + '.mat'));
root = A1_mat.getDocumentElement();
A1_intrinsic = root.getAttribute('intrinsic').getAttribute('data');
A1_R =         root.getAttribute('R')        .getAttribute('data');
A1_t =         root.getAttribute('t')        .getAttribute('data');

[R, t] = icp(A1, A2, 0.001, 'uniform', 400);

for i = 0:99
    Ai_normal = readPcd(fullfile(datadir, ids(i) + '_normal.pcd'));
    Ai =        readPcd(fullfile(datadir, ids(i) +        '.pcd'));
    Filter_Ai = filter_nanormals(Ai, Ai_normal);
    if prev_A
        [R, t] = icp(prev_A, Filter_Ai, 0.001, 'uniform', 400);
    end
    prev_A = Filter_Ai;
end
% Run ICP


[~, vocabulary] = kmeans(double(D'), vocabulary_size, 'display', 'off', 'replicates', 1, 'maxiter', 100);
bow_path = strcat(folder, 'bow.mat');
BoW = [];
for i = 1:size(I_BoW, 2)
    BoW_ = get_BoW(I_BoW{i}, vocabulary, sampling_method, sift_descriptor, descriptor_type);
    BoW = cat(1, BoW, BoW_);
end


