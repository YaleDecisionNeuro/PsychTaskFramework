## Test Suite

PsychTaskFramework uses a combination of [http://sikulix.com/](http://sikulix.com/) and the [Robot Framework](http://robotframework.org/) to test the correctness of its visual output. Broadly speaking, it compares the visual output to a previously taken screenshot.

To get started with Sikuli, you will need the Java Runtime Environment (see more in the [Quickstart](http://sikulix.com/quickstart/). To get started with Robot Framework, you will need a Python installation (I recommend [Anaconda](https://www.continuum.io/downloads)) and pip (which comes with Anaconda). Installing the necessary component is as easy as `pip install robotframework robotframework-SikuliLibrary`. (The latter is an effortless connector between the framework and Sikuli.)

To run the tests, navigate to your PsychTaskFramework folder on the command line and run `pybot.bat test/`. This should launch Matlab, invoke the test scripts, and compare them to the previously recorded screenshots.

(If you have multiple screens, you might have to coerce your task to be printed onto the primary one. Unfortunately, Sikuli cannot check all monitors at once.)