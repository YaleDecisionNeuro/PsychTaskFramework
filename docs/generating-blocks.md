# Generating blocks
So you've got your trials lined up, one way or the other.

`generateBlocks` is a convenience function that uses a couple of other config properties to sort out your trials into blocks and insert any catch trials. One thing to note is that `generateBlocks` is really `generateBlocksForCondition`: it assumes that all the blocks that the generates are composed of the same kind of a trial, so you'll have to generate your blocks for each condition separately.

Conditions are handled separately, and their name is set in `config.runSetup.conditions` in your per-condition configuration file. (This will automatically propagate to `DataObject.blocks{…}.conditions`.)

Let's say that you wanted to separate the trials you're about to generate into four blocks.

(...)

(The initial versions used `.task.blockLength`, and required that the number of generated trials be evenly divisible by it.)

If you had to do any "weird" advanced things, `generateBlocks` allows you to mix in previously generated trials as the fourth argument. `MDM` does it, like this:

(...)

## Ordering blocks

When you have your blocks of all conditions ready, you need to load all of these in some defined order into `DataObject.blocks`.

How can you decide order? Typically, you will want to counterbalance based on the last digit of the subject ID. The current tasks err on the side of eliminating repetition, which causes them to be being too clever by half; you can be as verbose as you want, as long as it works. Taking SODM as an example, here are 2 equivalent ways to sort the blocks in four counterbalancing orders:

(...)