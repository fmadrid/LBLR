function N = Normalization(T, varargin)
%N = Normalization(T, Range = [-1 1]) - Normalizes the vectors of T into a real-valued.
%       Inputs:
%           T           - Numerical column vectors
%           Range       - Numerical container of two elements
%
%       Outputs:
%           N - Normalized values (Retains NaN values)
%
%       Options:
%           Discrete - If true, rounds the normalized values to discrete values.
%
%       Example:
%           T = 1:100;
%           Range = [1,16];
%           Normalization(T, Range, 'Discrete', true); 
%
%   License to use and modify this code is granted freely without warranty to all, as long as the original author is
%   referenced and attributed as such. The original author maintains the right to be solely associated with this work.
%
%   Programmed and Copyright by Frank Madrid: fmadr002[at]ucr[dot]edu
%   Date: 02/12/2018
%% INPUT-VALIDATION
p = inputParser;

paramName     = 'T';
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty'});
addRequired(p, paramName, validationFcn);

paramName     = 'Range';
defaultVal    = [-1,1];
validationFcn = @(x) validateattributes(x, {'numeric'}, {'numel', 2, 'nondecreasing'});
addOptional(p, paramName, defaultVal, validationFcn);

paramName     = 'Discrete';
defaultVal    = false;
validationFcn = @(x)validateattributes(x, {'logical'}, {'scalar'});
addParameter(p, paramName, defaultVal, validationFcn);
p.parse(T, varargin{:});
Range = p.Results.Range;
Discrete = p.Results.Discrete;

%% BEGIN
MinValue = min(T);
MaxValue = max(T);
lowerBound = Range(1);
upperBound = Range(2);
N = (T - MinValue) / max(1, MaxValue - MinValue) * (upperBound - lowerBound) + lowerBound;

%% DISCRETE
if(Discrete)
    N = round(N);
end
