function [fig] = visualize_cloud(cloud)
    strct = struct();
    strct.x = cloud(:, 1);
    strct.y = cloud(:, 2);
    strct.z = cloud(:, 3);
    if size(cloud, 2) >= 4
        strct.int = cloud(:, 4);
    end
    fig = figure();
    fscatter3(strct);
end
