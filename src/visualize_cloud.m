function [fig] = visualize_cloud(cloud)
    strct = struct();
    strct.x = cloud(:, 1);
    strct.y = cloud(:, 2);
    strct.z = cloud(:, 3);
    fig = figure();
    fscatter3(strct);
end
