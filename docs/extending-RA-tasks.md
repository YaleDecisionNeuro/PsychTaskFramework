# Extending risk & ambiguity tasks

1. Decide which task is most like yours, because we have five to choose from, and copy it.
2. Articulate the differences and read the configuration documentation to figure out which fields you have to change. See if you need to alter any of the common functionality or make your own, or if you just need a different config. (Helpful in this regard: look over phase scripts, draw scripts, and action scripts. Also look over the [FAQ](FAQ.md) to see if the change that you wish to make has been described.)


3. Create a config for your task, plus one config for each of your conditions.

## Example: Using MDM to make SODM

(...)

## How can I add something to the task? The case of the SODM lottery

The general approach is as follows:

1. look for a usable function in the standard library,
2. decide at which point in the task you would like this thing to happen. In every trial? After every block? At the end of each session?
3. Write the logic of your little something in  atask-specific function! (Even though it would be nice if you could contribute any generally reusable logic back to the framework.)

The trickiest thing is getting the PsychToolbox reference that will allow you to use the same `Screen`, and here’s how you do it.

(TODO: Add details.)