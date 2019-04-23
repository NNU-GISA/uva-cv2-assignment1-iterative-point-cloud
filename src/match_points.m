function idx = match_points(p, q)
idx = zeros(1, size(p, 1));
% determine closest point in q per point in p
% (1 at a time to avoid memory errors)
for i = 1:size(p, 1)
    d = dist(p(i, :), q');
    [~, j] = min(d, [], 2);
    idx(i) = j;
end
end

%% TODO see if this is not a better match_points function
% idx = knnsearch(X, Y)