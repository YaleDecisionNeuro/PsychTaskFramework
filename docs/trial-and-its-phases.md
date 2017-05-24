# Trials and phases
A laboratory task consists of many parts. Each task has many blocks, each block has many trials, each trial consists of a number of phases. It is useful to start at the bottom and build our way up.

In this part, we'll look at creating a single trial out of a number of phases.

## Example of a task
Let's say that you want to test a reversal learning paradigm. You sure your participants different patterns; Anytime they see a pattern, they press a key that corresponds to the outcome that they think will occur after the pattern. (This is a poor man's way of testing learning: without fear and electric shocks.)

In this case, you have three phases. First, the cue display, during which you also collect participant predictions. Second, the contingency display, during which you display the outcome. Third, the inter-trial period, during which your participants get to rest for a bit.

## Part 1: Anatomy of a phase
In general terms, a Phase is defined by three things.

**First, what's shown.** For cue display, it's the cue; for contingency display, it's the contingency.

**Second, for how long it's shown.** Is the cue shown to the participants for five seconds? Ten seconds? Until they record their answers?

**Third, what interaction is expected and recorded.** In the cue display phase, we expect the participants do hit a key. In the other phases, we don't.

PsychTaskFramework thinks of phases in terms of these abstractions. Consequently, the simplest way to define the phase is to list the parts it consists of.

### Drawing elements
This framework uses PsychToolbox for the underlying drawing. It thinks of the drawings onscreen as a set of independent elements. Consequently, if you wanted to draw the cue any text that says "please press key now", you could separate the two into two distinct scripts.

(example)

### Defining actions
(collecting keystrokes or not?)

(...) As you noticed in the example above, duration can sometimes be dependent on action. Consequently, even in cases when the duration is constant and preset, the action is responsible for executing it.

In this example, let's end the phase after 10 seconds or whenever the user responds, whichever comes first.

(example)

## elements + action = phase abstraction

(example of the data structure)

## Many phase abstractions make a trial
This is all a trial is: a set of phases following one another.