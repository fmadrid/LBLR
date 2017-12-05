%% INFORMATION
% Current version of the LBLR algorithm used in the paper 'Efficient and Effective Labeling of
% Massive Time Series Archives'
%
% Usage:

%% PARAMETERS
% Random Number Generation
SEED = randi(intmax);   % -1 : Default random number generation

% Sequences
PATTERNS{1} = @(x) 0.5 * sin(4 * x * (pi/100)) + 0.5;
PATTERNS{2} = @(x) 0.5 * sin(2 * x * (pi/100)) + 0.5;

LENGTH  = 100;  % Segment length
CLASSES = [1 0 1 1 0 2 0 2 2 0 1 2 0 2 1 0 1 1 0 0 1 1 0 0 0];
%% INITIALIZATION

% Initialize random number generation
rng(SEED);

% Generate dataset
Dataset = generateTS(PATTERNS, CLASSES, LENGTH);
Dataset = Dataset + (rand(length(Dataset),1) * 0.1);
DiscreteDataset= discreteNormalization(Dataset, 8,1);

%% BEGIN
[matrixProfile, profileIndex, motifIndex, discordIndex] = interactiveMatrixProfileVer2(Dataset, LENGTH);

Hypothesis = profileIndex(1);

C = MDL(DiscreteDataset, Hypothesis,LENGTH);

%% PLOTS
% Original Dataset
figure('NumberTitle', 'off', 'Name', 'Fabricated Dataset (w/Partitions)');
hold on;
plot(Dataset);

for idx = 1:LENGTH:length(CLASSES) * LENGTH
    plot([idx idx], [min(Dataset) -  0.5, max(Dataset) + 0.5], 'color', [0 0 0 0.1], 'linewidth', 1);
end 