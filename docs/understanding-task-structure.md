# Understanding task structure

If you were familiar with the old task code, you'll notice that there are many more files in PTF. They fall into different levels of abstraction.

## The five levels of abstraction

There are, in all, five levels of abstraction. The topmost is **main task script**; in the current repository, it's `RA.m` or `MDM.m`. These are the files that define the big picture of how the task is run -- set the settings, define the order of blocks, etc. This is the file you run; and this is the file you'll change.

The one underneath it is the **block script**. This one is almost always implemented by vanilla `runNthBlock` and you should not have to touch it at all -- everything you need it to do, you specify in the task script. That includes even...

...the **trial script**. This layer calls each part of the task -- the display of the choice, the response prompt, the feedback display, the intertrial period, and any other you choose to define. Its responsibility is to collect data from these subparts and pass them around as needed. 

And we call each part of the task a **phase script**. Generally, a phase script will do three things: (1) direct something to be drawn on the screen, (2) keep it there until some time elapses or a condition (like user pressing a key) is met, and (3) collect any relevant data (like the user response, or the timing, or anything else you might want). We call the first thing that the phase script does a **draw script**, whose responsibility it is to draw a single element. The latter two things, duration and user interaction, are the domain of an **action script**.

## Chain of command

You can tell that these abstractions rely on one another. They go in both directions.

Down from the top, the main task script determines one block to run, the block script determines what trial to run, the child script determines what phase script to run, and the phases script determines what to draw and what action to take.

And back from the bottom, the action script collects a user keypress, the phase script passes it on to the trial script, which both stores it and passes it to the next phase. When all the phases in the trial are done, the trial returns the data back to the block, which runs the next trial. When all trials in the block are done, the block returns the data back to the main task script, which runs the next block, or does whatever else you tell it to.

## More than sum of its parts

The useful thing about PTF is that it's easy to substitute one script at a particular level of abstraction for another. Read more in [the life-changing magic of function handles](function-handles.md).