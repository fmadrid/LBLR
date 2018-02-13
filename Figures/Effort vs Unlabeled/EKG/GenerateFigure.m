Data{1} = 'Pig.mat';
Data{2} = 'Pulsus1.mat';
Data{3} = 'Pulsus2.mat';
Data{4} = 'SuddenCardiacDeath.mat';
Data{5} = 'Tilt2.mat';

L(1) = 100;
L(2) = 100;
L(3) = 100;
L(4) = 60;
L(5) = 60;

N(1) = 14973;
N(2) = 17521;
N(3) = 17521;
N(4) = 12001;
N(5) = 40000;

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

legend('Pig', 'Pulsus1', 'Pulsus2', 'SuddenCardiacDeath', 'Tilt2');