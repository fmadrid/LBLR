%% PARAMETERS
CLASSES = [0 0 1 0 2 0 0 1 1 0 0 2 2 0 1 2 0 1 2 2 2]; % Classes(0) -> Random Walk
                                                       % Classes(i) -> Patterns{i} subsequence
                                                                       
LENGTH = 100;                                            % Length of each subseqence
PATTERNS{1} = @(x) 0.5 * sin(x * (2 * pi/LENGTH)) + 0.5; % Single period of a sine graph
PATTERNS{2} = @(x) 0.5 * sin(x * (4 * pi/LENGTH)) + 0.5; % Two periods of a sine graph
NOISE_RATIO = 0.10;                                      % Effect of random noise pertubation on the dataset
COLORS = {'red', 'blue'};                                % Plot colors for the corresponding Patterns

%% INPUT VALDIATION

p = inputParser;

%% GENERATE DATASET
msg = 'Generating Dataset';
fprintf('%s - [RunMe] %s\n', datestr(now, 'HH:MM:SS'), msg);

Dataset = GenerateTimeSeries(PATTERNS, CLASSES, LENGTH);
Dataset = Dataset + (rand(numel(Dataset), 1) * NOISE_RATIO);
save('Dataset.mat', 'Dataset');

%% GENERATE PLOT
msg = 'Generating Plot';
fprintf('%s - [RunMe] %s\n', datestr(now, 'HH:MM:SS'), msg);

figure;
hold on;
xlim([0, numel(CLASSES) * LENGTH]);
ylim([min(Dataset) - 1, max(Dataset) + 1]);
plot(Dataset, 'color', 'black');

for i = 1 : numel(PATTERNS)
  arrayfun(@(x) plot(1 + (x-1) * LENGTH:x * LENGTH,Dataset(1 + (x-1) * LENGTH:x * LENGTH), 'color', COLORS{i}, 'LineWidth', 2), ...
  find(CLASSES == i));
end

savefig('Plot.fig');

%% GENERATE SOLUTION VECTOR
msg = 'Generating Solution Vector';
fprintf('%s - [RunMe] %s\n', datestr(now, 'HH:MM:SS'), msg);

Solution = zeros(numel(CLASSES) * LENGTH, 1);
for i = 1:numel(CLASSES)
  if i ~= 0
    Solution((1+(i-1)*LENGTH):(i*LENGTH)) = CLASSES(i);
  end
end

save('Solution.mat', 'Solution');

%% CLEANUP
msg = 'Cleaning up';
fprintf('%s - [RunMe] %s\n', datestr(now, 'HH:MM:SS'), msg);

clear CLASSES LENGTH PATTERNS NOISE_RATIO COLORS
clear Dataset i msg Solution