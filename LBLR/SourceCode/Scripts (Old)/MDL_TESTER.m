%% PARAMETERS
SEGMENTS = [8 7 6 5 4 3 2];
CLASS    = [1 0 2 0 1 0 2];

LENGTH           = 100;
VERTICAL_NOISE   = 0.0;
HORIZONTAL_NOISE = 0.0;
PERIOD_NOISE     = 10.0;
SEED             = 10;
CARDINALITY_BITS = 4;

PATTERNS = cell(3,1);

%% INITIALIZATION
rng(SEED);
OUTPUT_FILE = 'MDL Tester Output.txt';

outputFile = fopen(OUTPUT_FILE, 'w');

fprintf(outputFile, '----------------------------------------\n');
fprintf(outputFile, ' MDL TESTER Experiment Information\n');
fprintf(outputFile, '----------------------------------------\n');
fprintf(outputFile, 'Date-Time:   %s\n', datestr(datetime('now')));
fprintf(outputFile, 'Segments:    %s\n', mat2str(SEGMENTS));
fprintf(outputFile, 'CLASS:       %s\n', mat2str(CLASS));
fprintf(outputFile, 'LENGTH:      %d\n', LENGTH);
fprintf(outputFile, 'NOISE_DIFF:  %d\n', VERTICAL_NOISE);
fprintf(outputFile, 'CARDINALITY: %d bits (%d values)\n', CARDINALITY_BITS, 2 ^CARDINALITY_BITS);
fprintf(outputFile, 'SEED:        %d \n', SEED);

fprintf(outputFile, '\n');

% Generate curve A (class 1)
PATTERNS{1} = sin(0 : pi/(LENGTH - 1) : pi)'; % Half a period of pi

% Generate curve B (class 2)
PATTERNS{2} = (0.5*sin(0 : 2*pi/(LENGTH - 1) : 2*pi) + 0.5)'; % Full period of pi

%% DATASET GENERATION

Dataset = [];
for i = 1 : length(SEGMENTS)
    for j = 1 : SEGMENTS(i)
        if CLASS(i) == 0
            Dataset = [Dataset; rand(LENGTH, 1) * (1+VERTICAL_NOISE - 0)];
        elseif CLASS(i) == 1
            Dataset = [Dataset; sin(0 : pi/(LENGTH - 1 + rand * PERIOD_NOISE) : pi)'];
        elseif CLASS(i) == 2
            Dataset = [Dataset; (0.5*sin(0 : 2*pi/(LENGTH - 1) : 2*pi) + 0.5)'];
        end
    end
end

Points = [1:length(Dataset)]';
Points = Points + rand(length(Dataset),1) * HORIZONTAL_NOISE;

Points = [Points Dataset];

%% Run MDL
diffMatrix = MDL(Dataset, LENGTH, CARDINALITY_BITS);

%% SEGMENT SIMILARITY

fprintf(outputFile, '----------------------------------------\n');
fprintf(outputFile, ' Segment Similarity\n');
fprintf(outputFile, '----------------------------------------\n');

% Create class list (i.e. [1 1 1 1 1 0 0 0 0 2 2 2 0 0 1])
classList = [];
for i = 1:length(CLASS)
    classList = [classList; zeros(SEGMENTS(i), 1) + CLASS(i)];
end

% Sort each row of the diffMatrix but remember the index positions
diffTracker = [];
similarity = [];
for i = 1:length(diffMatrix)
    [Values, I] = sort(diffMatrix(i,:));
    diffTracker = [diffTracker; Values];
    similarity = [similarity; I];
end

cumDiffTracker = cumsum(diffTracker,2);

classLabels = [(1:sum(SEGMENTS))' classList(similarity)];
I = find(classList);
cumDiffTracker = cumDiffTracker(I, 2:end);
classLabels = classLabels(I, :);

correct = 0;
total = 0;
for i = 1 : size(classLabels,1)
    class = classList(classLabels(i,1));
    sz = size(find(classList == class),1);
    correct = correct + sum(classLabels(i, 2:sz + 1) == (ones(1, sz) * class));
    total = total + sz;
end

accuracy = correct / total;
fprintf(outputFile, 'Accuracy: %f\n', accuracy); 
%X = [X;NOISE_DIFF accuracy];
fclose(outputFile);

%% PLOT
figure('NumberTitle', 'off', 'Name', 'Fabricated Dataset (w/Partitions)');
hold on;
plot(Points(:,1),Points(:,2));
ylim([min(Dataset) - 1, max(Dataset) + 1]);
for idx = LENGTH : LENGTH : length(Dataset) - 1
    plot([idx idx], [min(Dataset) -  0.5, max(Dataset) + 0.5], 'color', [0 0 0 0.1], 'linewidth', 1);
end
hold off;

ID = 1;
title = sprintf('Segment [%d] Similarities', ID);
figure('NumberTitle', 'off', 'Name', title);
hold on;
plot(Dataset(1 + LENGTH * (ID - 1) : LENGTH * ID), 'color', 'blue', 'linewidth', 5);

class = classList(ID);
sz = size(find(classList == class),1);
UB = sz;
for i = 2:UB
    segID = similarity(ID, i);
    plot(Dataset(1 + LENGTH * (segID - 1) : LENGTH * segID), 'color', [0 + i / (UB + 1) 0 + i / (UB + 1) 0 + i / (UB + 1) 1 - i / (UB+100)], 'linewidth', 1);
end
hold off;