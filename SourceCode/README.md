# Source Code

This folder contains the source code for **LBLR** and **AutoLBLR** in addition to the many utility functions used by this two files. The **LBLR** program can be initiated by simply executing `LBLR` in the Matlab command window. For examples on how to use **AutoLBLR** please see [Experiments - RUNME.MD].

## Program Entry Point
The LBLR application can be initiated by simply executing `LBLR` in the MATLAB command window. To execute AutoLBLR, call `AutoLBLR(...)` with the appropriate parameters (see below)

```
function [Labels, PlotHandles, CompletionPercentage] = AutoLBLR(TimeSeries, ModelLength, SolutionVector, ExclusionRange = ModelLength/2, Bits = 4, OPTIONS)
```
AutoLBLR is an "unsupervised" execution of the LBLR application. Instead of deferring to the human annotator (user) AutoLBLR will simply apply a classification label to the cluster of subsequences which are semantically similar.
If AutoLBLR is not running "blind" it will greedily apply the most likely label as indicated by the `SolutionVector` otherwise the label will simply be the current iteration of the algorithm.
    Inputs:
        TimeSeries     -
        ModelLength    -
        SolutionVector - 
        
    Outputs:
        Labels               -
        PlotHandles          -
        CompletionPercentage - 
        
    Options
        Blind             -
        ShowPlot          -
        Colors            -
        Debug             -
        MaximumIterations -