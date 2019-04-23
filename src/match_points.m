%{
Old function for point matching.
We now use builtin knnsearch since it is much faster for small changes.
%}

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


