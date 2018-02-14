function [Labels, PlotHandles, Completion] = AutoLBLR(TimeSeries, ModelLength, varargin)
% [Labels, PlotHandles, Completion] = AutoLBLR(TimeSeries, ModelModelLength, Solution = [], OPTIONS)
%     AutoLBLR is an unsupervised execution of the LBLR application. Instead of deferring to the human annotator (user) AutoLBLR will simply apply a 
%     classification label to the cluster of subsequences which are semantically similar. If AutoLBLR is not running blind it will greedily apply the 
%     most likely label as indicated by the SolutionVector otherwise the label will simply be the current iteration of the algorithm.
%
%     Inputs:
%         TimeSeries     - A numeric non-empty vector with length n
%         ModelLength    - A scalar integer less than n
%         SolutionVector - Classification labels for the corresponding data poitns in 'TimeSeries' representing the ground truth. If empty, LBLR will
%                          be assumed to operate blind; otherwise, must be a non-empty numeric integer vector with length n.
%         
%
%     Outputs:
%         Labels      - Predicted labels for the corresponding points in 'TimeSeries'
%         PlotHandles - An array of figure handles for each of the generated plots.
%         Completion  - Increasing numeric vector indicating the percentage of annotated data after each iteration. 
%         
%     Options
%         ExclusionRange    - A heuristically set window which excludes a range of subsequences from the original subsequene when checking for
%                             similarity.
%         Bits              - Number of bits used to discretize the TimeSeries.
%         Blind             - If enabled, AutoLBLR will NOT math predicted labels to a solution vector. This option is useful for identifying
%                             preserved subsequences within a defined behavior.
%         Debug             - Outputs a deeper trace to the output file. Used for internal purposes only or really curious users.
%         MaximumIterations - Sets a limit to the amount of iterations AutoLBLR would run.
%
%   License to use and modify this code is granted freely without warranty to all, as long as the original author is
%   referenced and attributed as such. The original author maintains the right to be solely associated with this work.
%
%   Programmed and Copyright by Frank Madrid: fmadr002[at]ucr[dot]edu
%   Date: 02/12/2018

  %% INPUT VALIDATION
  p = inputParser;

  paramName     = 'TimeSeries';
  validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'vector'});
  addRequired(p, paramName, validationFcn);

  paramName     = 'ModelLength';
  validationFcn = @(x) validateattributes(x, {'numeric'}, {'integer', 'scalar', 'positive'});
  addRequired(p, paramName, validationFcn);

  paramName     = 'Solution';
  defaultVal    = [];
  validationFcn = @(x) validateattributes(x, {'numeric'}, {'integer', 'vector'});
  addOptional(p, paramName, defaultVal, validationFcn);

  paramName     = 'ExclusionRange';
  defaultVal    = floor(ModelLength * 0.5);
  validationFcn = @(x) validateattributes(x, {'numeric'}, {'integer', 'scalar', 'nonnegative'});
  addParameter(p, paramName, defaultVal, validationFcn);

  paramName     = 'Bits';
  defaultVal    = 8;
  validationFcn = @(x) validateattributes(x, {'numeric'}, {'integer', 'scalar', 'positive'});
  addParameter(p, paramName, defaultVal, validationFcn);

  paramName     = 'Blind';
  defaultVal    = false;
  validationFcn = @(x) validateattributes(x, {'logical'}, {'scalar'});
  addParameter(p, paramName, defaultVal, validationFcn);

  paramName     = 'Debug';
  defaultVal    = false;
  validationFcn = @(x) validateattributes(x, {'logical'}, {'scalar'});
  addParameter(p, paramName, defaultVal, validationFcn);
  
  paramName     = 'MaxIterations';
  defaultVal    = ceil(numel(TimeSeries)/ModelLength);
  validationFcn = @(x) validateattributes(x, {'numeric'}, {'integer', 'scalar'});
  addParameter(p, paramName, defaultVal, validationFcn);
  
  paramName     = 'Colors';
  defaultVal    = {'r', 'b', 'g', 'm', 'c', 'y', 'k'};
  validationFcn = @(x) validateattributes(x, {'char'}, {'vector'});
  addParameter(p, paramName, defaultVal, validationFcn);
  
  p.parse(TimeSeries, ModelLength, varargin{:});
  INPUTS = p.Results;

  msg = sprintf('ModelLength must be less than the length of the data. TimeSeries Size = %d ModelLength = %d', numel(INPUTS.TimeSeries), INPUTS.ModelLength);
  assert(numel(INPUTS.TimeSeries) > INPUTS.ModelLength, '%s - [AutoLBLR] %s\n', datestr(now, 'HH:MM:SS'), msg);

  msg = sprintf('Solution must be the same size as TimeSeries or empty. TimeSeries Size = %d Solution Size = %d', numel(INPUTS.TimeSeries), numel(INPUTS.Solution));
  assert(numel(INPUTS.TimeSeries) == numel(INPUTS.Solution) || numel(INPUTS.Solution) == 0, '%s - [AutoLBLR] %s\n', datestr(now, 'HH:MM:SS'), msg);

  msg = 'Solution values should be in the range of [1, N] where N is the number of classes.';
  assert(max(INPUTS.Solution) ~= numel(INPUTS.Solution), '%s - [AutoLBLR] %s\n', datestr(now, 'HH:MM:SS'), msg);

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
    fprintf(fileID, '\tTimeSeries Size: %d\n', numel(INPUTS.TimeSeries));
    fprintf(fileID, '\tModelLength:     %d\n', INPUTS.ModelLength);
    fprintf(fileID, '\tExclusion Range: %d\n', INPUTS.ExclusionRange);
    fprintf(fileID, '\tBits:            %d\n', INPUTS.Bits);
    fprintf(fileID, '\tClasses:         %d\n', numel(unique(INPUTS.Solution)));
    fprintf(fileID, '\n');
  end

  % Function Outputs
  Labels       = zeros(numel(INPUTS.TimeSeries),1);                                           % Predicted Lables for corresponding TimeSeriespoint
  PlotHandles  = gobjects(0,0);                                                               % Handles for each plot: {MainPlot, Motif(1), MDL(1), Motif(2), MDL(2), ...}
  Completion     = [];                                                                        % Progress(i) - Percentage of data classified at Iteration i
  DiscreteTimeSeries = Normalization(INPUTS.TimeSeries, [1 2^INPUTS.Bits], 'Discrete', true); % Discretized dataset which will be modeled during MDL
  TimeSeriesIDX      = {transpose(1:numel(INPUTS.TimeSeries))};                               % TimeSeriesIDX{i} - Contiguous and consecutive unlabeled IDX values

  % Generate plot which maintains labeled motifs
  PlotHandles(end+1) = figure('name','Main Plot', 'NumberTitle', 'off', 'visible', 'off');
  hold on;
  xlim([1,numel(INPUTS.TimeSeries)]);
  plot(TimeSeries, 'color', 'black');

  %% BEGIN AUTOLBLR

  if(INPUTS.Debug)
    fprintf(fileID, '==================================================\n');
    fprintf(fileID, ' %s\n', 'Experiment');
    fprintf(fileID, '==================================================\n');
  end

  Iteration = 0;
  while(~isempty(TimeSeriesIDX))
    Iteration = Iteration + 1;

    if(Iteration > numel(INPUTS.Colors))
      INPUTS.Colors(end+1) = {rand(1,3)};
    end

    if(INPUTS.Debug)
      fprintf(fileID, '%s - [AutoLBLR] Iteration [%d].\n', datestr(now, 'HH:MM:SS'), Iteration);
      fprintf(fileID, '\tUnlabeled IDX: %d - ', numel(TimeSeriesIDX)); cellfun(@(x) fprintf(fileID, ' [%d, %d]', x(1), x(end)), TimeSeriesIDX); fprintf(fileID, '\n');
      fprintf(fileID, '\tProgress:      %s\n', num2str(sum(Labels ~= 0) / numel(Labels) * 100) + "%");
      fprintf(fileID, '\n');
    end

    %% FIND MODEL
    % Uses the motif identified by the Matrix Profile as the model during the MDL process

    % Runs the Matrix Profile on the unlabeled data
    matTimeSeriesIDX = cell2mat(TimeSeriesIDX);
    try [~,MatrixProfile] = sort(stompSelf(INPUTS.TimeSeries(matTimeSeriesIDX), INPUTS.ModelLength));
    catch ME
      fprintf(fileID, '[AutoLBLR] Matrixrofile error caught.\n');
      warning('stompSelf did not return an appropriate value. Defaulting to the first IDX.\n');
      MatrixProfile = matTimeSeriesIDX(1);
    end

    MotifIDX      = matTimeSeriesIDX(MatrixProfile(1));
    DiscreteModel = GetSubsequence(DiscreteTimeSeries, MotifIDX, INPUTS.ModelLength);

    % Plot the Motif
    str = sprintf('Iteration %d - Motif Plot %d', Iteration, MotifIDX);
    PlotHandles(end+1) = figure('name', str, 'NumberTitle', 'off', 'visible', 'off');
    hold on;
    xlim([1,numel(INPUTS.TimeSeries)]);
    plot(INPUTS.TimeSeries, 'color', 'black');
    plot(GetRange(MotifIDX, INPUTS.ModelLength),GetSubsequence(INPUTS.TimeSeries, MotifIDX, INPUTS.ModelLength), 'color', 'blue', 'LineWidth', 2);
    legend('TimeSeriesset', 'Model');

    %% MDL - MODEL DATASET USING HYPOTHESIS
    % Identifies a cluster of subsequence IDX values by performing MDL on each contiguous dataset using the discretized motif as the model

    if(INPUTS.Debug)
      fprintf(fileID, '%s - [AutoLBLR] Running MDL on [%d] groups using MotifIDX [%d].\n', datestr(now, 'HH:MM:SS'), numel(TimeSeriesIDX), MotifIDX);
    end

    % Subsequence IDX values identified by MDL to have a reduced description length when modeling with the Motif
    GroupMDL_IDX = cell(numel(TimeSeriesIDX),1);
    GroupScores  = cell(numel(TimeSeriesIDX),1);

    % For each contiguous dataset
    for i = 1 : numel(TimeSeriesIDX)

      % INCLUDES an ExclusionRange of data on each side of the dataset (ensures always in the bounds of the data)
      InclusionTimeSeries = max(1, TimeSeriesIDX{i}(1) - INPUTS.ExclusionRange) : min(TimeSeriesIDX{i}(end) + INPUTS.ExclusionRange, numel(INPUTS.TimeSeries));

      % Runs MDL on the augmented contiguous dataset using the discretized motif as the model
      [tempMDL, tempScores] = MDL(DiscreteTimeSeries(InclusionTimeSeries), DiscreteModel);
      GroupMDL_IDX{i}       = InclusionTimeSeries(tempMDL);
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
      Label = mode(INPUTS.Solution(GetRange(MotifIDX, INPUTS.ModelLength)));
      MDL_IDX_Label = arrayfun(@(x) mode(INPUTS.Solution(GetRange(x,INPUTS.ModelLength))), MDL_IDX);

      if(INPUTS.Debug)
        fprintf(fileID, '[AutoLBLR] Motif is %0.2f%% Class [%d].\n', sum(INPUTS.Solution(MotifIDX:MotifIDX+INPUTS.ModelLength - 1) == Label) / INPUTS.ModelLength * 100, Label);
        fprintf(fileID, '\n');
      end

      % Brush the label to the first contiguous set of subsequences with IDX matching the motif's label
      LikeClasses = SequentialSegments(find(MDL_IDX_Label == Label));
      LabelIDX    = MDL_IDX(LikeClasses{1});

    end

    if(INPUTS.Debug)
      fprintf(fileID, '%s - [AutoLBLR] Brushing label [%d] onto [%d] subsequences.\n', datestr(now, 'HH:MM:SS'), Label, numel(LabelIDX));
      arrayfun(@(x) fprintf(fileID, '\t[%d, %d] ', x, x + INPUTS.ModelLength-1), LabelIDX);
      fprintf(fileID, '\n');
      fprintf(fileID, '\n');
    end

    % Generate MDL Plot
    str = sprintf('Iteration %d - MDL Plot', Iteration);
    PlotHandles(end+1) = figure('name', str, 'NumberTitle', 'off', 'visible', 'off');
    hold on;
    arrayfun(@(x) plot(INPUTS.TimeSeries(x:x + INPUTS.ModelLength - 1), 'color', [0 0 0 0.1]), LabelIDX);
    plot(GetSubsequence(INPUTS.TimeSeries, MotifIDX, INPUTS.ModelLength), 'color', 'blue', 'LineWidth', 2);
    
    %Update main plot
    set(0, 'CurrentFigure', PlotHandles(1))
    arrayfun(@(x) plot(intersect(GetRange(x, INPUTS.ModelLength), find(Labels == 0)), INPUTS.TimeSeries(intersect(GetRange(x, INPUTS.ModelLength), find(Labels == 0))), 'color', INPUTS.Colors{Label}, 'LineWidth', 2), LabelIDX);

    % Get the IDX values of the subsequences to label and apply the label
    IDX         = intersect(cell2mat(arrayfun(@(x) GetRange(x, INPUTS.ModelLength), LabelIDX, 'UniformOutput', false)), find(Labels == 0));
    Labels(IDX) = Label;

    % Remove all all labeled subsequences values from the contiguous datasets
    TimeSeriesIDX = SequentialSegments(setdiff(cell2mat(TimeSeriesIDX), IDX));

    %% AUTOCLASSIFY
    % Identifies and labels all small contiguous datasets

    if(INPUTS.Debug)
      Count = cellfun(@(x) numel(x) < INPUTS.ModelLength, TimeSeriesIDX);
      fprintf(fileID, '%s - [AutoLBLR] Autoclassifying [%d] groups.\n', datestr(now, 'HH:MM:SS'), sum(Count));
    end

    % For each contiguous dataset
    for i = 1 : numel(TimeSeriesIDX)

      % If the dataset is too short
      if(numel(TimeSeriesIDX{i}) < INPUTS.ModelLength)

        % Identify the label of the contiguous dataset with respect to the labels of the neighboring datasets
        L = AutoClassify([TimeSeriesIDX{i}(1) TimeSeriesIDX{i}(end)], Labels);
        Labels(TimeSeriesIDX{i}) = L;

        if(INPUTS.Debug)
          fprintf(fileID, '\t%d: [%d,%d] -> %d\n', i, TimeSeriesIDX{i}(1), TimeSeriesIDX{i}(end), L);
        end

        set(0, 'CurrentFigure', PlotHandles(1))
        if(L == -1) plot(TimeSeriesIDX{i}(1) : min(TimeSeriesIDX{i}(end) + 1, numel(INPUTS.TimeSeries)), INPUTS.TimeSeries(TimeSeriesIDX{i}(1) : min(TimeSeriesIDX{i}(end) + 1, numel(INPUTS.TimeSeries))), 'color', 'black', 'LineWidth', 2);
        else        plot(TimeSeriesIDX{i}(1) : min(TimeSeriesIDX{i}(end) + 1, numel(INPUTS.TimeSeries)), INPUTS.TimeSeries(TimeSeriesIDX{i}(1) : min(TimeSeriesIDX{i}(end) + 1, numel(INPUTS.TimeSeries))), 'color', INPUTS.Colors{L}, 'LineWidth', 2);
        end

        % Clear the dataset from the set of contiguous unlabeled datasets
        TimeSeriesIDX{i} = [];
      end

    end

    if(INPUTS.Debug)
      fprintf(fileID, '\n');
    end

    % Remove all cleared entries from the contiguous unlabeledge datasets
    TimeSeriesIDX = TimeSeriesIDX(~cellfun('isempty',TimeSeriesIDX));

    % Update Progress tracker
    Completion(end+1) = sum(Labels ~= 0) / numel(Labels);

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
function [S] = GetSubsequence(Sequence, StartIDX, ModelLength)
  S = Sequence(GetRange(StartIDX, ModelLength));
end

function [R] = GetRange(StartIDX, ModelLength)
  R = StartIDX:StartIDX+ModelLength-1;
end

function [L] = AutoClassify(TimeSeriesIDX, Labels)

    % Get left neighbor's class
    LeftLabel = 0;
    if(TimeSeriesIDX(1) ~= 1)
        LeftLabel = Labels(TimeSeriesIDX(1) - 1);
    end

    % Get right neighbor's class
    rightLabel = 0;
    if(TimeSeriesIDX(2) ~= length(Labels))
        rightLabel = Labels(TimeSeriesIDX(2) + 1);
    end

    if(LeftLabel == rightLabel) L = LeftLabel;
    elseif (LeftLabel == 0)     L = rightLabel;
    elseif (rightLabel == 0)    L = LeftLabel;
    else                        L = -1;
    end
end
