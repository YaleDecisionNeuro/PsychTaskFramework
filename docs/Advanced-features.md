
See the [README](../README.md) for basics. This is the original & updated version of that README. It might be outdated in parts.

## Structure
If you were familiar with the old task code, you'll notice that there are now many more files. I promise that this will make orienting yourself easier, not harder. Many of these files are helper functions that you will be able to reuse if needed and won't have to worry about if not.

But some are important.

There are, in all, four levels of abstraction. The topmost is **main task script**; in the current repository, it's `RA.m` or `MDM.m`. These are the files that define the big picture of how the task is run -- set the settings, define the order of blocks, etc. This is the file you run; and this is the file you'll change.

The one underneath it is the **block script**. This one is almost always implemented by vanilla `runBlock` and you might not have to touch it at all -- everything you need it to do, you specify in the task script. That includes even...

...the **trial script**. This layer calls each part of the task -- the display of the choice, the response prompt, the feedback display, the intertrial period, and any other you choose to define. Its responsibility is to collect data from these subparts and pass them around as needed.

And we call each part of the task a **phase script**. Generally, a phase script will do three things: (1) direct something to be drawn on the screen, (2) keep it there until some time elapses or a condition (like user pressing a key) is met, and (3) collect any relevant data (like the user response, or the timing, or anything else you might want). After that, it's done! It returns the collected data back up to the trial script, and the trial script will call the next phase script until the trial is done, and then it will return its data to the block script, which will run the next trial, and so on.

At the bottom is a **draw script**, whose responsibility it is to draw a single element. *(There is currently some confusion in the codebase about phase scripts vs. draw scripts; resolving it is near the top of the to-do list.)*

All of these are affected by configuration, about which we'll talk about later. But for now, what to do when you need to change something?

### Changing code, or re-using code?
In re-making our old task into this tool, I paid a lot of attention to re-usability. If you just need to change one thing, you shouldn't have to copy twenty files and make the change in all twenty! This is through two concepts: **composition** and **drop-in functions**.

What do I mean with **composition**? Let's say that you're writing task **XYZ**. How is it different from the standard LevyLab monetary R&A task? Well, it uses a different choice, because you want participants to choose between two brands of candy. But you want to use the same response prompt, feedback, and intertrial period marker as the standard LevyLab R&A task.

Composability means that you'll be able to just write the `XYZ_drawTask.m` and in `XYZ_runTrial.m`, you'll be able to just drop it in, without needing to copy and alter the code of the other "standard" features:

```matlab
function trialData = XYZ_runTrial(trialSettings, blockSettings)
trialData.trialStartTime = datevec(now);
trialData = XYZ_drawTask(trialData, trialSettings, blockSettings);
trialData = handleResponse(trialData, trialSettings, blockSettings);
disp(choiceReport(trialData, trialSettings));
trialData = drawFeedback(trialData, trialSettings, blockSettings);
trialData = drawIntertrial(trialData, trialSettings, blockSettings);
trialData.trialEndTime = datevec(now);
end
```

In fact, if you replace `XYZ` with `MDM`, that would be exactly what `MDM_runTrial.m` could look like, as it re-uses everything other phase from the standard library. (This will be the case for many tasks.)

But you'll have to re-write the block and task scripts to make this work, right? Thanks to the magic of **drop-in functions**, you might avoid this. Basically, all I have to do to make the task script show my participant choices in MDM rather than R&A monetary gambles is to set

```matlab
settings.game.optionsDisplayFn = @MDM_drawTask;
```

The `@` sign refers to a function without running it. (If you didn't use the `@` sign, this line would try to run a trial.) We'll talk about configuration below, but: if you pass a configuration struct with such a line to `runBlock`, it will do all you need it to do.

### What should I be expecting to change?

You'll probably touch the top-level task script (your equivalent of `RA.m`) and, if you make many changes to the default config, you might want to extract it into its own function (see `RA_config.m` for an example).

You'll almost never need to touch the block script `runBlock.m`, or make your own version of it -- almost anything you'd like to do in a block, you can configure in the task script.

You might have to write your own trial script `XYZ_runTrial.m` only if you're changing the order of standard phases (display choice, prompt for response, show feedback, and display intertrial period). You'll be able to set drop-in functions for each of these in `settings.game.*PhaseFn`.

You might have to write some of your own phase and draw scripts, but you might be able to re-use quite a few. (Currently, if you want an element to appear in a different position, you'll need to copy the draw script, change the things, and call the new one from your trial script. I'm working on removing that need.)

### Maintaining layer responsibilities
Technically, you're not constrained by anything when you write your own scripts -- they can do whatever, take whatever inputs and return whatever outputs suit you best. The current best practice, however, is to maintain a separation of responsibilities and have a common interface for all functions in the same layer.

(This is a bit like the intro, but more specific in its enumeration.)

* Task scripts load the settings; populate it with session values; load or create the participant data file; if needed, generate trials for the participant; open PTB screen; run whatever blocks necessary, with whatever settings necessary; and close the screen. Typical call to the block is `Data = runBlock(Data, settings);`.
* Block script receives the participant data and the settings specific to it. It iterates through the trials that it's been set to display, providing the trial script trial-specific settings and storing each trial's data. After all trials are finished, it appends the collected data and the settings used to `Data.recordedBlocks`.
* Trial scripts determine what order the trial phases should be displayed in; it passes to them, and receives from them, the gradual collection of data in the trial. It returns this data to the block script. Typical call to the trial script is `trialData = runTrial(trialSettings, blockSettings);`.
* Task scripts determine what to display and for how long. They collect data and turn it back over to the trial script. The typical call is `trialData = handleResponse(trialData, trialSettings, blockSettings);`.

----

The fewer changes you can make, and the more code you can recycle, the easier it will be for future lab members to decode what you were doing. Also, the fewer changes you make, the easier it will be for you to update to future versions of this toolset! So, whenever you can, look for the smallest re-write you have to do.

## Configuration
Your main task script will get its settings from `config()` (or, if you write your own, `TASKNAME_config()`). It returns a `struct` with useful default values. You can change these by directly accessing the struct.

Some of the changes are essential; for instance, everything breaks unless you save the pointers that `Screen('OpenWindow')` returns to you. Others you can do without.

I've divided the config struct into a couple of categories. You don't have to abide by them, but you will make yourself (and everyone who'll work on your code after you're long done with it) happier if you do.

Rather than explaining every value in full, you should look over `lib/config.m`, `RA_config.m`, and `MDM_config.m` for the possible values. You should also look over `RA.m` and `MDM.m` to see how such config is loaded, and what you need to do between loading it and actually running a task block.

If you've looked at these file and have questions, file them as issues! I might be a bad judge of what's clear and what needs explaining.

## Common issues
### Using images as stakes
PsychToolBox doesn't load images directly. Instead, it makes something called a "texture" from the image you supply, and gives you its ID. This seems annoying, but it's a good design choice -- loading images is computationally expensive and this allows PTB to keep your script spry and its timing reliable.

So how do you make it work when you're defining your task stakes in `settings.game.levels.stakes`?

My current implementation is as follows.

1. In `.levels.stakes`, define your payoffs as integers (e.g. `[1, 4:5]`). Same goes for your reference.
2. In `.lookups.stakes.img`, list in a cell array the paths to the images you'd like to represent each payoff.

   Note 1: **The innermost field must always be named `.img`.** The function we'll introduce in the next step, `createTexturesFromConfig`, will only automatically load and convert to textures the filepaths that it finds in `.img` subfields of your configuration.

   Note 2: **The order in which you list the images matters!** First image in the list will correspond to the payoff of `1`. If you defined `.game.levels.stakes` as `[1: 4:5]`, your `.game.levels.reference` as `7`, and provided `{'img/2.jpg', 'img/5.jpg', 'img/9.jpg'}` in `.lookups.stakes.img`, this will result in your payoff `1` displaying `2.jpg` and it will leave the other payoffs unassociated with any image whatsoever.

   This is because in MATLAB, the invisible "index" of the array is `{1: 'img/2.jpg', 2: 'img/5.jpg', 3: 'img/8.jpg'}`. This is why, if you called `settings.lookups.stakes.img{3}`, you'd get `'img/9.jpg'` as a result.

4. The function that creates the association between your stakes, your images, and PsychToolBox textures is `createTexturesFromConfig`. You should call it before you run your first block, but after you open a PTB window with `Screen('OpenWindow')`, and save its output to `settings`, like so:

    ```matlab
    settings.textures = loadTexturesFromConfig(settings);
    ```

5. When you want to display the texture, you'll use the function `imgLookup` to get the texture from a payoff value, like so:

    ```matlab
    % Draw images
    [ texture1, textureDims1 ] = imgLookup(amtOrder(1), blockSettings.lookups.stakes.img, ...
      blockSettings.textures);
    [ texture2, textureDims2 ] = imgLookup(amtOrder(2), blockSettings.lookups.stakes.img, ...
      blockSettings.textures);

    Screen('DrawTexture', windowPtr, texture1, [], [xCoords(1) yCoords(1) xCoords(1) + textureDims1(1) yCoords(1) + textureDims1(2)]);
    Screen('DrawTexture', windowPtr, texture2, [], [xCoords(2) yCoords(2) xCoords(2) + textureDims2(1) yCoords(2) + textureDims2(2)]);
    ```

This code is lifted verbatim from `tasks/MDM/MDM_drawTask.m`. It's a little abstruse, but: `amtOrder(1)` and `amtOrder(2)` are the top and bottom payoff, respectively. You then supply both the payoff-to-image-path table and the path-to-textureId table that you created and saved earlier. Finally, you display it with coordinates you had computed earlier.

In general, you should look at the scripts that implement `MDM` (i.e. `MDM.m', 'MDM_config.m`, and everything in `tasks/MDM/*`) to understand how this works together.

### Text as values
This is similar as the case for images. Your `stakes` are indices for a lookup table that you'll place in `settings.lookups.(object).txt`. You'll then use `textLookup` in a similar fashion, with one difference: to obtain the text's dimensions, you'll need to supply the ID of the window that PsychToolBox opened to you. If you follow best practice (see e.g. `RA.m`), you'll find this ID in `settings.device.windowPtr`.

The same script I cited earlier, `tasks/MDM/MDM_drawTask.m`, retrieves the text that corresponds to a payoff value in the following way:

```matlab
% Draw text
[ txt1, txtDims1 ] = textLookup(amtOrder(1), blockSettings.lookups.stakes.txt, ...
  blockSettings.device.windowPtr);
[ txt2, txtDims2 ] = textLookup(amtOrder(2), blockSettings.lookups.stakes.txt, ...
  blockSettings.device.windowPtr);

DrawFormattedText(windowPtr, txt1, ...
  xCoords(1), yCoords(1), blockSettings.objects.lottery.stakes.fontColor);
DrawFormattedText(windowPtr, txt2, ...
  xCoords(2), yCoords(2), blockSettings.objects.lottery.stakes.fontColor);
```

Again, `amtOrder(1)` and `amtOrder(2)` are the top and bottom payoff. `blockSettings.lookups.stakes.txt` is the lookup table, and the window pointer is where we said it was. Finally, you display it with the PTB function for text display.

### Displaying values slightly differently
Use existing formatters, or write your own! See `lib/draw/helpers/dollarFormatter.m` and how the `RA` task uses it in `tasks/RA/RA_drawTask.m`.

### Capturing key presses
* Currently done with `lib/waitForKey.m`, which is a wrapper around `KbCheck` for an arbitrary duration of time. If you wish to wait for the press of `5` and `Space` for five seconds, you should invoke `waitForKey({'5%', 'Space'}, 5)`.

### Extracting collected data from the data files
* Data is collected per-block in `Data.recordedBlocks`. You can export all data collected for task 'XYZ' using `exportTaskData('XYZ', '~/Desktop/XYZ.csv')`.

