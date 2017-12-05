function E = encoding(T,H)
%E = encoding - Returns an encoding of T using H
%   Inputs:
%       T,H - Sequence of discrete values
%
%   Outputs:
%       E - Encoding of T using H: E = T - H

%% BEGIN
% Calculate the difference vector H - T
E = H - T;