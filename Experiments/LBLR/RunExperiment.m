%% INFORMATION
% This script runs LBLR using the specified dataset in '/Datasets' 

Filename = '
Data     = importdata(Filename);

Dataset   = Data(:,1);
Solutions = Data(:,2);
save('TimeSeriesData.mat', 'Dataset');
save('Solutions.mat', 'Solutions');

LBLR;

PlotSolution(Dataset, Solutions);
set(gcf, 'visible', 'on');

openfig('TimeSeriesDataPlot.fig');
set(gcf, 'visible', 'on');

%% CLEANUP
clear FOLDER DATASET