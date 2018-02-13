ROOTFOLDER = 'C:\Users\fmadr\Desktop\Research\LBLR\Experiments\AutoLBLR\EPG';
FOLDERS{1} = [ROOTFOLDER '\EPG1 - Length 80 Bits 4'];
FOLDERS{2} = [ROOTFOLDER '\EPG1 - Length 90 Bits 4'];
FOLDERS{3} = [ROOTFOLDER '\EPG1 - Length 100 Bits 4 - A'];
FOLDERS{4} = [ROOTFOLDER '\EPG1 - Length 110 Bits 4'];
FOLDERS{5} = [ROOTFOLDER '\EPG1 - Length 120 Bits 4'];

Samples = numel(FOLDERS);

X = cell(Samples,1);
Y = cell(Samples,1);

for i = 1 : Samples
  N = numel(importdata([FOLDERS{i} '\Labels.mat']));
  Y{i} = 1-(importdata([FOLDERS{i} '/Completion.mat']));
  X{i} = -100/N:100/N:1.0;
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

legend('L = 80', 'L = 90', 'L = 100', 'L = 110', 'L = 120');