function [MDL_IDX, BitsGained] = MDL(Sequence, Hypothesis, varargin)
% [MDL_IDX, N] = MDL(Sequence, Hypothesis, ExclusionRange = numel(Hypothesis) / 2, Encoding = @HuffmanEncoding)
%     Returns a list of indices corresponding to subsequences of Sequence sorted by their reduced description length.
%
%     Inputs:
%         Sequence       - Nonempty numerical vector
%         Hypothesis     - Nonempty numerical vector with length less than the Sequence length
%         ExclusionRange - Postive integer less than half the length of the model
%         Encoding       - Function used to perform the encoding (Encoding = HuffmanEncoding)
%
%     Outputs:
%         MDL_IDX    - Indices of subsequences of sequence sorted by their reduced description length when modeled with the Hypothesis
%         BitsGained - Corresponding bits gained during the modeling process. Negative values indicate a saving of bits
%
%    License to use and modify this code is granted freely without warranty to all, as long as the original author is
%    referenced and attributed as such. The original author maintains the right to be solely associated with this work.
%
%    Programmed and Copyright by Frank Madrid: fmadr002[at]ucr[dot]edu
%    Date: 02/12/2018

%% INPUT_VALIDATION
p = inputParser;

paramName     = 'Sequence';
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'vector'});
addRequired(p, paramName, validationFcn);

paramName     = 'Hypothesis';
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'vector'});
addRequired(p, paramName, validationFcn);

paramName     = 'ExclusionRange';
defaultVal    = floor(numel(Hypothesis)/2);
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'scalar', 'integer'}, {'nonnegative'});
addOptional(p, paramName, defaultVal, validationFcn);

paramName     = 'Encoding';
defaultVal    = @HuffmanEncoding;
validationFcn = @(x) validateattributes(x, {'function_handle'}, {'nonempty'});
addOptional(p, paramName, defaultVal, validationFcn);

p.parse(Sequence, Hypothesis, varargin{:});
ExclusionRange = p.Results.ExclusionRange;

errormsg = '[MDL] Hypothesis length must be smaller than the Sequence length.';
assert(numel(Hypothesis) < numel(Sequence), errormsg);

errormsg = '[MDL] ExclusionRange must be less than half the Hypothesis length.';
assert(ExclusionRange <= numel(Hypothesis) / 2, errormsg);
Encoding = p.Results.Encoding;

%% BEGIN

% Find the more liberal ReducedDescriptionLength(Sequences, M)
differenceCost = arrayfun(@(x) numel(unique(Hypothesis - Sequence(GetRange(x,numel(Hypothesis))))) - numel(unique(Sequence(GetRange(x,numel(Hypothesis))))), 1:numel(Sequence) - numel(Hypothesis) + 1);
IDX            = find(differenceCost < 0);

% Calculate the less liberal ReducedDescriptionLength(Sequences(IDX), M)
differenceCost = arrayfun(@(x) numel(de2bi(Encoding(Hypothesis - (Sequence(GetRange(x,numel(Hypothesis))))))) - numel(de2bi(Encoding(Sequence(GetRange(x,numel(Hypothesis)))))), IDX);
IDX2 = find(differenceCost < 0);

[BitsGained,I] = sort(differenceCost(IDX2));
MDL_IDX = IDX(IDX2(I));

function R = GetRange(X,Y)
R = X:X+Y-1;
