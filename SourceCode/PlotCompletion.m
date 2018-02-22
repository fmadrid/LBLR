function [FigureHandle] = PlotCompletion(TimeSeries, SubsequenceLength, CompletionPercentages, varargin)

p = inputParser;

paramName     = 'TimeSeries';
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty'});
addRequired(p, paramName, validationFcn);

paramName     = 'SubsequenceLength';
validationFcn = @(x)validateattributes(x, {'numeric'}, {'scalar', 'positive'});
addRequired(p, paramName, validationFcn);

paramName     = 'CompletionPercentages';
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty'});
addRequired(p, paramName, validationFcn);

paramName     = 'Filename';
defaultVal    = '';
validationFcn = @(x) validateattributes(x, {'char'}, {'nonempty'});
addParameter(p, paramName, defaultVal, validationFcn);

p.parse(TimeSeries, SubsequenceLength, CompletionPercentages, varargin{:});

Y = 1 - CompletionPercentages;
Y = [1 Y];
Ratio = SubsequenceLength / numel(TimeSeries);
X = 0.0:Ratio:1.0;
X = X(1:numel(Y));

X2 = [X(end) X(end) + 1];
Y2 = [Y(end) Y(end) - 1];

FigureHandle = figure;
hold on;
xlim([0 1]);
xticks([0.0 0.25 0.50 0.75 1.0])
xticklabels({'0.0', '0.25', '0.50', '0.75', '1.0'})
get(gca, 'XTick');
set(gca, 'FontSize', 14)
ylim([0 1]);
yticks([0.0 0.25 0.50 0.75 1.0])
yticklabels({'0.0', '0.25', '0.50', '0.75', '1.0'})
get(gca, 'YTick');
set(gca, 'FontSize', 14)
xlabel('Fraction of Effort (relative to labeling snippets individually)', 'FontSize', 14);
ylabel('Fraction of Unlabeled Data', 'Fontsize', 14);
stairs(X,Y, 'color', 'b', 'LineWidth', 1);
plot(X2, Y2, 'color', 'k', 'LineStyle', '--');

if(~isempty(p.Results.Filename))
  legend(p.Results.Filename);
end