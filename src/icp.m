function [R, t] = icp(varargin)
%ICP Iterative Closest Point algorithm.

A1 = reshape(1:5*3, 5, 3);
A2 = zeros(size(A1));

err = rms(A1, A2);

R = eye();
t = 0;

end

function rms = rms(A1, A2)
%RMS Calculates Root Mean Square.
% IN
%  A1 : coordinate array 1
%  A2 : coordinate array 2
% OUT
%  rms : Root Mean Square value.

% check that A1 and A2 have the same dimensions
if size(A1) ~= size(A2)
    error('Array sizes do not match.');
end

% calculate euclidian distance between vectors
diff = vecnorm(A2 - A1, 2, 2);

% calculate Root Mean Square of difference
rms = sqrt(sum(diff .^ 2) / size(A1, 1));

end
