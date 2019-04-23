function score = icp_eval(A1, A2, R, t)
A3 = A1 * R' + t;
scores = vecnorm(A2 - A3, 2, 2) .^ 2;
score = sum(scores, 1);
end