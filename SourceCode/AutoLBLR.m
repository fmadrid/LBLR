function [Labels, PlotHandles, Progress] = AutoLBLR(Data, Length, Solution, varargin)

%   License to use and modify this code is granted freely without warranty to all, as long as the original author is
%   referenced and attributed as such. The original author maintains the right to be solely associated with this work.
%
%   Programmed and Copyright by Frank Madrid: fmadr002[at]ucr[dot]edu
%   Date: 02/12/2018

  %% INPUT VALIDATION
  p = inputParser;

  paramName     = 'Data';
  validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'vector'});
  addRequired(p, paramName, validationFcn);

  paramName     = 'Length';
  validationFcn = @(x) validateattributes(x, {'numeric'}, {'integer', 'scalar', 'positive'});
  addRequired(p, paramName, validationFcn);

  paramName     = 'Solution';
  validationFcn = @(x) validateattributes(x, {'numeric'}, {'integer', 'vector'});
  addRequired(p, paramName, validationFcn);

  paramName     = 'ExclusionRange';
  defaultVal    = floor(Length * 0.5);
  validationFcn = @(x) validateattributes(x, {'numeric'}, {'integer', 'scalar', 'nonnegative'});
  addParameter(p, paramName, defaultVal, validationFcn);

  paramName     = 'Bits';
  defaultVal = 8;
  validationFcn = @(x) validateattributes(x, {'numeric'}, {'integer', 'scalar', 'positive'});
  addParameter(p, paramName, defaultVal, validationFcn);

  paramName     = 'Blind';
  defaultVal    = false;
  validationFcn = @(x) validateattributes(x, {'logical'}, {'scalar'});
  addParameter(p, paramName, defaultVal, validationFcn);

  paramName     = 'Debug';
  defaultVal    = true;
  validationFcn = @(x) validateattributes(x, {'logical'}, {'scalar'});
  addParameter(p, paramName, defaultVal, validationFcn);

  paramName     = 'Colors';
  defaultVal    = {'r', 'b', 'g', 'm', 'c', 'y', 'k'};
  validationFcn = @(x) validateattributes(x, {'char'}, {'vector'});
  addParameter(p, paramName, defaultVal, validationFcn);

  paramName     = 'ShowPlot';
  defaultVal    = false;
  validationFcn = @(x) validateattributes(x, {'logical'}, {'scalar'});
  addParameter(p, paramName, defaultVal, validationFcn);

  paramName     = 'MaxIterations';
  defaultVal    = ceil(numel(Data)/Length);
  validationFcn = @(x) validateattributes(x, {'numeric'}, {'integer', 'scalar'});
  addParameter(p, paramName, defaultVal, validationFcn);
  p.parse(Data, Length, Solution, varargin{:});

  INPUTS = p.Results;

  msg = sprintf('Length must be less than the length of the data. Data Size = %d Length = %d', numel(INPUTS.Data), INPUTS.Length);
  assert(numel(INPUTS.Data) > INPUTS.Length, '%s - [AutoLBLR] %s\n', datestr(now, 'HH:MM:SS'), msg);

  msg = sprintf('Solution must be the same size as Data. Data Size = %d Solution Size = %d', numel(INPUTS.Data), numel(INPUTS.Solution));
  assert(numel(INPUTS.Data) == numel(INPUTS.Solution) || numel(INPUTS.Solution) == 0, '%s - [AutoLBLR] %s\n', datestr(now, 'HH:MM:SS'), msg);

  msg = 'Solution values should be in the range of [1, N] where N is the number of classes.';
  assert(max(Solution) ~= numel(Solution), '%s - [AutoLBLR] %s\n', datestr(now, 'HH:MM:SS'), msg);

  % Add more colors
  while(numel(unique(INPUTS.Solution)) > numel(INPUTS.Colors))
    INPUTS.Colors(end+1) = {rand(1,3)}; %#ok<*AGROW>
  end

  %% INITIALIZE AUTOLBLR

  if(INPUTS.Debug)

    fileID = fopen('AutoLBLR - Logfile.txt', 'w');
    fprintf(fileID, '==================================================\n');
    fprintf(fileID, ' %s\n', 'AutoLBLR');
    fprintf(fileID, '==================================================\n');
    fprintf(fileID, '\n');

    fprintf(fileID, '==================================================\n');
    fprintf(fileID, ' %s\n', 'Initialization');
    fprintf(fileID, '==================================================\n');
    fprintf(fileID, 'AutoLBLR Parameters\n');
    fprintf(fileID, '\tData Size:       %d\n', numel(INPUTS.Data));
    fprintf(fileID, '\tLength:          %d\n', INPUTS.Length);
    fprintf(fileID, '\tExclusion Range: %d\n', INPUTS.ExclusionRange);
    fprintf(fileID, '\tBits:            %d\n', INPUTS.Bits);
    fprintf(fileID, '\tClasses:         %d\n', numel(unique(INPUTS.Solution)));
    fprintf(fileID, '\n');
  end

  % Function Outputs
  Labels       = zeros(numel(INPUTS.Data),1);                                     % Predicted Lables for corresponding Datapoint
  PlotHandles  = gobjects(0,0);                                                   % Handles for each plot: {MainPlot, Motif(1), MDL(1), Motif(2), MDL(2), ...}
  Progress     = [];                                                              % Progress(i) - Percentage of data classified at Iteration i
  DiscreteData = Normalization(INPUTS.Data, [1 2^INPUTS.Bits], 'Discrete', true); % Discretized dataset which will be modeled during MDL
  DataIDX      = {transpose(1:numel(INPUTS.Data))};                               % DataIDX{i} - Contiguous and consecutive unlabeled IDX values

  % Generate plot which maintains labeled motifs
  PlotHandles(end+1) = figure('name','Main Plot', 'NumberTitle', 'off', 'visible', 'off');
  hold on;
  xlim([1,numel(INPUTS.Data)]);
  plot(Data, 'color', 'black');

  if(INPUTS.ShowPlot)
    set(PlotHandles(1), 'visible', 'on');
  end

  %% BEGIN AUTOLBLR

  if(INPUTS.Debug)
    fprintf(fileID, '==================================================\n');
    fprintf(fileID, ' %s\n', 'Experiment');
    fprintf(fileID, '==================================================\n');
  end

  Iteration = 0;
  while(~isempty(DataIDX))
    Iteration = Iteration + 1;

    if(Iteration > numel(INPUTS.Colors))
      INPUTS.Colors(end+1) = {rand(1,3)};
    end

    if(INPUTS.Debug)
      fprintf(fileID, '%s - [AutoLBLR] Iteration [%d].\n', datestr(now, 'HH:MM:SS'), Iteration);
      fprintf(fileID, '\tUnlabeled IDX: %d - ', numel(DataIDX)); cellfun(@(x) fprintf(fileID, ' [%d, %d]', x(1), x(end)), DataIDX); fprintf(fileID, '\n');
      fprintf(fileID, '\tProgress:      %s\n', num2str(sum(Labels ~= 0) / numel(Labels) * 100) + "%");
      fprintf(fileID, '\n');
    end

    %% FIND MODEL
    % Uses the motif identified by the Matrix Profile as the model during the MDL process

    % Runs the Matrix Profile on the unlabeled data
    matDataIDX = cell2mat(DataIDX);
    try [~,MatrixProfile] = sort(stompSelf(INPUTS.Data(matDataIDX), INPUTS.Length));
    catch ME
      fprintf(fileID, '[AutoLBLR] Matrixrofile error caught.\n');
      break;
    end

%     % Catch and terminate experiment if MatrixProfile is empty
%     if(isempty(MatrixProfile))
%       fprintf(fileID, '%s - [AutoLBLR] WARNING: MatrixProfile should not be empty. Exiting Labeling process', datestr(now, 'HH:MM:SS'));
%       break;
%     end
% 
%     % Catch and attempt to recover from unexpected values
%     if(matDataIDX(MatrixProfile(1)) + INPUTS.Length > numel(INPUTS.Data))
%       i = matDataIDX(MatrixProfile(2));
%       while matDataIDX(MatrixProfile(i)) + INPUTS.Length > numel(INPUTS.Data)
%         i = i + 1;
%         if i > numel(INPUTS.Data)
%           break;
%         end
%       end
% 
%       if(i > numel(INPUTS.Data))
%         fprintf(fileID, '%s - [AutoLBLR] WARNING: MatrixProfile did not return a valid sequence.\n', datestr(now, 'HH:MM:SS'));
%         break;
%       else
%         fprintf(fileID, '%s - [AutoLBLR] MatrixProfile returned an invalid subsequence. Recovered using motifIDX [%d].\n', ...
%           datestr(now, 'HH:MM:SS'), matDataIDX(MatrixProfile(i)));
%       end
%     end

    MotifIDX      = matDataIDX(MatrixProfile(1));
    DiscreteModel = GetSubsequence(DiscreteData, MotifIDX, INPUTS.Length);

    % Plot the Motif
    str = sprintf('Iteration %d - Motif Plot %d', Iteration, MotifIDX);
    PlotHandles(end+1) = figure('name', str, 'NumberTitle', 'off', 'visible', 'off');
    hold on;
    xlim([1,numel(INPUTS.Data)]);
    plot(INPUTS.Data, 'color', 'black');
    plot(GetRange(MotifIDX, INPUTS.Length),GetSubsequence(INPUTS.Data, MotifIDX, INPUTS.Length), 'color', 'blue', 'LineWidth', 2);
    legend('Dataset', 'Model');
    if(INPUTS.ShowPlot)
      set(PlotHandles(end),'visible', 'on');
    end

    %% MDL - MODEL DATASET USING HYPOTHESIS
    % Identifies a cluster of subsequence IDX values by performing MDL on each contiguous dataset using the discretized motif as the model

    if(INPUTS.Debug)
      fprintf(fileID, '%s - [AutoLBLR] Running MDL on [%d] groups using MotifIDX [%d].\n', datestr(now, 'HH:MM:SS'), numel(DataIDX), MotifIDX);
    end

    % Subsequence IDX values identified by MDL to have a reduced description length when modeling with the Motif
    GroupMDL_IDX = cell(numel(DataIDX),1);
    GroupScores  = cell(numel(DataIDX),1);

    % For each contiguous dataset
    for i = 1 : numel(DataIDX)

      % INCLUDES an ExclusionRange of data on each side of the dataset (ensures always in the bounds of the data)
      InclusionData = max(1, DataIDX{i}(1) - INPUTS.ExclusionRange) : min(DataIDX{i}(end) + INPUTS.ExclusionRange, numel(INPUTS.Data));

      % Runs MDL on the augmented contiguous dataset using the discretized motif as the model
      [tempMDL, tempScores] = MDL(DiscreteData(InclusionData), DiscreteModel);
      GroupMDL_IDX{i}       = InclusionData(tempMDL);
      GroupScores{i}        = transpose(tempScores);

      if(INPUTS.Debug)
        UniqueSubsequences = GroupMDL_IDX{i}(arrayfun(@(x) sum(GroupMDL_IDX{i} < x & GroupMDL_IDX{i} > x - INPUTS.ExclusionRange) == 0 || sum(GroupMDL_IDX{i} > x & GroupMDL_IDX{i} < x + INPUTS.ExclusionRange) == 0, GroupMDL_IDX{i}));
        fprintf(fileID, '\tGroup %d - Found [%d] subsequences: %s\n', i, numel(UniqueSubsequences), mat2str(UniqueSubsequences));
      end

    end
    if(INPUTS.Debug)
      fprintf(fileID, '\n');
    end

    % Combines the identified subsequences for each contiguous dataset TO-DO: Figure out why cell2mat does not work here
    MDL_IDX = [];
    for i = 1 : numel(GroupMDL_IDX)
      MDL_IDX = [MDL_IDX GroupMDL_IDX{i}];
    end

    Scores = [];
    for i = 1 : numel(GroupScores)
      Scores = [Scores; GroupScores{i}];
    end

    % Order MDL_IDX values by their score
    [~,I] = sort(Scores);
    MDL_IDX = MDL_IDX(I);

    % Remove subsequences which are completely overlapped
    MDL_IDX = MDL_IDX(arrayfun(@(x) sum(MDL_IDX < x & MDL_IDX > x - INPUTS.ExclusionRange) == 0 || sum(MDL_IDX > x & MDL_IDX < x + INPUTS.ExclusionRange) == 0, MDL_IDX));
    MDL_IDX = [MotifIDX MDL_IDX];

    msg = sprintf('Iteration: %d - MotifIDX should be in the list of MDL identified indices.', Iteration);
    assert(ismember(MotifIDX, MDL_IDX), '%s - [AutoLBLR] %s\n', datestr(now, 'HH:MM:SS'), msg);

    %% BRUSH LABELS
    % Applies a label to the motif and MDL subsequences. If there is no solution vector or AutoLBLR is "running blind", then identify the class as the current
    % iteration of AutoLBLR; otherwise, use a greedy approach to identify the label from the corresponding indices of the solution vector

    % Acquire the label to "brush" onto the motif and MDL subsequences
    if(INPUTS.Blind)
      Label = Iteration;
      LabelIDX = MDL_IDX; % Brush the label to all subsequences at the IDX values identified by MDL

    else

      % Greedily sets the label as the highest frequency label in the corresponding indices of the solution vector
      Label = mode(Solution(GetRange(MotifIDX, INPUTS.Length)));
      MDL_IDX_Label = arrayfun(@(x) mode(Solution(GetRange(x,INPUTS.Length))), MDL_IDX);

      if(INPUTS.Debug)
        fprintf(fileID, '[AutoLBLR] Motif is %0.2f%% Class [%d].\n', sum(Solution(MotifIDX:MotifIDX+INPUTS.Length - 1) == Label) / INPUTS.Length * 100, Label);
        fprintf(fileID, '\n');
      end

      % Brush the label to the first contiguous set of subsequences with IDX matching the motif's label
      LikeClasses = SequentialSegments(find(MDL_IDX_Label == Label));
      LabelIDX    = MDL_IDX(LikeClasses{1});

    end

    if(INPUTS.Debug)
      fprintf(fileID, '%s - [AutoLBLR] Brushing label [%d] onto [%d] subsequences.\n', datestr(now, 'HH:MM:SS'), Label, numel(LabelIDX));
      arrayfun(@(x) fprintf(fileID, '\t[%d, %d] ', x, x + INPUTS.Length-1), LabelIDX);
      fprintf(fileID, '\n');
      fprintf(fileID, '\n');
    end

    % Generate MDL Plot
    str = sprintf('Iteration %d - MDL Plot', Iteration);
    PlotHandles(end+1) = figure('name', str, 'NumberTitle', 'off', 'visible', 'off');
    hold on;
    arrayfun(@(x) plot(INPUTS.Data(x:x + INPUTS.Length - 1), 'color', [0 0 0 0.1]), LabelIDX);
    plot(GetSubsequence(INPUTS.Data, MotifIDX, INPUTS.Length), 'color', 'blue', 'LineWidth', 2);


    if(INPUTS.ShowPlot)
      set(PlotHandles(end), 'visible', 'on');
    end

    %Update main plot
    set(0, 'CurrentFigure', PlotHandles(1))
    arrayfun(@(x) plot(intersect(GetRange(x, INPUTS.Length), find(Labels == 0)), INPUTS.Data(intersect(GetRange(x, INPUTS.Length), find(Labels == 0))), 'color', INPUTS.Colors{Label}, 'LineWidth', 2), LabelIDX);

    % Get the IDX values of the subsequences to label and apply the label
    IDX         = intersect(cell2mat(arrayfun(@(x) GetRange(x, INPUTS.Length), LabelIDX, 'UniformOutput', false)), find(Labels == 0));
    Labels(IDX) = Label;

    % Remove all all labeled subsequences values from the contiguous datasets
    DataIDX = SequentialSegments(setdiff(cell2mat(DataIDX), IDX));

    %% AUTOCLASSIFY
    % Identifies and labels all small contiguous datasets

    if(INPUTS.Debug)
      Count = cellfun(@(x) numel(x) < INPUTS.Length, DataIDX);
      fprintf(fileID, '%s - [AutoLBLR] Autoclassifying [%d] groups.\n', datestr(now, 'HH:MM:SS'), sum(Count));
    end

    % For each contiguous dataset
    for i = 1 : numel(DataIDX)

      % If the dataset is too short
      if(numel(DataIDX{i}) < INPUTS.Length)

        % Identify the label of the contiguous dataset with respect to the labels of the neighboring datasets
        L = AutoClassify([DataIDX{i}(1) DataIDX{i}(end)], Labels);
        Labels(DataIDX{i}) = L;

        if(INPUTS.Debug)
          fprintf(fileID, '\t%d: [%d,%d] -> %d\n', i, DataIDX{i}(1), DataIDX{i}(end), L);
        end

        set(0, 'CurrentFigure', PlotHandles(1))
        if(L == -1) plot(DataIDX{i}(1) : min(DataIDX{i}(end) + 1, numel(INPUTS.Data)), INPUTS.Data(DataIDX{i}(1) : min(DataIDX{i}(end) + 1, numel(INPUTS.Data))), 'color', 'black', 'LineWidth', 2);
        else        plot(DataIDX{i}(1) : min(DataIDX{i}(end) + 1, numel(INPUTS.Data)), INPUTS.Data(DataIDX{i}(1) : min(DataIDX{i}(end) + 1, numel(INPUTS.Data))), 'color', INPUTS.Colors{L}, 'LineWidth', 2);
        end

        % Clear the dataset from the set of contiguous unlabeled datasets
        DataIDX{i} = [];
      end

    end

    if(INPUTS.Debug)
      fprintf(fileID, '\n');
    end

    % Remove all cleared entries from the contiguous unlabeledge datasets
    DataIDX = DataIDX(~cellfun('isempty',DataIDX));

    % Update Progress tracker
    Progress(end+1) = sum(Labels ~= 0) / numel(Labels);

    if(Iteration >= INPUTS.MaxIterations)
      Labels((Labels == 0)) = -1;
      break;
    end

  end

  %% CLEANUP LABELS
  % Greedily reduce each label to the labels of the solution vector

  % If AutoLBLR was blind, greedily reduce each label to the labels of the solution vector; otherwise,
  if(INPUTS.Blind)

    if(~isempty(INPUTS.Solution))
      % Get the specific labels
      UniqueValues = unique(Labels);

      % Greedily sets each label as the highest frequency label in the corresponding indices of the solution vector
      RealLabels = zeros(numel(Labels),1) - 1;
      for i = 1:numel(UniqueValues)
        Label = mode(Solution(Labels == UniqueValues(i)));
        RealLabels(Labels == UniqueValues(i)) = Label;
      end

      Labels = RealLabels;
    end

  else

    % Set all unclassifiable labels to its own class
    Labels(Labels == -1) = 0;

  end

  if(INPUTS.Debug)
    fclose(fileID);
  end
end

%% HELPER FUNCTIONS
function [S] = GetSubsequence(Sequence, StartIDX, Length)
  S = Sequence(GetRange(StartIDX, Length));
end

function [R] = GetRange(StartIDX, Length)
  R = StartIDX:StartIDX+Length-1;
end

function [L] = AutoClassify(DataIDX, Labels)

    % Get left neighbor's class
    LeftLabel = 0;
    if(DataIDX(1) ~= 1)
        LeftLabel = Labels(DataIDX(1) - 1);
    end

    % Get right neighbor's class
    rightLabel = 0;
    if(DataIDX(2) ~= length(Labels))
        rightLabel = Labels(DataIDX(2) + 1);
    end

    if(LeftLabel == rightLabel) L = LeftLabel;
    elseif (LeftLabel == 0)     L = rightLabel;
    elseif (rightLabel == 0)    L = LeftLabel;
    else                        L = -1;
    end
end
