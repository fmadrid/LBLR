%   License to use and modify this code is granted freely without warranty to all, as long as the original author is
%   referenced and attributed as such. The original author maintains the right to be solely associated with this work.
%
%   Programmed and Copyright by Frank Madrid: fmadr002[at]ucr[dot]edu
%   Date: 02/12/2018

% Frank Madrid, Shailendra Singh, Quentin Chesnais, Kerry Mauck, Eamonn Geogh "Efficient and Effective Labeling of Massive Time Series
% Archives"  http://www.cs.ucr.edu/~fmadr002/LBLR.html

%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure Initialization %
%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = LBLR(varargin)
% LBLRFig MATLAB code for LBLRFig.fig
%      LBLRFig, by itself, creates a new LBLRFig or raises the existing
%      singleton*.
%
%      H = LBLRFig returns the handle to a new LBLRFig or the handle to
%      the existing singleton*.
%
%      LBLRFig('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LBLRFig.M with the given input arguments.
%
%      LBLRFig('Property','Value',...) creates a new LBLRFig or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LBLRFig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LBLR_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LBLR

% Last Modified by GUIDE v2.5 09-Feb-2018 03:30:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LBLR_OpeningFcn, ...
                   'gui_OutputFcn',  @LBLR_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function LBLR_OpeningFcn(hObject, ~, handles, varargin)

handles.output = hObject;
handles = figureInitialization(handles);
guidata(hObject, handles);

function varargout = LBLR_OutputFcn(~, ~, handles) 

varargout{1} = handles.Labels;
varargout{2} = get(handles.ClassificationMenu,'String');
varargout{3} = handles.Progress;
uiwait(handles.LBLR);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Object Creation Functions %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SegmentField_CreateFcn(hObject, ~, ~) %#ok<*DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ClassificationSlider_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function DatasetTextField_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function LengthField_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ClassificationMenu_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function DatasetField_CreateFcn(~, ~, ~)
function MainPlot_CreateFcn(~, ~, ~)
function ExecuteButton_CreateFcn(~, ~, ~)

%%%%%%%%%%%%%%%%%%%%
% Object Callbacks %
%%%%%%%%%%%%%%%%%%%%

function LengthField_Callback(~,~,~)

function ImportDatasetButton_Callback(hObject, ~, handles)

%% PROMPT TO DISCARD PREVIOUSLY LOADED DATA
if ~isempty(handles.Data)
    promptResponse = questdlg('Discard results and dataset?', ...
        'LBLR - Discard Results', ...
        'Yes', 'No', 'No');
    if strcmp(promptResponse,'Yes')
        
        delete(handles.MasterPlot);
        cla(handles.MainPlot);
        
        delete(handles.ScrollHandler);
        set(handles.MainPlot, 'Position', [5.8 1.5 190 17]);
        
        delete(handles.MotifPlot);
        cla(handles.MotifPlot);
        
        % Reinitialize figure
        handles = figureInitialization(handles);
    else
        return
    end
    
end

%% GET DATA
[Filename, Pathname] = uigetfile('*.mat','Select the dataset file','../Datasets');
if (isequal(Filename,0) || isequal(Pathname,0))
    return;
end

try
    Data = load(strcat(Pathname,Filename));
    Dataset = Data.TimeSeries;
    validateattributes(Dataset, {'numeric'}, {'nonempty', 'vector'});
catch ME
    h = errordlg(ME.message);
    waitfor(h);
    return;
end

handles.Data = Dataset;

%% UPDATE GUI

% Update Fields
set(handles.DatasetField, 'String', Filename);
set(handles.MasterPlot, 'visible', 'on');

% Update Plot
handles.MasterPlot = plot(handles.MainPlot, handles.Data, 'color' ,'k');
hold on;
handles.ScrollHandler = scrollplot;

% Update handles structure
guidata(hObject, handles);

function ExecuteButton_Callback(hObject, ~, handles)

%% VALIDATE LENGTH
handles.Length  = str2double(get(handles.LengthField,'String'));
handles.ExclusionRange = floor(handles.Length / 2);
try validateattributes(handles.Length, {'numeric'}, {'integer', 'scalar', 'positive'});
catch ME
  return;
end

%% INITIALIZE LBLR
[handles.Labels, handles.DiscreteData, handles.DataIDX] = InitializeLBLR(handles.Data, 4);
try
  validateattributes(handles.Labels,       {'numeric'}, {'nonempty'});
  validateattributes(handles.DiscreteData, {'numeric'}, {'nonempty'});
  validateattributes(handles.DataIDX,      {'cell'},    {'nonempty'});
catch ME
  return;
end
handles.Iterations = 1;
handles.ViewingIDX = 1;

%% UPDATE GUI

% Disable Program Options
set(findall(handles.ProgramOptionsPanel, '-property', 'enable'), 'enable', 'off');
set(handles.ExportButton, 'enable', 'on');

% Enable Statistics Panel
set(findall(handles.StatisticsPanel, '-property', 'enable'), 'enable', 'on');
set(handles.IterationField, 'String', "1");

% Enable LabelControls Panel
set(findall(handles.LabelControlsPanel, '-property', 'enable'), 'enable', 'on');
set(handles.SegmentField, 'enable', 'off');

%% FIND MODEL
matDataIDX = cell2mat(handles.DataIDX);
try 
  [~,handles.MatrixProfile] = sort(stompSelf(handles.Data(matDataIDX), handles.Length));
  validateattributes(handles.MatrixProfile, {'numeric'}, {'nonempty'});
catch ME
  errordlg('Matrix Profile threw error: %s.', ME.message);
  return;
end

handles.MotifIDX      = matDataIDX(handles.MatrixProfile(1));
handles.DiscreteModel = GetSubsequence(handles.DiscreteData, handles.MotifIDX, handles.Length);

%% UPDATE GUI
% Highlight the Hypothesis in the main plot
Range                   = GetRange(handles.MotifIDX, handles.Length);
handles.SubsequencePlot = plot(handles.MainPlot, Range, handles.Data(Range), 'color', 'blue', 'LineWidth', 3);

%% MDL - MODEL DATASET USING HYPOTHESIS
% Run MDL on the Discretized Dataset using the first motif identified by the matrix profile
[handles.MDL_IDX, Scores] = RunMDL(handles.DiscreteData, handles.DiscreteModel, handles.ExclusionRange, handles.DataIDX, handles.MotifIDX);
handles.PlotHandles       = GeneratePlots(handles.Data, handles.MotifIDX, handles.Length, handles.MotifAxes, handles.MDL_IDX);

%% UPDATE GUI

% Get the initial guess for the proposed clustering
N = sum(Scores < 0);

% Update Motif Plots and Classification Slider
set(handles.MotifAxes, 'visible', 'on');
UpdateMotifPlots(N, handles.PlotHandles);

UpdateSlider(handles.ClassificationSlider, numel(handles.MDL_IDX), N);
set(handles.SegmentField,'String', num2str(N));

guidata(hObject, handles);

function ClassificationSlider_Callback(hObject, ~, handles)
value = ceil(get(hObject, 'Value'));
set(hObject, 'Value', value);
set(handles.SegmentField, 'String', num2str(value));

% Update the visibility of plots on the MotifPlots Axes
UpdateMotifPlots(value, handles.PlotHandles);

function ExportButton_Callback(~, ~, handles)
[~, DataFilename,~] = fileparts(get(handles.DatasetField, 'String'));
[Filename, Pathname] = uiputfile([DataFilename 'Labels.mat'], 'Save Label and Progress Data');
Labels = handles.Labels;
Labels(Labels == 0) = -1;
Progress = handles.Progress;
save([Pathname Filename], 'Labels', 'Progress');

[Filename, Pathname] = uiputfile([DataFilename 'Plot.fig'], 'Save Label and Progress Data');
PlotSolution(handles.Data, Labels);
saveas(gcf, [Pathname Filename]);
close(gcf);

function PreviousMotifButton_Callback(hObject, ~, handles)
delete(handles.SubsequencePlot);
if handles.ViewingIDX ~= 1
    handles.ViewingIDX = handles.ViewingIDX - 1;
else
    handles.ViewingIDX = length(handles.MatrixProfile);
end

handles.MotifIDX      = handles.MatrixProfile(handles.ViewingIDX);
handles.DiscreteModel = GetSubsequence(handles.DiscreteData, handles.MotifIDX, handles.Length);

%% UPDATE GUI
% Highlight the Hypothesis in the main plot
Range                   = GetRange(handles.MotifIDX, handles.Length);
handles.SubsequencePlot = plot(handles.MainPlot, Range, handles.Data(Range), 'color', 'blue', 'LineWidth', 3);

%% MDL - MODEL DATASET USING HYPOTHESIS
% Run MDL on the Discretized Dataset using the first motif identified by the matrix profile
[handles.MDL_IDX, Scores] = RunMDL(handles.DiscreteData, handles.DiscreteModel, handles.ExclusionRange, handles.DataIDX, handles.MotifIDX);
handles.PlotHandles       = GeneratePlots(handles.Data, handles.MotifIDX, handles.Length, handles.MotifAxes, handles.MDL_IDX);

%% UPDATE GUI

% Get the initial guess for the proposed clustering
N = sum(Scores < 0);

% Update Motif Plots and Classification Slider
set(handles.MotifAxes, 'visible', 'on');
UpdateMotifPlots(N, handles.PlotHandles);

UpdateSlider(handles.ClassificationSlider, numel(handles.MDL_IDX), N);
set(handles.SegmentField,'String', num2str(N));

guidata(hObject, handles);

function NextMotifButton_Callback(hObject, ~, handles)
delete(handles.SubsequencePlot);
if handles.ViewingIDX ~= length(handles.MatrixProfile)
    handles.ViewingIDX = handles.ViewingIDX + 1;
else
    handles.ViewingIDX = 1;
end

handles.MotifIDX      = handles.MatrixProfile(handles.ViewingIDX);
handles.DiscreteModel = GetSubsequence(handles.DiscreteData, handles.MotifIDX, handles.Length);

%% UPDATE GUI
% Highlight the Hypothesis in the main plot
Range                   = GetRange(handles.MotifIDX, handles.Length);
handles.SubsequencePlot = plot(handles.MainPlot, Range, handles.Data(Range), 'color', 'blue', 'LineWidth', 3);

%% MDL - MODEL DATASET USING HYPOTHESIS
% Run MDL on the Discretized Dataset using the first motif identified by the matrix profile
[handles.MDL_IDX, Scores] = RunMDL(handles.DiscreteData, handles.DiscreteModel, handles.ExclusionRange, handles.DataIDX, handles.MotifIDX);
handles.PlotHandles       = GeneratePlots(handles.Data, handles.MotifIDX, handles.Length, handles.MotifAxes, handles.MDL_IDX);

%% UPDATE GUI

% Get the initial guess for the proposed clustering
N = sum(Scores < 0);

% Update Motif Plots and Classification Slider
set(handles.MotifAxes, 'visible', 'on');
UpdateMotifPlots(N, handles.PlotHandles);

UpdateSlider(handles.ClassificationSlider, numel(handles.MDL_IDX), N);
set(handles.SegmentField,'String', num2str(N));

guidata(hObject, handles);

function ClassificationMenu_Callback(hObject, ~, handles)
delete(handles.SubsequencePlot);

%% GET CLASSIFICATION MENU VALUE
% If 'NewClass' was selected (i.e. value == 1) prompt the user for a class name
if get(hObject, 'Value') == 1
  
  NewClass = inputdlg('Enter Class Identifier:', 'LBLR - New Classification');
  
  % If the user did not enter a response, break out of the function, else update the classification menu list
  if(isempty(NewClass))
      return
  else
    NewList = char(get(hObject, 'String'), char(NewClass));
    set(hObject, 'String', NewList);
    set(hObject, 'Value', size(NewList,1));
  end
end

handles.Iterations = handles.Iterations + 1;

%% BRUSH LABELS

% Get the IDX values of the subsequences to label and apply the label
LabelIDX = handles.MDL_IDX(arrayfun(@(x) strcmp(get(x,'visible'),'on'), handles.PlotHandles));
%LabelIDX            = handles.MDL_IDX(1:get(handles.ClassificationSlider, 'Value'));
IDX                 = intersect(cell2mat(arrayfun(@(x) GetRange(x, handles.Length), LabelIDX, 'UniformOutput', false)), find(handles.Labels == 0));
handles.Labels(IDX) = get(hObject, 'Value');

% Remove all all labeled subsequences values from the contiguous datasets
handles.DataIDX = SequentialSegments(setdiff(cell2mat(handles.DataIDX), IDX));

%% AUTOCLASSIFY
% Identifies and labels all small contiguous datasets

% For each contiguous dataset
for i = 1 : numel(handles.DataIDX)

  % If the dataset is too short
  if(numel(handles.DataIDX{i}) < handles.Length)

    % Identify the label of the contiguous dataset with respect to the labels of the neighboring datasets
    L = AutoClassify([handles.DataIDX{i}(1) handles.DataIDX{i}(end)], handles.Labels);
    handles.Labels(handles.DataIDX{i}) = L;

    % Clear the dataset from the set of contiguous unlabeled datasets
    handles.DataIDX{i} = [];
  end

end

% Remove all cleared entries from the contiguous unlabeledge datasets
handles.DataIDX = handles.DataIDX(~cellfun('isempty',handles.DataIDX));

% Update Progress tracker
handles.Progress(end+1) = sum(handles.Labels ~= 0) / numel(handles.Labels);

%% UPDATE GUI    

% Update Percentage Classified
set(handles.IterationField, 'String', num2str(handles.Iterations));
str = sprintf('%0.2f%%', handles.Progress(end) * 100);
set(handles.ClassifiedField, 'String', str);

delete(handles.MasterPlot);
cla(handles.MainPlot);

delete(handles.ScrollHandler);
set(handles.MainPlot, 'Position', [5.8 1.5 190 17]);
        
% Update Plot
handles.MasterPlot = plot(handles.MainPlot, handles.Data, 'color' ,'k');
hold on;
handles.ScrollHandler = scrollplot(handles.MasterPlot);

Classes = unique(handles.Labels);
while(numel(unique(Classes)) > numel(handles.Colors))
    handles.Colors(end+1) = {rand(1,3)}; %#ok<*AGROW>
  end
% For each unique value in Solutions
for i = 1:numel(Classes)
  
  if Classes(i) == 0
    Color = 'k';
  elseif Classes(i) == -1
      Color = [0 0 0];
  else
    Color = handles.Colors{Classes(i)-1};
  end
  
  % Get the indices of INPUTS.Solution segments containing contiguous values of the current class
  IDX = SequentialSegments(find(handles.Labels == Classes(i)));
  
  % Plot the contiguous segments adding 1 to the range to 'connect' drawn plots
  cellfun(@(x) plot(handles.MainPlot, x(1):min(x(end)+1,numel(handles.Data)), handles.Data(x(1):min(x(end)+1,numel(handles.Data))), 'color', Color), IDX);
end

guidata(hObject, handles);

if(~isempty(handles.DataIDX))
  %% FIND MODEL
  matDataIDX = cell2mat(handles.DataIDX);
  try 
    [~,handles.MatrixProfile] = sort(stompSelf(handles.Data(matDataIDX), handles.Length));
    validateattributes(handles.MatrixProfile, {'numeric'}, {'nonempty'});
  catch ME
    errordlg('Matrix Profile threw error: %s.', ME.message);
    return;
  end

  handles.MotifIDX      = matDataIDX(handles.MatrixProfile(1));
  handles.DiscreteModel = GetSubsequence(handles.DiscreteData, handles.MotifIDX, handles.Length);

  %% UPDATE GUI
  % Highlight the Hypothesis in the main plot
  Range                   = GetRange(handles.MotifIDX, handles.Length);
  handles.SubsequencePlot = plot(handles.MainPlot, Range, handles.Data(Range), 'color', 'blue', 'LineWidth', 3);

  %% MDL - MODEL DATASET USING HYPOTHESIS
  % Run MDL on the Discretized Dataset using the first motif identified by the matrix profile
  [handles.MDL_IDX, Scores] = RunMDL(handles.DiscreteData, handles.DiscreteModel, handles.ExclusionRange, handles.DataIDX, handles.MotifIDX);
  handles.PlotHandles       = GeneratePlots(handles.Data, handles.MotifIDX, handles.Length, handles.MotifAxes, handles.MDL_IDX);

  %% UPDATE GUI

  % Get the initial guess for the proposed clustering
  N = sum(Scores < 0);

  % Update Motif Plots and Classification Slider
  set(handles.MotifAxes, 'visible', 'on');
  UpdateMotifPlots(N, handles.PlotHandles);

  UpdateSlider(handles.ClassificationSlider, numel(handles.MDL_IDX), N);
  set(handles.SegmentField,'String', num2str(N));


else
    cla(handles.MotifAxes);
    % Disable Program Options
    set(findall(handles.LabelControlsPanel, '-property', 'enable'), 'enable', 'off');
    % Disable Program Options
    set(findall(handles.MotifLabelerPanel, '-property', 'enable'), 'enable', 'off');
    str = "All data has been classified.";
    set(handles.InformationText, 'String', str);
end

guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%
% Helper Functions %
%%%%%%%%%%%%%%%%%%%%

% Initializes the application variables, and Statistics and LabelControl Panels
function [H] = figureInitialization(H)

% Application Variables
H.Labels          = [];              % LBLR Output: Integer labels of dataset
H.ViewingIDX      = [];              % Current IDX of the MOTIF_INDICES
H.Data            = [];              % Dataset to be classified
H.DiscreteDataset = [];              % Discretized version of Dataset
H.MasterPlot      = [];              % Main plot handler
H.ScrollHandler   = [];              % Scroll plot handler
H.MotifPlot       = [];              % Motif plot handler
H.Colors          = [];              % Motif plot colors
H.SubsequencePlot = [];
H.Progress        = [];
H.Colors          = {'r', 'g', 'm', 'c', 'y'};
H.Iterations      = 0;
H.L = {};
% Disable StatisticsPanel and LabelControlsPanel
set(findall(H.StatisticsPanel, '-property', 'enable'), 'enable', 'off');
set(findall(H.LabelControlsPanel, '-property', 'enable'), 'enable', 'off');

% Initialize Statistics Panel
set(H.IterationField, 'String', '0');
set(H.ClassifiedField, 'String', '0.00%');

% Initialize Classification Menu List
set(H.ClassificationMenu, 'String', 'Add New Class');

% Updating Information Text
str = sprintf('To begin, [Program Options]->[Import] to import a dataset, specify a [Length] and hit [Execute]');
set(H.InformationText, 'String', str);

% Helper function to ExecuteButton Callback. Initializes the variables required for LBLR.
function [Labels, DiscreteData, DataIDX] = InitializeLBLR(Data, Bits)

%% INITIALIZATION
Labels       = [];
DiscreteData = [];
DataIDX      = {};

%% INPUT VALIDATION
try 
  validateattributes(Data, {'numeric'}, {'nonempty', 'vector'});
  validateattributes(Bits, {'numeric'}, {'integer', 'scalar', 'positive'});
catch ME
    h = errordlg(ME.message);
    waitfor(h);
    return;
end

%% BEGIN
Labels       = zeros(numel(Data),1);                              % Predicted Lables for corresponding Datapoint
DiscreteData = Normalization(Data, [1 2^Bits], 'Discrete', true); % Discretized dataset which will be modeled during MDL
DataIDX      = {transpose(1:numel(Data))};                        % DataIDX{i} - Contiguous and consecutive unlabeled IDX values

function [MDL_IDX, Scores] = RunMDL(DiscreteData, DiscreteModel, ExclusionRange, DataIDX, MotifIDX)
% Helper function to LBLR. Runs the MDL on each dataset in DatasetIDX using the model specified by
% the Length, and MotifIndex. Returns a list of ordered indices corresponding to 'similar'
% subsequences and a best guess N.

GroupMDL_IDX = cell(numel(DataIDX),1);
GroupScores  = cell(numel(DataIDX),1);

% For each contiguous dataset
for i = 1 : numel(DataIDX)

  % INCLUDES an ExclusionRange of data on each side of the dataset (ensures always in the bounds of the data)
  InclusionData = max(1, DataIDX{i}(1) - ExclusionRange) : min(DataIDX{i}(end) + ExclusionRange, numel(DiscreteData));

  % Runs MDL on the augmented contiguous dataset using the discretized motif as the model
  [tempMDL, tempScores] = MDL(DiscreteData(InclusionData), DiscreteModel);
  GroupMDL_IDX{i}       = InclusionData(tempMDL);
  GroupScores{i}        = transpose(tempScores);

end

% Combines the identified subsequences for each contiguous dataset TO-DO: Figure out why cell2mat does not work here
MDL_IDX = [];
for i = 1 : numel(GroupMDL_IDX)
  MDL_IDX = [MDL_IDX GroupMDL_IDX{i}]; %#ok<*AGROW>
end

Scores = [];
for i = 1 : numel(GroupScores)
  Scores = [Scores; GroupScores{i}];
end

% Order MDL_IDX values by their score
[Scores, I] = sort(Scores);
MDL_IDX = MDL_IDX(I);

% Remove subsequences which are completely overlapped
I = arrayfun(@(x) sum(MDL_IDX < MDL_IDX(x) & MDL_IDX > MDL_IDX(x) - ExclusionRange) == 0 || sum(MDL_IDX > MDL_IDX(x) & MDL_IDX < MDL_IDX(x) + ExclusionRange) == 0, 1:numel(MDL_IDX));
%MDL_IDX = MDL_IDX(arrayfun(@(x) sum(MDL_IDX < x & MDL_IDX > x - ExclusionRange) == 0 || sum(MDL_IDX > x & MDL_IDX < x + ExclusionRange) == 0, MDL_IDX));

Scores = Scores(I);
MDL_IDX = MDL_IDX(I);

MDL_IDX = [MotifIDX MDL_IDX];
 
function [PLOT_HANDLES] = GeneratePlots(Dataset, MotifIndex, Length, Axes, MDL_IDX)
% Helper function to GeneartePlots. Generates plots of subsequences specified by MDL. Returns an
% array of ordered plot handles corresponding to the ordered subsequences specified by the MDL
% indicse.

cla(Axes);
axes(Axes);
hold on;

PLOT_HANDLES = gobjects(length(MDL_IDX),1);

for i = 2 : length(MDL_IDX)
    ph = plot(Axes, GetSubsequence(Dataset, MDL_IDX(i), Length), 'color', [0 0 0 0.5], 'visible', 'off');
    PLOT_HANDLES(i) = ph;
    set(ph, 'ButtonDownFcn', {@LineSelected, ph})
end
PLOT_HANDLES(1) = plot(Axes, GetSubsequence(Dataset, MotifIndex, Length), 'color', 'blue', 'LineWidth', 2);

function LineSelected(ObjectH, EventData, H)
set(ObjectH, 'visible', 'off');

function UpdateSlider(handle, maximumValue, value)
% Helper function to LBLR. Updates the slider's maximum and current value.
set(handle, 'Max', maximumValue);
set(handle, 'SliderStep', [1,1] / (maximumValue - 1));
set(handle, 'Value', min(value + 1, maximumValue));

function UpdateMotifPlots(value, PlotHandles)
% Enables or disables the visibility of MDL identified subsequences in the Motif Plot.

for i = 2 : value
    set(PlotHandles(i), 'Visible', 'on');
end

for i = max(value + 1,2) : length(PlotHandles)
    set(PlotHandles(i), 'visible', 'off');
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

function [Range] = GetRange(IDX, Length)
Range = IDX:IDX + Length - 1;

function [SUBSEQUENCE] = GetSubsequence(Sequence, index, len)
% Returns a subsequence of Sequence with length len beginning at index

SUBSEQUENCE = Sequence(GetRange(index, len));
