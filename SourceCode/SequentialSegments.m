function [C] = SequentialSegments(A)
% C = SequentialSegments(A)
%    Splits a vector into a cell array of monotically increasing consecutive column vectors.
%    Inputs:
%        A   - Integer vector
%    Outputs:
%        N - Cell array whose elements are monotonic increasing consecutive vectors
%    Example
%        splitVector([5 2 3 5 6 8 10 2 3 3 4 4]) -> {[5], [2; 3], [5; 6], [8], [10], [2; 3], [3; 4] [4]}
%
%    License to use and modify this code is granted freely without warranty to all, as long as the original author is
%    referenced and attributed as such. The original author maintains the right to be solely associated with this work.
%
%    Programmed and Copyright by Frank Madrid: fmadr002[at]ucr[dot]edu
%    Date: 02/12/2018

%% INPUT VALIDATION
p = inputParser;

paramName     = 'A';
validationFcn = @(x) validateattributes(x, {'numeric'}, {'integer', 'vector'});
addRequired(p, paramName, validationFcn);

p.parse(A);

%% BEGIN
C = {};
if(isempty(A))
    return
end

% Finds the indices of each element who is not one less than its right neighbor
EndPoints = find(diff(A) ~= 1);

% Add A(end) manually since diff(A(end)) is not defined
EndPoints(end + 1) = length(A);

startPoint = 1;
C = cell(length(EndPoints), 1);
for i = 1 : numel(EndPoints)
    C{i} = A(startPoint:EndPoints(i));
    startPoint = EndPoints(i) + 1;  % Begin the next sequence at one index past the end point
end
