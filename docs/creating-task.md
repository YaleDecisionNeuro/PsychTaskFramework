# Creating your own task

Here’s the general gist. (Note: I go back and forth on the order of this, and should come back to it when I actually write a fresh task. It also seems clear that we need `tryX` from #34.)

1. Create a master task script. You can take a look at the existing ones at the root of the repository, all of which contain the following:

* getting configuration from a configuration function (for starters, you can use `configDefaults`),
* loading PsychToolbox with `loadPTB`,
* getting some blocks with trials in them,
* iterating through a cell array of blocks and running them one by one,
* unloading PsychToolbox with `unloadPTB`.

You will be able to use this empty skeleton as a test of sorts – keep running it and see where it fails.

2. [Define the phases of your trial, what to draw, and when.](trial-and-its-phases.md)
3. [Create the configuration files.](configuring-task.md) How many depends on how many different kinds of blocks you have, because technically, all configuration files are configuration files for a block. Most tasks have a base configuration file, and one configuration file per condition which starts by getting the shared configuration from the base file.
4. For each of your conditions, [generate your trials](generating-blocks.md) and [sort them into blocks](generating-blocks.md).