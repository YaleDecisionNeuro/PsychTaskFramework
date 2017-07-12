# Extending risk & ambiguity tasks

1. Decide which task is most like yours, because we have five to choose from, and copy it.
2. Articulate the differences and read the configuration documentation to figure out which fields you have to change. See if you need to alter any of the common functionality or make your own, or if you just need a different config. 

   (Helpful in this regard: read [The life-changing magic of function handles](function-handles.md); look over phase scripts, draw scripts, and action scripts in the town library; and look over the [FAQ](FAQ.md) to see if the change that you wish to make has been described.)


3. Create a `config` for your task, plus one `config` for each of your conditions.

## Examples

* [Using MDM to make SODM](examples/SODM-from-MDM.md)

# Adding something to an existing task

The general approach is as follows:

1. decide what feature(s) you need to add,
2. look for a usable function in the standard library (`lib/`),
3. decide at which point in the task you would like this thing to happen. In every trial? After every block? At the end of each session?
4. Write the logic of your little something in a task-specific function. 
5. If possible, contribute any generally reusable logic back to the framework.

## Tricky things

* PsychToolbox knows what screen to draw on through a screen ID. This is stored in `config.device.screenId`. This means that you need to pass the `config` object, or at least this particular subfield, to most of your features.

## Examples

* [Adding a lottery evaluation to SODM](examples/SODM-lotto-extension.md)