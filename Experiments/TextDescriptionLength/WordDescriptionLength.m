CARDINALITY = 26;
MODEL = 'scatters';
WORD = 'shatters';

M = double(MODEL);
W = double(WORD);
ModelCost    = numel(HuffmanEncoding(M));
OriginalCost = numel(HuffmanEncoding(W));

Model = M-W;
ReducedCost = ModelCost;
for i = 1:numel(M-W)
    if Model(i) ~= 0
        ReducedCost = ReducedCost + ceil(log2(CARDINALITY)) + ceil(log2(numel(M)));
    end
end

fprintf('ModelCost:    %d\n', ModelCost);
fprintf('OriginalCost: %d\n', OriginalCost);
fprintf('ReducedCost:  %0.2f\n', ReducedCost);
