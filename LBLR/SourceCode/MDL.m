function [C] = MDL(Dataset,HypothesisIndex, queryLength)
%MDL Summary of this function goes here
%   Detailed explanation goes here

%% INITIALIZATION
segH = Dataset(HypothesisIndex:HypothesisIndex + queryLength - 1);

%% BEGIN
segmentCount = length(Dataset) / queryLength;
differenceArray = zeros(segmentCount,1);

% For each segment of length LENGTH in the discretized dataset
for i = 1 : segmentCount
    i
    segB = Dataset(queryLength * (i - 1) + 1 : queryLength * i)
    differenceArray(i) = length(unique(segH-segB));
end
        differenceArray
[C,I] = sort(differenceArray);
original = [];
for i = 1: length(I)
    segmentID = I(i);
    original = [original ;length(unique(Dataset(queryLength * (segmentID - 1) + 1 : queryLength * segmentID)))];
end
figure
plot(segH)

figure
hold on
plot(original - C);
hold off
