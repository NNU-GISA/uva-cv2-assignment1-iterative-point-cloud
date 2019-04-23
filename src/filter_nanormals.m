function [filtered_points2, filtered_normals2] = filter_nanormals(cloud, normals)



nonNans = ~isnan(normals(:,1));
filtered_points = cloud(nonNans,:);
filtered_normals = normals(nonNans,:);

outliers = filtered_points(:,3) < 1;
filtered_points2 = filtered_points(outliers,:);
filtered_normals2 = filtered_normals(outliers,:);

% x = filtered_points2(:,1);
% y = filtered_points2(:,2);
% z = filtered_points2(:,3);
% u = filtered_normals2(:,1);
% v = filtered_normals2(:,2);
% w = filtered_normals2(:,3);
% 
% quiver3(x,y,z,u,v,w)

% visualize_cloud(filtered_points2)


end