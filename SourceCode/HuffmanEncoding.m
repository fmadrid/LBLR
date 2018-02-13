function Encoding = HuffmanEncoding(T)
%Encoding = HuffmanEncoding(T)
%    Calculates the Huffman Encoding of T.
%    Inputs:
%        T - Vector of numerical values
%    Outputs:
%        Encoding - Huffman encoding of T
%
%    License to use and modify this code is granted freely without warranty to all, as long as the original author is
%    referenced and attributed as such. The original author maintains the right to be solely associated with this work.
%
%    Programmed and Copyright by Frank Madrid: fmadr002[at]ucr[dot]edu
%    Date: 02/12/2018

%% INPUT VALIDATION
p = inputParser;
paramName     = 'T';
validationFcn = @(x) validateattributes(x, {'numeric'}, {'nonempty', 'vector'});
addRequired(p, paramName, validationFcn);

p.parse(T);

%% BEGIN
A = tabulate(T);  % Matrix whose first column contains the values [1:unique(T)] and third column contains the percentage frequency.

% Get the unique symbols and associated probabilities of the values of T
Symbols       = A(A(:,2) ~= 0, 1);
Probabilities = A(A(:,2) ~= 0, 3) / 100;

if(numel(Symbols) == 1) Encoding = 1;
else                    Encoding = huffmanenco(T(~isnan(T)), huffmandict(Symbols, Probabilities));
end
