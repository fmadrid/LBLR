clear
clc
%% PARAMETERS

% Random Number Generation
SEED = randi(intmax);   % -1 : Default random number generation

% Sequences
PATTERNS{1} = @(x) 0.5 * sin(4 * x) + 0.5;
PATTERNS{2} = @(x) 0.5 * sin(2 * x) + 0.5;

LENGTH_MEAN = 100;  % Segment length average
LENGTH_STD  = 50;   % Segment length standard devision

SEGMENT_COUNT = 30;  % Number of seperate segments

%% INITIALIZATION

% Initialize random number generation
rng(SEED);

% Generate segment classes
Classes = randi([0,length(PATTERNS)], SEGMENT_COUNT, 1);

% Establish length of each segment
l = floor(LENGTH_STD * randn + LENGTH_MEAN);

% Generate dataset
Dataset = [];
for i = 1:SEGMENT_COUNT
    if Classes(i) == 0
        Dataset = [Dataset; rand(l,1)];
    else
        Dataset = [Dataset; PATTERNS{Classes(i)}(0:pi/(l - 1):pi)'];
    end
end

%% Plot

% Original Dataset
figure('NumberTitle', 'off', 'Name', 'Fabricated Dataset (w/Partitions)');
hold on;
plot(Dataset);

% Original Dataset
figure('NumberTitle', 'off', 'Name', 'Fabricated Dataset (w/Partitions)');
hold on;
Dataset = [[1:length(Dataset)]' Dataset];
   
for i = 1:SEGMENT_COUNT
    switch Classes(i)
        case 0
            plot(Dataset(1 + l * (i-1):l * i,1), Dataset(1 + l * (i-1):l * i,2), 'color', 'black');
        case 1
            plot(Dataset(1 + l * (i-1):l * i,1), Dataset(1 + l * (i-1):l * i,2), 'color', 'red');
        case 2
            plot(Dataset(1 + l * (i-1):l * i,1), Dataset(1 + l * (i-1):l * i,2), 'color', 'blue');
    end
end

for idx = 1:l:SEGMENT_COUNT*l
    plot([idx idx], [min(Dataset(:,2)) -  0.5, max(Dataset(:,2)) + 0.5], 'color', [0 0 0 0.1], 'linewidth', 1);
end