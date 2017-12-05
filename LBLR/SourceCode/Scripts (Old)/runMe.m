clear
clc
%% Script Properties
CARDINALITY_BITS = 4;
DATASET          = '../Datasets/Gun_Point_TRAIN';	% Dataset Format: |Classification TimeSeries|
TEST             = 3;
SAMPLES          = 20;
SEED             = 0;
OUTPUT_FILE      = 'Output.txt';

fileID = fopen(OUTPUT_FILE,'w');
rng(SEED);

fprintf(fileID, '----------------------------------------\n');
fprintf(fileID, ' Experiment Information\n');
fprintf(fileID, '----------------------------------------\n');
fprintf(fileID, 'CARDINALITY: %d bits (%d values)\n', CARDINALITY_BITS, 2 ^CARDINALITY_BITS);
fprintf(fileID, 'DATASET:     %s\n'                 , DATASET);
switch(TEST)
    case 1
        testString = 'Equivalent Classes';
    case 2
        testString = 'Differing Classes';
    case 3
        testString = 'Random Data';
end
fprintf(fileID, 'TEST:        %s\n', testString);
fprintf(fileID, 'SAMPLES:     %d\n', SAMPLES);
fprintf(fileID, 'SEED:        %d\n', SEED);
fprintf(fileID, '\n');

%% Load Dataset
fprintf(fileID, '----------------------------------------\n');
fprintf(fileID, ' Loading Datasets\n'                       );
fprintf(fileID, '----------------------------------------\n');

masterDataset = load(DATASET);

% Generate a random permutation of indices corresponding to datasets of class 1
goodIDs = find(masterDataset(:,1) == 1);
goodIDs = goodIDs(randperm(length(goodIDs)));

% Generate a random permutation of indices corresponding to datasets of class 2
badIDs = find(masterDataset(:,1) == 2);
badIDs = badIDs(randperm(length(badIDs)));

controlIndex = goodIDs(1);

fprintf(fileID, 'Time Series: %d entries\n', size(masterDataset,1));
fprintf(fileID, 'Length:      %d\n'        , size(masterDataset,2) - 1);
fprintf(fileID, 'Control ID:  %d\n'        , controlIndex);
fprintf(fileID, '\n');

switch(TEST)
    case 1
        goodCount = SAMPLES;
        badCount = 0;
        randomCount = 0;
    case 2
        goodCount = floor(SAMPLES/2);
        badCount = SAMPLES - goodCount;
        randomCount = 0;
    case 3
        goodCount = floor(SAMPLES/2);
        badCount = 0;
        randomCount = SAMPLES - goodCount;
end

sampleIndices = sort(goodIDs(2:goodCount + 1));
sampleIndices = [sampleIndices sort(badIDs(1:badCount))];

% Output the indices of the samples
fprintf(fileID, 'Sample IDs:  ');
for i = 1:length(sampleIndices)
    fprintf(fileID, '%3d ', sampleIndices(i));
end
fprintf(fileID, '\n');

% Output the classifications corresponding to the samples
fprintf(fileID, 'Classes:     ');
for i = 1:length(sampleIndices)
    fprintf(fileID, '%3d ', masterDataset(sampleIndices(i),1));
end
fprintf(fileID, '\n\n');

%% Get and Discretize Datasets
% Discretize the control and sample datasets
fprintf(fileID, '----------------------------------------\n');
fprintf(fileID, ' Get and Discretize Datasets\n'            );
fprintf(fileID, '----------------------------------------\n');

datasets = cell(1 + SAMPLES, 1); % Stores the raw datasets [control; sample_1; sample_2; ...]
datasetDiscretizations = cell(1 + SAMPLES, 1); % Stores the discrete datasets

% Get control dataset
datasets{1} = zscore(masterDataset(controlIndex, 2:end));

% Get sample datasets
fprintf(fileID, '[SYSTEM] Loading dataset: ');
for i = 1 : length(sampleIndices)
    fprintf(fileID, '%3d ', sampleIndices(i));
	datasets{1 + i} = zscore(masterDataset(sampleIndices(i), 2:end));
end
fprintf(fileID, '\n');

% Generate random datasets 
controlMax = max(datasets{1});
controlMin = min(datasets{1});
fprintf(fileID, '[SYSTEM] Generating %d randomized datasets between %d and %d\n', randomCount, controlMin, controlMax);
for i = 1:randomCount
	datasets{1 + goodCount + i} = zscore(rand(1, length(datasets{1})) * (controlMax - controlMin) + controlMin);
end

fprintf(fileID, '[SYSTEM] Discretizing datasets using %d values\n', 2^CARDINALITY_BITS);

% Discretize each dataset
for i = 1 : SAMPLES + 1
	datasetDiscretizations{i} = Discretization(datasets{i}, CARDINALITY_BITS);
end
fprintf(fileID, '\n');

%% Differences
% Calculate the differences between the control and each sample time series

fprintf(fileID, '----------------------------------------\n');
fprintf(fileID, ' Differences\n'            );
fprintf(fileID, '----------------------------------------\n');

differences = cell(SAMPLES, 1);
normalizedDifferences = cell(SAMPLES,1);
differenceTable = zeros(3, SAMPLES);

fprintf(fileID, '[SYSTEM] Calculating differences\n');
for i = 1:SAMPLES
    differenceTable(1, i) = length(unique(datasetDiscretizations{i+1,1}));
    differences{i,1} = datasetDiscretizations{1,1} - datasetDiscretizations{i+1,1};
    
end

fprintf(fileID, '[SYSTEM] Normalizing difference datasets\n');
for i = 1:SAMPLES
    tempMin = min(differences{i,1});
    normalizedDifferences{i,1} = differences{i,1} - tempMin + 1;  % Normalized to [1, ...]
    differenceTable(2, i) = length(unique(normalizedDifferences{i,1}));
end


fprintf(fileID, 'Dataset:                     ');
for i = 1:SAMPLES
    fprintf(fileID, '%3d ', i);
end
fprintf(fileID, '\n');
fprintf(fileID, 'Unique Symbols (Original):   ');
for i = 1:SAMPLES
    fprintf(fileID, '%3d ', differenceTable(1,i));
end
fprintf(fileID, '\n');
fprintf(fileID, 'Unique Symbols (Difference): ');
for i = 1:SAMPLES
    fprintf(fileID, '%3d ', differenceTable(2,i));
end
fprintf(fileID, '\n\n');

%% Encoding
% Calculate the encoding length of the time series and 'difference' time series

fprintf(fileID, '----------------------------------------\n');
fprintf(fileID, ' Encoding\n'            );
fprintf(fileID, '----------------------------------------\n');

% Calculate the encoding lengths of each discretized datazet (control + samples)
encodingLengths = zeros(1 + SAMPLES, 1);
fprintf(fileID, '[SYSTEM] Encoding discretized datasets\n');
for i = 1 : length(datasets)

    % The maximum value of the symbols to be encoded(should be 2^CARDINALITY_BITS)
    maximum = 2 ^ CARDINALITY_BITS;
    
    % Find the probability of occurrence for each symbol (i.e. integer) in the raw dataset
    probabilities = zeros(maximum,1);
    for j = 1 : maximum
        probabilities(j) = length(find(datasetDiscretizations{i,1} == j));
    end
    probabilities = probabilities / sum(probabilities);
    dict = huffmandict(1:maximum, probabilities);
    encoding = huffmanenco(datasetDiscretizations{i,1}, dict);
    
    encodingLengths(i) = length(encoding);

end

% Calculate the encoding lengths of each normalizedDifference discrete dataset
encodingLengthsDifferences = zeros(SAMPLES, 1);
fprintf(fileID, '[SYSTEM] Encoding normalized difference datasets\n');
for i = 1:SAMPLES
    maximum = max(normalizedDifferences{i,1});

    % Find the probability of occurrence for each symbol (i.e. integer) in the difference time series
    probabilities = zeros(maximum,1);
    for j = 1:maximum
        probabilities(j) = length(find(normalizedDifferences{i,1} == j));
    end
    probabilities = probabilities / sum(probabilities);
    I = find(probabilities);
    dict = huffmandict(I, probabilities(I));
    encoding = huffmanenco(normalizedDifferences{i,1}, dict);
    encodingLengthsDifferences(i) = length(encoding);

end


fprintf(fileID, 'Datasets:               ');
for i = 1:length(encodingLengths)
    fprintf(fileID, '%4d ', i-1);
end
fprintf(fileID, '\n');

fprintf(fileID, 'Encoding Length:        ');
for i = 1:length(encodingLengths)
    fprintf(fileID, '%4d ', encodingLengths(i));
end
fprintf(fileID, '\n');

fprintf(fileID, 'Encoding Length (Diff):      ');
for i = 1:length(encodingLengthsDifferences)
    fprintf(fileID, '%4d ', encodingLengthsDifferences(i));
end
fprintf(fileID, '\n');

fprintf(fileID, 'Cumulative Costs:\n');

cumulativeBaseCost = (encodingLengths(1) + encodingLengths(2)) * CARDINALITY_BITS;
for i = 2:SAMPLES+1
    cumulativeBaseCost(i) = cumulativeBaseCost(i-1) + encodingLengths(i) * CARDINALITY_BITS;
end

cumulativeEncodingCost(1) = (encodingLengthsDifferences(1) + encodingLengths(1)) * CARDINALITY_BITS;
for i = 2:SAMPLES
    cumulativeEncodingCost(i) = cumulativeEncodingCost(i-1) + encodingLengths(i) * CARDINALITY_BITS;
end


fprintf(fileID, 'Sample: ');
for i = 1:SAMPLES
    fprintf(fileID, '%6d ', i);
end
fprintf(fileID, '\n');
fprintf(fileID, 'Base:   ');
for i = 1:SAMPLES
    fprintf(fileID, '%6d ', cumulativeBaseCost(i));
end
fprintf(fileID, '\n');
fprintf(fileID, 'Diff:   ');
for i = 1:SAMPLES
    fprintf(fileID, '%6d ', cumulativeEncodingCost(i));
end
fprintf(fileID, '\n\n');

%% Plots

figure('NumberTitle', 'off', 'Name', 'Opportunity Cost');
hold on
plot(cumulativeBaseCost, 'color', 'blue', 'linewidth', 2);
plot(cumulativeEncodingCost, 'color', 'red', 'linewidth', 2);
hold off

%% Standard Plots
figure('NumberTitle', 'off', 'Name', 'Standard Plots');
hold on;

for i = 1:1
    plot(datasets{i,1}, 'color', 'blue', 'linewidth', 5);
end

for i = 2:length(datasets)
    plot(datasets{i,1}, 'color', [0 0 0 1 - i/length(datasets)], 'linewidth', 1);
end

% Encoding Lengths
figure('NumberTitle', 'off', 'Name', 'Encoding Lengths');
hold on;
plot(encodingLengths, 'color', 'blue');
plot(encodingLengthsDifferences, 'color', 'red');
hold off;

% Discretized Plots
figure('NumberTitle', 'off', 'Name', 'Discretized Plots');
hold on;
for i = 1:1
    plot(datasetDiscretizations{i,1}, 'color', 'blue', 'linewidth', 5);
end

for i = 2:length(datasets)
    plot(datasetDiscretizations{i,1}, 'color', [0 0 0 1 - i/length(datasets)], 'linewidth', 1);
end
hold off

% Difference Plots
figure('NumberTitle', 'off', 'Name', 'Difference Plots');
hold on;
for i = 1:SAMPLES
    plot(differences{i,1}, 'color', [0 0 0 (1/SAMPLES) * i], 'linewidth', 1);
end

%% Cleanup
fclose(fileID);
