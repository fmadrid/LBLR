function [DATASET] = generateTS(Patterns, Classes, len)
%% INPUT VALIDATION
%l = generateTS - Creates a time series using the supplied patterns.
%   Inputs:
%       PATTERNS - 
%       Classes
%   Outputs:
%       l - The description length of T (|T| * #bits required to uniquely express each element)
%% GENERATE DATASET
DATASET = [];
for i = 1:length(Classes)
    if Classes(i) == 0
        DATASET = [DATASET; generateRandomWalk(len, 0, 1)];
    else
        DATASET = [DATASET; Patterns{Classes(i)}([0:len-1]')];
    end
end
