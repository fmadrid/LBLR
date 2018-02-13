function [TimeSeries, FigureHandle] = GenerateTimeSeries(Patterns, varargin)
%    TimeSeries = GenerateTimeSeries(Patterns, Classes = randi([1, |Patterns|],10,1), Length = 100)
%        Generates a time series of embedded patterns with the specified length.
%    Inputs:
%        Patterns - Cell array of anonymous functions with singular input and output
%        Classes  - Discrete valued vector whose elements correspond to indices of Patterns
%        Length   - Length of embedded patterns
%    Outputs:
%        TimeSeries - Time series of length |Classes| * Len.
%    Options:
%        ShowPlot - If true, displays a plot of the generated time series.
%
%   License to use and modify this code is granted freely without warranty to all, as long as the original author is
%   referenced and attributed as such. The original author maintains the right to be solely associated with this work.
%
%   Programmed and Copyright by Frank Madrid: fmadr002[at]ucr[dot]edu
%   Date: 02/12/2018

%% INPUT-VALIDATION
p = inputParse;

paramName     = 'Patterns';
validationFcn = @(x) validateattributes(x, {'cell'}, {'nonempty'}) & all(cellfun(@(y) validateattributes(y, {'function_handle'}),x));
addRequired(p, paramName, validationFcn);

paramName     = 'Classes';
defaultVal    = randi([1, numel(Patterns)],10,1);
validationFcn = @(x)validateattributes(x, {'numeric'}, {'numel', 2});
addOptional(p, paramName, defaultVal, validationFcn);

paramName     = 'Length';
defaultVal    = 100;
validationFcn = @(x)validateattributes(x, {'numeric'}, {'scalar', 'postiive'});
addOptional(p, paramName, defaultVal, validationFcn);

paramName     = 'ShowPlots';
defaultVal    = false;
validationFcn = @(x)validateattributes(x, {'logical'}, {'false'});
addParameter(p, paramName, defaultVal, validationFcn);

p.parse(Length, varargin{:});

errormsg = sprintf('[GenerateTimeSeries] Classes elements must correspond with the indices of Patterns or 0. Classes = %s', mat2str(Classes));
assert(all(ismember(Classes, [1, numel(Patterns)])), errormsg);

%% BEGIN
TimeSeries = arrayfun(@(x) Patterns{Classes(x)}(transpose(1:Length)), 1:numel(Classes));

FigureHandle = [];
if(ShowPlot)
  FigureHandle = figure;
  plot(TimeSeries);
end


