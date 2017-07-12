# Creating your own task

(See [Understanding task structure](understanding-task-structure.md) first.)

Here’s the general gist. (Note: I go back and forth on the order of this, and should come back to it when I actually write a fresh task. It also seems clear that we need `tryX` from #34.)

1. Create a master task script. You can take a look at the existing ones at the root of the repository, all of which contain the following:

* getting configuration from a configuration function (for starters, you can use `configDefaults`),
* loading PsychToolbox with `loadPTB`,
* getting some blocks with trials in them,
* iterating through a cell array of blocks and running them one by one by feeding them to `runNthBlock`,
* unloading PsychToolbox with `unloadPTB`.

You will be able to use this as an empty skeleton as a test of sorts – keep running it and see where it fails.

2. [Define the phases of your trial, what to draw, and when.](trial-and-its-phases.md)
3. [Create the configuration files.](configuring-task.md) How many depends on how many different kinds of blocks you have, because technically, all configuration files are configuration files for a block. Most tasks have a base configuration file, and one configuration file per condition which starts by getting the shared configuration from the base file.
4. For each of your conditions, [generate your trials](generating-blocks.md) and [sort them into blocks](generating-blocks.md).

### Maintaining layer responsibilities

Technically, you're not constrained by anything when you write your own scripts -- they can do whatever, take whatever inputs and return whatever outputs suit you best. The current best practice, however, is to maintain a separation of responsibilities and have a common interface for all functions in the same layer.

(This is a bit like the intro, but more specific in its enumeration.)

- Task scripts load the settings; populate it with session values; load or create the participant data file; if needed, generate trials for the participant; open PTB screen; run whatever blocks necessary, with whatever settings necessary; and close the screen. Typical call to the block is `Data = runBlock(Data, settings);`.
- Block script receives the participant data and the settings specific to it. It iterates through the trials that it's been set to display, providing the trial script trial-specific settings and storing each trial's data. After all trials are finished, it appends the collected data and the settings used to `Data.recordedBlocks`.
- Trial scripts determine what order the trial phases should be displayed in; it passes to them, and receives from them, the gradual collection of data in the trial. It returns this data to the block script. Typical call to the trial script is `trialData = runTrial(trialSettings, blockSettings);`.
- Task scripts determine what to display and for how long. They collect data and turn it back over to the trial script. The typical call is `trialData = handleResponse(trialData, blockSettings);`.

------

The fewer changes you can make, and the more code you can recycle, the easier it will be for future lab members to decode what you were doing. Also, the fewer changes you make, the easier it will be for you to update to future versions of this toolset! So, whenever you can, look for the smallest re-write you have to do.

