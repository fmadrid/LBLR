function l = descriptionLength(T)
%l = descriptionLength - Calculates the number of bits required to represent a time series.
%   Inputs:
%       T - Sequence of discrete values.
%   Outputs:
%       l - The description length of T (|T| * #bits required to uniquely express each element)
%% INPUT VALIDATION

if nargin < 1
    error('[descriptionLength] Usage: descriptionLength(sequence)');
end

%% BEGIN

% Calculate the length of T
n = length(T);

% Calculate the cardinality of T (i.e. the number of unique elements)
c = length(unique(T));

l = n * ceil(log2(c));

%l = length(huffmanEncoding(T));