delete(findall(0,'Type','figure'))

%% INPUTS

DATASET          = 'Dataset.mat';
LENGTH           = 100;
SOLUTION         = 'Solution.mat';
EXCLUSION_RANGE  = LENGTH / 2;
BITS             = 4;
DEBUG            = false;

%% GENRATE DATA
if exist(DATASET, 'file') == 0 || exist(SOLUTION, 'file') == 0
  GenerateData;
end

Data = importdata(DATASET);
Solution = importdata(SOLUTION);

%% RUN AUTOLBLR
Labels = AutoLBLR(Data, LENGTH, Solution, 'ExclusionRange', EXCLUSION_RANGE, 'Bits', BITS, 'Debug', DEBUG, 'Blind', true);

%% GET ACCURACY
PrintAccuracy(Labels, Solution);

%% CLEANUP
clear DATASET LENGTH SOLUTION EXCLUSION_RANGE BITS DEBUG