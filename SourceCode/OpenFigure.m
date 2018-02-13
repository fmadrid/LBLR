function OpenFigure
% OpenFigure - Opens a figure specified by uigetfile and makes it visible because MatLab is dumb and saved non-visible figures retain their
% non-visible property upon reopening.
%   License to use and modify this code is granted freely without warranty to all, as long as the original author is
%   referenced and attributed as such. The original author maintains the right to be solely associated with this work.
%
%   Programmed and Copyright by Frank Madrid: fmadr002[at]ucr[dot]edu
%   Date: 02/12/2018

InitialDirectory = pwd;
[Filename, Pathname] = uigetfile('*.fig','Select Figure to open', InitialDirectory);
FigToOpen = [Pathname Filename];
openfig(FigToOpen,'new','visible');