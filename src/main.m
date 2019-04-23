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


function A = loadA(datadir, id)
A_normal = readPcd(fullfile(datadir, id + '_normal.pcd'));
A_cloud = readPcd(fullfile(datadir, id + '.pcd'));
A = filter_nanormals(A_cloud, A_normal);
end

