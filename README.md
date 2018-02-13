# Like-Behaviors Labeling Routing (LBLR)

**LBLR** presented in [Efficient and Effective Labeling of Massive Time Series Archives](https://github.com/fmadrid/LBLR/blob/master/Documentation/Efficient%20and%20Effective%20Labeling%20of%20Massive%20Time%20Series.pdf)
(Submitted to KDD 2018) is our solution to the following problem:

```
Given a time series T of length n, we wish to produce an annotation vector A of length n which correctly
annotates T while minimizing the number of accesses to a human annotator.
```
Here you will find the project [Source Code](https://github.com/fmadrid/LBLR/tree/master/SourceCode), [Documentation](https://github.com/fmadrid/LBLR/tree/master/Documentation), and 
[Experimental Results](https://github.com/fmadrid/LBLR/tree/master/Experiments) but be sure to also checkout our project website [LBLR Homepage](http://www.cs.ucr.edu/~fmadr002/LBLR.html).

Though not fully optimized we encourage users to use our application and share any experiences (or issues) they encounter when using our software. Please send any inquiries to fmadr002[at]ucr[dot]edu.

## Getting Started

### Prerequisites

This project requires an installation of [Matlab (R2017b)](https://www.mathworks.com/?s_tid=gn_logo) and the [Communications Toolbox](https://www.mathworks.com/matlabcentral/answers/101885-how-do-i-install-additional-toolboxes-into-an-existing-installation-of-matlab).

### Installing

After installing the required software and toolboxes, simply clone or download the project to your Matlab User Path. To identify your Matlab User Path, run the command `userpath` on the Matlab command line. By default on a Windows 7 or Windows 10 machine, the userpath is `C:\Users\[username]\Documents\MATLAB`. 

To test your setup, simply run the application with the provided test input: `LBLR('Datasets\TestInput.mat')`.

If the application initiated, then setup was successful.

## Using LBLR
The **LBLR** application can be initiated by simply executing `LBLR` in the MATLAB command window. To execute **AutoLBLR**, call `AutoLBLR(...)` with the appropriate parameters (see below)

**AutoLBLR** is an *unsupervised* execution of the **LBLR** application. Instead of deferring to the human annotator (user) **AutoLBLR** will simply apply a classification label to the cluster of subsequences which are 
semantically similar. If AutoLBLR is not running *blind* it will greedily apply the most likely label as indicated by the `SolutionVector` otherwise the label will simply be the current iteration of the algorithm.

```
AutoLBLR(TimeSeries, ModelLength, SolutionVector, ExclusionRange = ModelLength/2, Bits = 4, OPTIONS)
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
```

## Built With

* [Matlab (R2017b)](https://www.mathworks.com/?s_tid=gn_logo)

## Contributing
We are not accepting commits at this time but will be facilitating the means for public contribution in the near future.


## Authors

* **Frank Madrid** - *Initial work* - [fmadrid](https://github.com/fmadrid)

See also the list of [contributors](https://github.com/fmadrid/LBLR/contributors) who participated in this project.

## Acknowledgments

* Thank you to Quentin Chesnais, and Kerry Mauck (paper co-authors) for providing a LBLR case study.
