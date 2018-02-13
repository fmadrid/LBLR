%% INFORMATION
% This script runs AutoLBLR using the specified dataset in '/Datasets' and outputs their results into '/Results'.

%% SCRIPT PARAMETERS
FOLDER  = 'EPG';
DATASET = 'EPG1';    % Specifies dataset to load
EXPERIMENT_ID = 'A';
%% AUTOLBLR PARAMETERS
LENGTH = 100;       % Matrix Profile Subsequence Length (See documentation). Suggested Length: 100
BITS   = 4;        % Discretization cardinality (Suggested Values: 4, 6, 8)
BLIND  = false;    % Indicates if solution vector is hidden to AutoLBLR (See documentation)

%% INITIALIZATION
OutputFolder = [FOLDER '/' DATASET ' - Length ' num2str(LENGTH) ' Bits ' num2str(BITS) ' - ' EXPERIMENT_ID];
mkdir(pwd, OutputFolder);
mkdir(pwd, [OutputFolder '/Plots/']);
mkdir(pwd, [OutputFolder '/Plots/AutoLBLR']);

Filename = ['../../Datasets/' FOLDER '/' DATASET '.mat'];
Data     = importdata(Filename);

fileID = fopen([OutputFolder '/Experiment Results.txt'], 'w');
fprintf(fileID, '==================================================\n');
fprintf(fileID, ' %s\n', 'AutoLBLR Experiment');
fprintf(fileID, '==================================================\n');
fprintf(fileID, 'Experiment Parameters\n');
fprintf(fileID, '\t%-7s: %s\n', 'Dataset', Filename);
fprintf(fileID, '\n');
fprintf(fileID, 'AutoLBLR Parameters\n');
fprintf(fileID, '\t%-7s: %d\n', 'Length', LENGTH);
fprintf(fileID, '\t%-7s: %d\n', 'Bits',   BITS);
fprintf(fileID, '\t%-7s: %d\n', 'Blind',  BLIND);
fprintf(fileID, '\n');

%% RUN AUTOLBLR
TimeSeries = Data(:,1);
Solution   = Data(:,2);
tic
[Labels, PlotHandles, Completion] = AutoLBLR(TimeSeries, LENGTH, Solution, 'Bits', BITS, 'Blind', BLIND, 'Debug', true);
ElapsedTimeAutoLBLR = toc;

save([OutputFolder '/Labels.mat'], 'Labels');
save([OutputFolder '/Completion.mat'], 'Completion');
copyfile('AutoLBLR - Logfile.txt', OutputFolder);
try delete('AutoLBLR - Logfile.txt', OutputFolder);
catch ME
end
    

%% OUTPUT RESULTS
fprintf(fileID, '==================================================\n');
fprintf(fileID, ' %s\n', 'Results');
fprintf(fileID, '==================================================\n');
fprintf(fileID, '%-17s: %d\n',            'Iterations',       numel(Completion));
fprintf(fileID, '%-17s: %0.2f seconds\n', 'Elapsed Time',     ElapsedTimeAutoLBLR);
fprintf(fileID, '%-17s: %0.2f\n',         'Classified',       sum(Labels ~= 0) / numel(Labels) * 100);
fprintf(fileID, '%-17s: %0.2f\n',         'Overall Accuracy', sum(Labels == Solution) / numel(Solution) * 100);
fprintf(fileID, '%-17s: %0.2f\n',         'Default Accuracy', sum(mode(Solution) == Solution) / numel(Solution) * 100);

diary off;

%% GENERATE PLOTS
str = 'AutoLBLR Accuracy';
f = figure('name', str, 'NumberTitle', 'off', 'visible', 'off');
hold on
xlim([1, numel(Data(:,1))]);
plot(TimeSeries, 'color', 'black');
stairs(Labels, 'color', 'Blue');
stairs(Solution, 'color', 'Red');
stairs(Solution == Labels, 'color', 'magenta');
legend('TimeSeries', 'Experimental Labels', 'Solution Labels', 'Difference Vector');
saveas(f, [OutputFolder '/Plots/Accuracy.fig']);
close(f);

str = 'AutoLBLR Completion Iterations';
f = figure('name', str, 'NumberTitle', 'off', 'visible', 'off');
hold on
xlim([1, numel(0:numel(TimeSeries)/LENGTH)]);
plot(1:numel(TimeSeries)/LENGTH+1, fliplr(0:LENGTH/numel(TimeSeries):1), 'color', 'black');
stairs(1:numel(Completion), 1 - Completion, 'color', 'blue');
legend('Human Baseline', 'AutoLBLR')
xlabel('Iterations');
ylabel('Label Percentage');
saveas(f, [OutputFolder '/Plots/CompletionIterations.fig']);
close(f);

for i = 1 : numel(PlotHandles)
  str = [OutputFolder '/Plots/AutoLBLR/' get(PlotHandles(i), 'name') '.fig'];
  saveas(PlotHandles(i), str);
  close(PlotHandles(i));
end

%% CLEANUP
fclose(fileID);
clear DATASET ID LENGTH BITS BLIND OutputFolder Filename Data TimeSeries Solution ElapsedTimeAutoLBLR Labels PlotHandles Completion i str f fileID EXPERIMENT_ID
