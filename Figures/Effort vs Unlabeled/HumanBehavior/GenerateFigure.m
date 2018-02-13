Data{1} = 'WalkSaw.mat';
Data{2} = 'Cutting.mat';
Data{3} = 'Sitting-Standing6.mat';
Data{4} = 'Lying-Sitting22.mat';
Data{5} = 'Standing-Running22.mat';

L(1) = 20;
L(2) = 60;
L(3) = 100;
L(4) = 60;
L(5) = 60;

N(1) = 2734;
N(2) = 16903;
N(3) = 6000;
N(4) = 6000;
N(5) = 6000;

Samples = numel(Data);

X = cell(Samples,1);
Y = cell(Samples,1);

for i = 1 : Samples
  Y{i} = 1-(importdata(Data{i}));
  X{i} = -L(i)/N(i):L(i)/N(i):1.0;
  X{i} = X{i}(1:numel(Y{i}));
end

X2 = cell(Samples,1);
Y2 = cell(Samples,1);
for i = 1:Samples
 X2{i} = [X{i}(end) X{i}(end) + 1];
 Y2{i} = [Y{i}(end) Y{i}(end) - 1];
end

f = figure;
hold on;
xlim([0 1]);
ylim([0 1]);
xlabel('Percentage of effort relative to labeling snippets individually');
ylabel('Percentage of unlabeled data')
cellfun(@(x,y) stairs(x,y), X,Y);
cellfun(@(x,y) plot(x,y, 'color', 'k', 'LineStyle', '--'), X2,Y2);

legend('WalkSaw', 'Cutting', 'Sitting-Standing_HandAccel2', 'Lying-Sitting_HandAccel2', 'Standing-Running_ChestAccel2');