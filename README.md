# Generalized framework for risk-and-ambiguity tasks in PsychToolBox
This README only contains basic instructions. For more detailed stuff, [see the docs](https://github.com/YaleDecisionNeuro/PsychTaskFramework/blob/master/docs/).

## Installation
The framework was tested with MATLAB 2016b and Psychophysics Toolbox v3.0.12. The oldest version of MATLAB that it can work with is 2013b, but **do use the latest version of both MATLAB and PsychToolBox available to you**. The installation process of PsychToolBox is a little involved, so please [follow the instructions here](http://psychtoolbox.org/download).

To use the framework, fork this repository and then clone it on your local setup. [The process is described here.](http://blog.scottlowe.org/2015/01/27/using-fork-branch-git-workflow/) (If you wish to make it easy for me to provide support, please use this approach. That way, I'll be able to see what changes you've made and which version you're using, and you'll be able to pull my general improvements to your instance. Alternatively, though, you can [download the latest release](https://github.com/YaleDecisionNeuro/PsychTaskFramework/releases/latest) and unzip it wherever you need.)

## Getting started
### Moving around
Generally speaking, the framework is organized in the following way:

1. **Master scripts** -- the scripts you run for each subject -- are in the topmost folder. In the current release, it is `RA` (for the monetary loss-and-gains task), `MDM` (for the medical-and-monetary task), `SODM` (for the self-other medical-and-monetary task) and `UVRA` (for the monetary task arranged vertically with unlimited response time).
2. **Task-specific functions** live in `tasks/`. Specifically, functions for task `XYZ` live in `tasks/[XYZ]/`. These are for (1) config files, (2) custom function files, (3) any image files in `img/` folder.
3. **General-purpose functions** live in `lib/`. You should be able to do most anything with them. They are documented below.

This is the annotated directory structure of the project:

```
├── MDM.m
├── RA.m
├── SODM.m
├── UVRA.m
├── lib
│   ├── action
│   │   └── (...functions for implementing per-phase action...)
│   ├── draw
│   │   └── (...functions for drawing individual display elements...)
│   ├── export
│   │   └── (...functions for data export...)
│   ├── helpers
│   │   └── (...miscellaneous...)
│   ├── input
│   │   └── (...functions for keyboard interaction...)
│   ├── phase
│   │   └── (...functions for each "phase" of a trial...)
│   ├── setup
│   │   └── (...functions for setting up your task and your run...)
│   └── (...general-use functions...)
└── tasks
    ├── MDM
    │   ├── (...task-specific files...)
    │   └── img
    │       └── (...image files...)
    ├── HLFF
    │   ├── (...task-specific files...)
    │   └── img
    │       └── (...image files...)
    ├── RA
    │   └── (...task-specific files...)
    ├── SODM
    │   ├── (...task-specific files...)
    │   └── img
    │       └── (...image files...)
    └── UVRA
    │   └── (...task-specific files...)
```

### Using existing tasks
The scripts are written so that if you run them without an argument, they run a shorter "practice" version of the task that doesn't get recorded (e.g. `RA()` or `RA` will run the practice for the monetary loss-and-gains task). This is useful for getting acquainted with the tasks.

If you wish to record the data for a subject, run the task script with a numeric argument that is the ID of the subject, e.g. `RA(116)` for subject 116. The script will automatically create a data file in `tasks/RA/116.mat`.

Unless you set `config.debug` to `false` in your task configuration, your task will run in a debug mode. This makes task display transparent, so you'll be able to see what and where you're typing if you choose to abort the task before its finish. (You should do this with `Ctrl-C`. Then, when you see that you can write in the MATLAB command window, run the command `sca`, which is short for PsychToolBox's `Screen('CloseAll')`.)

### Extending the existing tasks
The configuration for task `XYZ` is in `tasks/XYZ/XYZ_blockDefaults.m`. If there are two kinds of blocks, `A` and `B`, the convention is that these are in `tasks/XYZ/XYZ_blockDefaults_A.m` and `tasks/XYZ/XYZ_blockDefaults_B.m`. If you wish to see the configurable values, please take a look at `lib/configDefaults.m`, from which all task configurations inherit default values.

See: [Extending risk & ambiguity tasks](https://github.com/YaleDecisionNeuro/PsychTaskFramework/blob/62_docs/docs/extending-RA-tasks.md).

### Writing your own tasks
A cookbook and proper documentation is forthcoming. If you need to do this now, I recommend taking a look at one of the tasks and walking through the call stack. (MATLAB's "Set breakpoint" feature allows the execution to stop at an arbitrary point. Other debugging features -- especially "Step", "Step in" and "Step out" -- can take you through the code execution one step at a time.)

See: [Creating tasks.](https://github.com/YaleDecisionNeuro/PsychTaskFramework/blob/master/docs/creating-task.md)

## This is a beta
This repository is still in the process of being re-written. The most prominent result is that some config aren't clearly defined except by their practical use; some config are intertwined with others without a clear indication of this; and some things (most prominently, object positioning) have not been refactored into config at all.

In my defense, most functions are well-commented and the modular design means that each file should be a self-contained chunk of code that shouldn't be difficult to understand. Nonetheless, if you find yourself struggling, [file an issue and tag it as `question`](https://github.com/YaleDecisionNeuro/PsychTaskFramework/issues/new).

This `README` is a work in progress as well. Please let me know how I can improve it -- or, better still, improve it yourself!
