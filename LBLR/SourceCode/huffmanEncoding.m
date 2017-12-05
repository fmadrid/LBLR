function E = huffmanEncoding(T)
%E = encoding - Performs Huffman Encoding on a sequence
%   Inputs:
%       T - Sequence of discrete values
%
%   Outputs:
%       E - Huffman encoding of T

%% BEGIN
% Get the unique symbols in T
S = unique(T);

% Count the number of occurences of symbol S(i) in T
O = zeros(length(S));
for i = 1 : length(S)
    O(i) = length(find(T == S(i)));
end

% Calculate the probability vector of each symbol in S
P = O / sum(O);

% Calculate the Huffman Encoding of D
E = huffmanenco(T, huffmandict(S, P));

