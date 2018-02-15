function [T] = GenerateRandomWalk(Length, varargin)
%T = GenerateRandomWalk(Length, Range = [-1,1])
%        Generates a random walk within the specified range
%    Inputs:
%        Length  - Length of the normalized sequence. Must be a positive, scalar integer.
%        Range   - Range of the real values (inclusive). Must be a numerical vector with two elements.
%    Outputs:
%        Dataset - Normalized real-valeud column vector in the specified range (inclusive).
%
%    License to use and modify this code is granted freely without warranty to all, as long as the original author is
%    referenced and attributed as such. The original author maintains the right to be solely associated with this work.
%
%    Programmed and Copyright by Frank Madrid: fmadr002[at]ucr[dot]edu
%    Date: 02/12/2018

%% INPUT VALIDATION
p = inputParser;

paramName     = 'Length';
validationFcn = @(x) validateattributes(x, {'numeric'}, {'integer', 'scalar', 'positive'});
addRequired(p, paramName, validationFcn);

paramName     = 'Range';
defaultVal    = [-1,1];
validationFcn = @(x)validateattributes(x, {'numeric'}, {'numel', 2});
addOptional(p, paramName, defaultVal, validationFcn);

p.parse(Length, varargin{:});
INPUTS = p.Results;

assert(Range(1) <= Range(2), '[GenerateRandomWalk] Range must specify a valid interval. Range = %s', mat2str(Range));

%% BEGIN
RandomWalk = zeros(INPUTS.Length, 1);
RandomWalk(1) = randn();
for i = 2 : INPUTS.Length
    RandomWalk(i) = RandomWalk(i-1) + randn();
end

T = Normalization(RandomWalk, INPUTS.Range);
