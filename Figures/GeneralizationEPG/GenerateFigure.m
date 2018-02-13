%% GENERATE DATASET
FILENAME        = '..\..\..\..\..\Kelly\Data\MatLab\Ara-\Whitefly - Athaliana - 0306 - Channel 4.mat';
LENGTH          = 180;
MODEL_IDX       = 138276;
SUBSEQUENCE_IDX = [138111; 140200; 151400];

Dataset = load(FILENAME);
Dataset = Dataset.DATA;

Model     = Dataset(MODEL_IDX:MODEL_IDX+LENGTH-1);
Sequences = Dataset(transpose(cell2mat(arrayfun(@(x,y) x:x+LENGTH-1, SUBSEQUENCE_IDX, 'UniformOutput', false))));
%% PLOTS
ReducedDescriptionLength(Model, Sequences, 8, 'ShowPlots', true)

clear FILENAME;
clear LENGTH;
clear MODEL_IDX;
clear SUBSEQUENCE_IDX;
