function pickAndEvaluateTrial(DataObject, settings)
% ConductLottery Picks a recorded trial at random and evaluates it.
%
% Three parts to this logic:
% 0. Pick a trial at random
% 1. Get the trial and calculate its outcome
% 2. Display the outcome
%
% Both should be extracted into their own separate logic, at least in part.
%
% - What should be retrieved? Trial info, choice info, display info
% - What should the function do? Draw the selection process.
% - What should the function return? Selected trial row, kind of outcome, and level of outcome?

%% 1. Pick a trial at random
blockIdx = randi(DataObject.blocks.numRecorded);
block = DataObject.blocks.recorded{blockIdx};
trialIdx = randi(height(block.records));
trial = block.records(randi(trialIdx), :);

%% 2. Evaluate the trial
% summary = experimentSummary(DataObject, blockIdx, trialIdx);
[ outcomeKind, outcomeLevel, trueProb, randDraw ] = evaluateTrial(trial);

%% 3. Draw the trial
% Steps:
%  1. Factor out code from XYZ_drawTask so that it can be re-used here
%  2. Disappear the non-picked choice
%  (3. Re-paint lottery with true probability layout
%  4. Draw a line through the chosen random number)
%  5. Highlight the winning amount
end

function [ outcomeKind, outcomeLevel, trueLotteryProb, randomDraw ] = evaluateTrial(trial)
% EvaluateTrial Given a trial row, evaluates it.
if trial.choseLottery == 0
  outcomeKind = 'Reference';
  outcomeLevel = trial.reference;
else
  % Conduct lottery
  ambig = trial.ambigs;
  if ambig > 0
    minProb = (1 - ambig) / 2;
    trueLotteryProb = minProb + ambig * rand;
  else
    trueLotteryProb = trial.probs;
  end

  randomDraw = rand;
  if randomDraw <= trueLotteryProb
    outcomeKind = 'Win';
    outcomeLevel = trial.stakes;
  else
    outcomeKind = 'Loss';
    outcomeLevel = trial.stakes_loss;
  end
end
end
