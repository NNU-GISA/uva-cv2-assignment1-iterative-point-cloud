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

