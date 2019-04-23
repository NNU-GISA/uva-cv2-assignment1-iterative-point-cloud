function A = loadA(datadir, id)
% loadA: small function to help load and filter pcm data
%  datadir : path to directory with pcm data
%  id : id (string/charArray) of pcm data to load
A_normal = readPcd(fullfile(datadir, id + '_normal.pcd'));
A_cloud = readPcd(fullfile(datadir, id + '.pcd'));
A = filter_nanormals(A_cloud, A_normal);
end