%% GENERATE DATASET

CLASSES = [0 1 0 1 0 1 0 1 0 1 0];                          % Classes(0) -> Random Walk
                                                            % Classes(i) -> Patterns{i} subsequence
LENGTH = 100;                                               % Length of each subseqence
PATTERNS{1} = @(x) 0.5 * sin(x * (2 * pi/LENGTH)) + 0.5;    % Single period of a sine graph
NOISE_RATIO = 0.10;                                         % Effect of random noise pertubation on the dataset

Dataset = generateTS(PATTERNS, CLASSES, LENGTH);
Dataset = Dataset + rand(numel(Dataset), 1) * NOISE_RATIO;

%% PLOT

% Generate Main Plot
MainPlot = figure;
plot(Dataset, 'color', 'black')
hold on
ylim([min(Dataset) - 0.5, max(Dataset) + 0.5]);

% Highlight Patterns
for i = 1:numel(CLASSES)
    if CLASSES(i) == 0
        continue;
    end
    
    Range = 1 + LENGTH * (i-1) : i * LENGTH;
    plot(Range, Dataset(Range), 'color', 'blue', 'LineWidth', 2); 
end
hold off;
savefig('MainPlot');

%Generate Overplot Plot
OverPlot = figure;
hold on;
for i = 1:numel(CLASSES)
    if CLASSES(i)== 0
        continue;
    end
    
    Range = 1 + LENGTH * (i-1) : i * LENGTH;
    plot(Dataset(Range), 'color', 'black', 'LineWidth', 2);
    
end
hold off;

save('Dataset');
savefig('OverPlot');

clear PATTERNS;
clear CLASSES;
clear LENGTH;
clear NOISE_RATIO;
clear Dataset;
