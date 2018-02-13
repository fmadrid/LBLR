function [RDL] = ReducedDescriptionLength(Hypothesis, Sequences, varargin)
% [RDL] = ReducedDescriptionLength(Hypothesis, Sequences, Bits = 4, Encoding = @HuffmanEncoding)
%           Calculates the change in description lengths when using Hypothesis to model the columns of Sequences when encoding.
%
%       Inputs:
%           Hypothesis - Numerical column vector with length n
%           Sequence   - Numerical matrix of column vectors with n rows
%           Bits       - Number of bits used to discretize Hypothesis and Subsequences (Bits = 4)
%           Encoding   - Function used to encode M|S (Encoding = HuffmanEncoding)
%
%       Outputs:
%           DL - The reduced description lengths DL(M,S) such that DL(M,S) = DL(S) - DL(M|S)
%
%       Options:
%           'ShowPlots' - If true, outputs the following plots: Susbequences (Real-Valued),
%                         Subsequences (Discretized), Hypothesised Subsequences (Discretized). The model
%                         has a thicker line
%
%       Example:
%           Hypothesis   = rand(10,1);
%           Subsequences = rand(10,10);
%           ReducedDescriptionLength(Hypothesis, Subsequences, 'ShowPlots', true)
%
%   License to use and modify this code is granted freely without warranty to all, as long as the original author is
%   referenced and attributed as such. The original author maintains the right to be solely associated with this work.
%
%   Programmed and Copyright by Frank Madrid: fmadr002[at]ucr[dot]edu
%   Date: 02/12/2018
%% INPUT VALIDATION
p = inputParser;

paramName     = 'Hypothesis';
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'vector'});
addRequired(p, paramName, validationFcn);

paramName     = 'Sequences';
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty'});
addRequired(p, paramName, validationFcn);

paramName     = 'Bits';
defaultVal    = 4;
validationFcn = @(x) validateattributes(x, {'numeric'}, {'integer', 'positive'});
addOptional(p, paramName, defaultVal, validationFcn);

paramName     = 'Encoding';
defaultVal    = @HuffmanEncoding;
validationFcn = @(x) validateattributes(x, {'function_handle'});
addOptional(p, paramName, defaultVal, validationFcn);

paramName     = 'ShowPlots';
defaultVal    = false;
validationFcn = @(x) validateattributes(x, {'logical'}, {'scalar'});
addOptional(p, paramName, defaultVal, validationFcn);
p.parse(Hypothesis, Sequences, varargin{:});

assert(numel(Hypothesis) == size(Sequences,1), 'Hypothesis and Subsequence lengths do not match.');

%% BEGIN

% Generate Discretized and Hypothesised Datasets
Datasets = num2cell([Hypothesis Sequences],1);
DiscretizedDatasets = cellfun(@(x) Normalization(x,[1 2^Bits], 'Discrete', true), Datasets, 'UniformOutput', false);
ModelDatasets = cellfun(@(x) DiscretizedDatasets{1}-x, DiscretizedDatasets, 'UniformOutput', false);


% Calculate Reduction in cost
RDL = cellfun(@(x) numel(de2bi(Encoding(x))), DiscretizedDatasets) - cellfun(@(x) numel(de2bi(Encoding(x))), ModelDatasets);

%% SHOW PLOTS
if(ShowPlots)
    
    Colors = transpose(num2cell(rand(numel(Datasets),3),2));  % Transpose is required so that Colors and Datasets cell arrays match
    Colors{1} = [0 0 0];
    
    figure('Name','Original Plots','NumberTitle','off');
    hold on
    plots = cellfun(@(x,y) plot(x, 'color', y), Datasets, Colors);
    plots(1).LineWidth = 2;
    
    figure('Name','Discretized Plots','NumberTitle','off');
    hold on
    plots =cellfun(@(x,y) plot(x, 'color', y), DiscretizedDatasets, Colors);
    plots(1).LineWidth = 2;
    
    figure('Name','Modeled Plots','NumberTitle','off');
    hold on
    plots = cellfun(@(x,y) plot(x, 'color', y), ModelDatasets, Colors);
    plots(1).LineWidth = 2;
end