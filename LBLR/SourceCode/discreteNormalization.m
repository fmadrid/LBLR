function [N, c] = discreteNormalization(T,b,lowerBound)
%[N, c] = discreteNormalization - Normalizes a real-valued sequence T into a b-bit discrete value range [lowerBound, 2^b].
%   Inputs:
%       T - Column vector representing a time series. (Can include NaN values but are omitted)
%       b - Number of bits used to describe the discrete values of T. Defaults to 4
%       lowerBound - Smallest discrete value in the normalized sequence range (inclusive)
%   Outputs:
%       N - Normalized discrete value sequence in the range [lowerBound, 2^b] (Retains NaN values)
%       c - Cardinality of the normalized sequence (i.e. the number of unique values)
%% INPUT VALIDATION
% Default Value: b = 4
if nargin < 2
    b = 4;
end

% Default Value: lowerBound = 1
if nargin < 3
    lowerBound = 1;
end

if (b < 0 || mod(b,1) ~= 0)
    error('[discreteNormalization] b must be a positive integer. b = %f', b);
end

if (mod(lowerBound,1) ~= 0)
    error('[discreteNormalization] Error: lowerBound must be an integer. lowerBound = %f', lowerBound);
end

%% BEGIN
minimum = min(T);
maximum = max(T);
upperBound = 2^b;
N = round((T - minimum) / (maximum - minimum) * (upperBound - lowerBound) + lowerBound);
c = unique(N);

%% WARNINGS
if(ceil(log2(c)) < b)
    warning('[discreteNormalization] T can be expressed using a smaller number of bits. cardinality = %d, b (Current) = %d, b(Suggested)', c, b, ceil(log2(c)));
end
