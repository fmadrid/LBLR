function [FigureHandle, Colors] = PlotSolution(Data, Solution, varargin)
% [FigureHandle] = PlotSolution(Data, Solution, Colors = {'r', 'b', 'g', 'm', 'c', 'y', 'b'})
%     Colors a data plot specified by the values of the Solution vector.
%   Inputs:
%     Data     - Nonempty numeric vector
%     Solution - Nonempty, integer vector
%     Colors   - Vector cell array of MatLab colors (i.e. [r g b a])
%
%   Outputs:
%     FigureHandle - Handle to the generated plot
%     Colors       - Colors used to draw the unique values of Solution
%
%   Options:
%     ShowPlots - If true, displays the generated plot
%
%   Example:
%     Data     = sin(-pi:0.01:pi);
%     Solution = [zeros(1, 300) + 1 zeros(1, 300) + 2 zeros(1,29) + 3];
%     PlotSolution(Data, Solution, 'ShowPlot', true);
%
%   License to use and modify this code is granted freely without warranty to all, as long as the original author is
%   referenced and attributed as such. The original author maintains the right to be solely associated with this work.
%
%   Programmed and Copyright by Frank Madrid: fmadr002[at]ucr[dot]edu
%   Date: 02/12/2018
%% INPUT VALIDATION
p = inputParser;

paramName     = 'Data';
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'vector'});
addRequired(p, paramName, validationFcn);

paramName     = 'Solution';
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'integer', 'vector'});
addRequired(p, paramName, validationFcn);

paramName     = 'Colors';
defaultValue  = {'blue', 'red', 'green', 'magenta', 'cyan', 'yellow'};
validationFcn = @(x) validateattributes(x, {'cell'}, {'vector'});
addOptional(p, paramName, defaultValue, validationFcn);

paramName     = 'ShowPlot';
defaultValue  = false;
validationFcn = @(x) validateattributes(x, {'logical'}, {'scalar', 'nonempty'});
addParameter(p, paramName, defaultValue, validationFcn);
p.parse(Data, Solution, varargin{:});
assert(numel(Data) == numel(Solution), 'Solution vector must be the same size as the dataset.');

Colors = p.Results.Colors;

%% BEGIN

Classes = unique(Solution);

% Append random colors to Colors until we have enough colors to plot each class uniquely
while numel(Colors) < numel(Classes)
  Colors(end+1) = {rand(1,3)};
end

% Generates figure, setting visible if ShowPlot is set
FigureHandle = figure('visible', 'off');
if(ShowPlot)
  set(FigureHandle, 'visible', 'on');
end

hold on;

% For each unique value in Solutions
for i = 1:numel(Classes)
  
  % Get the indices of Solution segments containing contiguous values of the current class
  IDX = SequentialSegments(find(Solution == Classes(i)));
  
  % Plot the contiguous segments adding 1 to the range to 'connect' drawn plots
  cellfun(@(x) plot(x(1):min(x(end)+1,numel(Data)), Data(x(1):min(x(end)+1,numel(Data))), 'color', Colors{i}), IDX);
end
