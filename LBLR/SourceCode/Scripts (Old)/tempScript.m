diffTracker = cell(length(diffMatrix),1);

for i = 1:length(diffTracker)
    [Values,I] = sort(diffMatrix(i,:));
    diffTracker{i} = [I; Values];
end

simTracker = [];
for i = 1:length(diffTracker)
    simTracker = [simTracker; diffTracker{i}(1,:)];
end

classTracker = zeros(35,35);
classTracker = classTracker + ((simTracker >= 1 & simTracker <= 8) | (simTracker >= 27 & simTracker <= 30));
classTracker = classTracker + 2 * ((simTracker >= 16 & simTracker <= 21) | (simTracker >= 34 & simTracker <= 35));