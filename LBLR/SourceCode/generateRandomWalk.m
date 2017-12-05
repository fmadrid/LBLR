function [DATASET] = generateRandomWalk(length,lowerBound, upperBound)
%generateRandomWalk Generates a random walk within the range [lowerBound, upperBound]
%   Inputs:
%       length -
%       lowerBound - 
%       upperBound -
%   Outputs:
%       DATASET - 
%% INPUT VALIDATION
if nargin < 2 
    lowerBound = -1; 
end
if nargin < 3 
    upperBound =  1; 
end

assert(length > 0 && mod(length,1) == 0, '[generateRandomWalk] Error: length must be a positive integer. length = %f', length);
assert(lowerBound < upperBound, '[generateRandomWalk] Error: minimum must be greater than maximum. minimum = %f maximum = %f', lowerBound, upperBound);
%% BEGIN
RandomWalk = zeros(length, 1);
RandomWalk(1) = randn();
for i = 2 : length
    RandomWalk(i) = RandomWalk(i-1) + randn();
end
DATASET = (RandomWalk - min(RandomWalk)) / (max(RandomWalk) - min(RandomWalk)) * (upperBound - lowerBound) + lowerBound;
