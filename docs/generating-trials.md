# Generating trials

You want your task to have particular payoffs, probabilities, ambiguities, and other features. You want them to be repeated a particular amount of times, and you want different catch trials for each of your blocks. How can you make this happen?

This article will not go into dividing the trials up into blocks, or generating different trial sets for block sets with different conditions. [You can read about it in Generating blocks.](Generating-blocks.md) Rather, here, we'll assume that we just want to generate the set of trials for a single kind of a block -- say, for a monetary decision-making trial where the subject is choosing on behalf of a friend.

Let's assume that we want to test two levels of ambiguity, `0.2` and `0.4`; five levels of probability, `0.1:0.2:0.9`; and four levels of reward, `10:5:25`. We'd like the reference to be `5` and the loss contingency to be `-2`. (We also want to have a catch trial, but that will come up when we get to [block generation](generating-blocks.md).) We only want each combination to appear (repeat) once.

This we'll define in the block config file, like so:

```matlab
function [ c ] = XYZ_cashConfig(defaults)
% tasks/XYZ/XYZ_cashConfig.m
c.trial.generate.stakes = 10:5:25;
c.trial.generate.probs = 0.1:0.2:0.9;
c.trial.generate.ambigs = [0.2 0.4];
c.trial.generate.reference = 5;
c.trial.generate.stakes_loss = -2;
c.trial.generate.repeats = 1;
% ...and other settings
end
```

There are two other things that PTF asks of you. First, it expects you to define what colors to use for the lottery values (drawn from `s.objects.lottery.box.probColors`). The defaults (set up in `lib/configDefaults.m`) are `[1 2]`; nothing wrong with using those. Second, you'll want to define the intertrial durations, which will be evenly distributed across the trials. (`generateBlocks` will make sure that they remain distributed within each block, but on that later.)

Now, to get the trials, all you need to do is to call `generateTrials`:

```matlab
cashConfig = XYZ_cashConfig;
trials = generateTrials(cashConfig.trial.generate);
```

This will give you all the combinations of the trials. If you added another subfield into `c.trial.generate` -- say, `vertical = [0 1]`, which you'll implement in one of your phase scripts to flip the choice from horizontal to vertical -- it will be randomly distributed among the existing combinations.

Usually, you will not need to invoke `generateTrials` directly -- `generateBlocks` is usually the sufficient wrapper for most needs.

## Advanced demands
### How can we center the ambiguity concealer on a different divider than 0.5?
The `drawLotto` function can handle this, but `generateTrials` currently assumes that all ambiguous trials center on 0.5 and doesn't provide for a different option. Consequently, you might have to generate trials with placeholder values and then replace the generated `probs`.

### How can we make all combinations with the reference values?
Currently, we can't -- multiple reference values would merely get evenly distributed among the combinations of stakes, probabilities and ambiguities. As of now, if you need this to happen, you'll need to modify the `generateTrials` script. Alternately, you can run multiple generations for one reference value each.

# Generating blocks
`generateBlocks` is a convenience function that uses a couple of other config properties to sort out your trials into blocks and insert any catch trials.

Let's say that you wanted to separate the trials you're about to generate into four blocks.

(...)

(The initial versions used `.task.blockLength`, and required that the number of generated trials be evenly divisible by it.)

If you had to do any "weird" advanced things, `generateBlocks` allows you to mix in previously generated trials as the fourth argument. `MDM` does it, like this:

(...)
