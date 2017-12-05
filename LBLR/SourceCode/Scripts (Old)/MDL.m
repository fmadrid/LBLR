function [differenceMatrix] = MDL(DATASET, LENGTH, CARDINALITY_BITS)
% Summary of this function goes here
%   Detailed explanation goes here

%% INPUT VALIDATION
if CARDINALITY_BITS <= 0
    error('[CRITICAL ERROR] CARDINALITY_BITS must be a positive number');
end

if LENGTH <= 0
   error('[CRITICAL ERROR] LENGTH must be a positive number'); 
end

if nargin == 2
    CARDINALITY_BITS = 4;
elseif nargin < 2
    error('[USAGE] MDL(dataSet, length, cardinalityBits = 4');
end

%% INITIALIZATION
segmentCount = length(DATASET) / LENGTH;
if rem(segmentCount,1) ~= 0 || segmentCount <= 0
    error('[CRITICAL ERROR] length(DATASET) [%d] / LENGTH [%d] should result in a positive integer.', length(DATASET), LENGTH);
end

%% DATASET DISCRETIZATION
discreteDataset = discreteNormalization(DATASET, CARDINALITY_BITS);

%% CALCULATE DIFFERENCE MATRIX (BRUTE FORCE)
differenceMatrix = zeros(segmentCount);

% For each segment of length LENGTH in the discretized dataset
for i = 1 : segmentCount
    %fprintf('Index: [%d,%d]', LENGTH * (i - 1) + 1, LENGTH * i);
    segA = discreteDataset(LENGTH * (i - 1) + 1 : LENGTH * i);
    
    for j = i+1 : segmentCount
        if i == j
            continue;
        end
        
        segB = discreteDataset(LENGTH * (j - 1) + 1 : LENGTH * j);
        differenceMatrix(i,j) = length(unique(E));
    end
        
end

differenceMatrix = differenceMatrix + transpose(differenceMatrix);

