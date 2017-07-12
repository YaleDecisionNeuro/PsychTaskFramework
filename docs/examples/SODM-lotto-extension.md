## Adding a lottery to the SODM task

*(written by @skim725, edited by @sp576)*

I wanted to implement a trial evaluation at the end of the SODM session, after the subject has made a 
choice on all trials. Moreover, I wanted to evaluate one trial from each condition. Finally, I wanted to the 
progression to the next lottery evaluation to wait for a key press.

### Reusable functionality

The last request was the easiest to do: `input/waitForKey` allows a specification of what key it should wait 
for, and how long.	
The function that existed in the library was `phase/pickAndEvaluateTrial`. It had two main shortcomings: 

1. The more important shortcoming was, to quote issue #73, that the function conflated two things: the selection of block/trial to evaluate, and the evaluation itself. I had to decouple the logic. 
2. Even that logic wasn’t complete: pick a trial from a given block the function could do, but pick one block per condition it couldn’t.
3. Other than that, the function also didn’t actually display outcomes, only color of the marble drawn. I had to extract the value instead of the color.

### Implementation / logic

To get where I needed to go, I did the following things:

1. Factored out the logic from `pickAndEvaluateLottery` that did the actual lottery evaluation and place it in `showTrialEvaluation`,


2. Rewrote `showTrialEvaluation` to show outcomes, not just marbles picked.
3. Wrote `getOneBlockPerCondition`, which will return the indices for n blocks, such that there will be one block from each condition.


4. Created the scaffolding in `SODM_pickTrials`, which: grabs a screen ID to display the lottery evaluation on, gets the four blocks from `getOneBlockPerCondition` & one random trial from each, and evaluates them with `showTrialEvaluation`, all the while pausing until a key is pressed in between each of the four evaluations. 
5. Called `SODM_pickTrials` after all the blocks are run in SODM, the master task script.