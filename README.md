# Generalized framework for risk-and-ambiguity tasks in PsychToolBox
## Intro
This repository is still in the process of being re-written. The most prominent result is that some settings aren't clearly defined except by their practical use; some settings are intertwined with others without a clear indication of this; and some things (most prominently, object positioning) have not been refactored into settings at all.

In my defense, most functions are well-commented and the modular design means that each file should be a self-contained chunk of code that shouldn't be difficult to understand. Nonetheless, if you find yourself struggling, [file an issue and tag it as `question`](https://git.yale.edu/levylab/RNA_PTB_task/issues/new).

This README is a work in progress as well.

## Structure
If you were familiar with the old task code, you'll notice that there are now many more files. I promise that this will make orienting yourself easier, not harder. Many of these files are helper functions that you will be able to reuse if needed and won't have to worry about if not.

But some are important.

There are, in all, four levels of abstraction. The topmost is **main task script**; in the current repository, it's `RA.m` or `MDM.m`. These are the files that define the big picture of how the task is run -- set the settings, define the order of blocks, etc. This is the file you run; and this is the file you'll change.

The one underneath it is the **block script**. This one is almost always implemented by vanilla `runBlock` and you might not have to touch it at all -- everything you need it to do, you specify in the task script. That includes even...

...the **trial script**. This layer calls each part of the task -- the display of the choice, the response prompt, the feedback display, the intertrial period, and any other you choose to define. Its responsibility is to collect data from these subparts and pass them around as needed.

And we call each part of the task a **draw script**. Generally, a draw script will do three things: (1) draw something on the screen, and (2) keep it there until some time elapses or a condition (like user pressing a key) is met, and (3) collect any relevant data (like the user response, or the timing, or anything else you might want). After that, it's done! It returns the collected data back up to the trial script, and the trial script will call the next draw script until the trial is done, and then it will return its data to the block script, which will run the next trial, and ...

And all of these are affected by configuration, about which we'll talk about later.

## Configuration
Your main task script will get its settings from `config()` (or, if you write your own, `TASKNAME_config()`). It returns a `struct` with useful default values, that you can nonetheless change at will, between blocks. Some of these changes are essential; for instance, everything breaks unless you save the pointers `Screen('OpenWindow')` returns to you. Others you can do without.

I've divided the config struct into a couple of categories. You don't have to abide by them, but you will make yourself (and everyone who'll work on your code after you're long done with it) happier if you do.

## Code recycling and re-use
Recycle as much as you can. If you can effect a change using a different callback function only, everything will be a delight.

That said, sometimes your needs are more complex and you just need to roll your own code. What then?

## Common issues
### Using images or extended text as values
* Save image paths in `settings.(...).img` (the name of the final subfield is key here). `loadTexturesFromConfig` will then convert them into a format that PsychToolBox can use.
* Lookup tables.
* Look at `MDM` task and its sub-parts to see an implementation example.

### Capturing key presses
* Currently done with `KbCheck` -- see e.g. `handleResponse.m`. Issues #9 and #10 might change (and improve) this, but that's the way for now.

### Extracting collected data from the data files
* Data is collected per-block in `Data.recordedBlocks`. Writing an extraction script is on the list; if you keep collecting the same data, it will be very easy to do.
