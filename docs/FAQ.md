# How do I...

## ...set my installation up without messing up old tasks that rely on older Matlab & PsychToolBox versions?
New Matlab versions don't overwrite the old ones by default. Each versions toolboxes are separate, too. This means that if you install 2017a and run `DownloadPsychtoolbox(differentLocation)` ([see instructions](http://psychtoolbox.org/download/)), you can also have side-by-side non-interfering versions of PTB.

## ...know what things I can configure?
Check out `lib/configDefaults.m`. It has a well-annotated list of settings that the framework recognizes.

## ...know *what config files* to configure?
Here's the basic insight: **all config files configure task blocks**. In practice, though, we find it useful to have some settings in common between the blocks of a single task. Consequently, most tasks have:

1. one config file for defaults for all task blocks, which is usually named `tasks/XYZ/XYZ_blockDefaults.m` and re-uses the config structure from `lib/configDefaults.m`,
2. one config file for each block, which defines the things that the particular block does differently, typically named `tasks/XYZ/XYZ_${condition}Config.m`.

## ...set which keys participants use to make their choices, or to move on from the "when you're ready" screen?
Set `s.device.choiceKeys` and `s.device.breakKeys` in your task's `blockDefaults`. The key names follow convention from PTB's [`KbName`](http://docs.psychtoolbox.org/KbName).

## ...set `breakKeys` to accept any key?
The current way is to set it to `KbName('KeyNames')` or equivalent. This will include all the keys. Simpler way is under development in issue #100.

## ...make the task display not transparent?
This is the product of `c.debug`, which is `true` by default. Set it to `false`.

## ...ensure that my timing is precise to the millisecond?
You'll need to turn off `c.debug` and ensure that PsychToolBox's sync timing is accurate. PsychTaskFramework does use `Screen('Flip')` for accurate timestamps, but you have to set up your machine to take advantage of it.

## ...generate different trial values?
Look at `c.trial.generate` in your block configuration.

## ...add images as payoffs?
Here's the current approach:

1. Add the images to a specific folder. List that folder in your task's config in the `.device.imgPath` subfield.
2. List the image filenames in a cell array in `.runSetup.lookups.img`. You might find the `prependPath` helper function helpful.
3. (If you do this, you currently also have to list the labels that will appear alongside the images in `.runSetup.lookups.txt`. This is a bug that will be addressed in #95.)
3. Change the payoff values in `.trial.generate.stakes`, `.trial.generate.stakes_loss` and `.trial.generate.reference` to correspond to the *indices of the `runSetup.lookups.img` cell array*. That is to say, if your payoff images are `{'explosion.jpg', 'nothing.jpg', 'sprinkles.jpg'}`, and you want the safe reference to be `nothing.jpg` and the potential loss to be `explosion.jpg`, then you would set `stakes` to 3, `stakes_loss` to 1, and `reference` to 2.
4. Use `loadTexturesFromConfig(blockConfig)` to load the images into PsychToolBox.

## ...add images as something else?
Put you image file name(s) into any subfield named `.img`. `loadTexturesFromConfig` will actually attempt to load all subfields named `.img`. `.runSetup.lookups.img` is a special case only because the default draw scripts know to look in it.

## ...load the images?
Use `imgLookup`.

## ...set up blocks to run in a different order?
Currently, the master task script (`XYZ.m`) has full control over the way the blocks are ordered. Load them into `Data.blocks` in whatever order you please.

## ...what the difference is between `config` and `Data`? What goes where?
`Data` is particular to each individual participant. It is saved after each block (or, if so set, after each trial) in `tasks/XYZ/data/subjectId.mat`. Its structure is the following:

```
Data
.subjectId
.filename
.lastAccessed
.numFinishedBlocks
.blocks
```

The field `.blocks` is a cell array; there is one block structure per cell. The cell's contents are as follows:

```
.blocks{k}
	.trials [table]
	.config [struct]
	.conditions [struct]
	.data [table]
	.finished [boolean]
```

`trials` contains the properties of every trial for the given block in a `table`; each trial has a row. `data` contains a `table` that has the trial properties **and** the recorded responses, timing & co. from the subject. `config` has the settings to be used for this block at large; `conditions` is a key -> value `struct` that contains the high-level information about the block (is it medical or monetary? is the subject selecting for themselves or for a friend?). Finally, `finished` is `true` or `false` depending on whether all the trials in the block have been run.

As you see, `config` is merely a part of the block. It is created separately, though, and assigned during trial/block generation.

A different way of looking at this is: you can make changes to the `config` functions in editor, but you can't make such changes to `Data`. (Well, you can if you try hard enough, but you shouldn't.)

## ...set up different blocks to contain trials with different payoffs?
Utilize the per-block configs. See `tasks/MDM/MDM_monetaryConfig.m` and `tasks/MDM/MDM_medicalConfig.m` for an example?

## ...set up blocks that have a completely different trial structure, add a new phase, or change a phase significantly?
This is a question that will get its separate article. The quick answer is that there are two preferred ways:

1. Write your own version of `runRATrial`, in which you invoke an additional phase function (that you'll, presumably, also write), and let PTF know that you'd like to use it by setting `config.task.fnHandles.trialFn = @yourTrialFunction`, or
2. Take advantage of the new `.trial.phases` cell array, which utilizes phase abstraction. (This assumes you're using `runGenericTrial` as your trial function.)

What's a phase abstraction? Each phase is defined by five things: name, duration, script that draws all of its elements (or, alternatively, what elements are drawn), and the action that concludes the phase. This is codified in `PhaseConfig`.

Say that I want to modify the "feedback" phase of the `HLFF` task to wait for the subject to press the break key. The `HLFF` phases are defined thus:

```matlab
% tasks/HLFF/HLFF_blockDefaults.m
s.trial.phases = { ...
  phaseConfig('showChoice', Inf, @phase_showChoice, @action_collectResponse), ...
  phaseConfig('feedback', 0.5, @phase_generic, @action_display, @drawFeedback), ...
  phaseConfig('ITI', 2, @phase_ITI, @action_display)};
```

Now, I don't need to change the script that draws the feedback depiction; all I need is to define a different action. It turns out that PsychTaskFramework already contains one that's useful for just this task: `action_waitForBreak`. Thus, you'd replace `@action_display` with `@action_waitForBreak` and be done!

Now, `phaseConfig` allows you to specify what draw scripts you want to use and let PTF handle the phase. If you wanted to add a phase that only displays the reference for a fraction of a second right after the feedback, you could also do this, using `phaseConfig`'s named arguments:

```matlab
phaseConfig('name', 'refPrime', 'duration', 0.05, ...
	`phaseScript`, @phase_generic, ...
	'action', @action_display, 'drawCmds', @drawRef);
```

This would use `phase_generic` to invoke `drawRef` and wait 0.05 seconds before allowing the trial to move on to the next phase. And the number of own scripts that you had to write? Zero.

(You'll notice that the `HLFF` configuration doesn't list any `showCmds`. That's because phase scripts other than `@phase_generic` already enumerate which draw scripts they use.

In the latter case of the subliminal reference display, you could have left out the `phaseScript` argument, because `phaseConfig` uses `@phase_generic` by default. The other arguments you could omit are duration - it defaults to infinity - and action, which defaults to `@action_waitForBreak`. It doesn't hurt to be complete, though.)
## ...add a special phase, but only for the last trial of the session?
You could write your custom post-block function and set it in `s.task.fnHandles.postBlockFn`.

