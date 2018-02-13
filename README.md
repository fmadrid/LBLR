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


## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone who's code was used
* Inspiration
* etc
