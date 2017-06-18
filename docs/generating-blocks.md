# Generating blocks
So you've got your trials lined up, one way or the other.

`generateBlocks` is a convenience function that uses a couple of other config properties to sort out your trials into blocks and insert any catch trials.

Let's say that you wanted to separate the trials you're about to generate into four blocks.

(...)

(The initial versions used `.task.blockLength`, and required that the number of generated trials be evenly divisible by it.)

If you had to do any "weird" advanced things, `generateBlocks` allows you to mix in previously generated trials as the fourth argument. `MDM` does it, like this:

(...)