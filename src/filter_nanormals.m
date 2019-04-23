function filtered_points2 = filter_nanormals(cloud, normals)

filtered_points = [];

for i = 1:length(normals)
    if isnan(normals(i))
%         disp(cloud(i,:))
        filtered_points = [cloud(i,:); filtered_points];
    end
end

filtered_points2 = [];
outliers = isoutlier(filtered_points(:,3));

for i = 1:length(filtered_points)
    if outliers(i) == 0
%         disp(cloud(i,:)
        filtered_points2 = [filtered_points(i,:); filtered_points2];
    end
end

% visualize_cloud(filtered_points2)

% outliers2 = isoutlier(cloud(:,3));

end