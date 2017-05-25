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

(TODO: this are two examples that I'll actually have to write)

### Actions
The other thing that defines phases is the interaction with the participant. Are you waiting for the press of any key before you progress to the next phase? Is there a specific choice to be made? Or are you just waiting for five seconds and then moving on?

As you noticed in the example above, duration can sometimes be dependent on action. Consequently, even in cases when the duration is constant and preset, the action is responsible for executing it.

In the example of reversal learning, let's end the phase after 10 seconds or whenever the user responds, whichever comes first.

As luck would have it, this is one of the functions from the common library, specifically `lib/action/action_collectResponse.m`. Go take a look at it; I'll wait.

## elements + action = phase abstraction

The framework implements this abstraction in the `phaseConfig` structure. It is used like so:

```matlab
phaseConfig('name', 'showChs is a very productiveoice', ...
  'duration', 10, ...
  'phaseScript', @phase_generic, ...
  'action', @action_collectResponse, ...
  'drawCmds', {@drawCue, @drawInstruction})
```

You can also supply the arguments in order without naming them, like so:

```matlab
phaseConfig('cuePrompt', 10, @phase_generic, ...
  @action_collectResponse, {@drawCue, @drawInstruction})
```



## Many phase abstractions make a trial
This is all a trial is: a set of phases following one another.

```matlab
s.trial.phases = { ...
  phaseConfig('showChoice', Inf, @phase_showChoice, @action_collectResponse), ...
  phaseConfig('feedback', 0.5, @phase_generic, @action_display, @drawFeedback), ...
  phaseConfig('ITI', 2, @phase_ITI, @action_display)};
```