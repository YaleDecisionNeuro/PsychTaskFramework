function pickAndEvaluateTrial(DataObject, settings)
% Picks a recorded trial at random, evaluates it, and displays the outcome.
%
% This can be run as a post-block callback. To do this, include
% `blockSettings.game.postBlockFn = @pickAndEvaluateTrial` in your
% configuration file.
%
% FIXME: This was written in a hurry, and should at some point be refactored.

%% 1. Pick an available trial at random
blockIdx = randi(DataObject.blocks.numRecorded);
block = DataObject.blocks.recorded{blockIdx};
trialIdx = randi(height(block.records));
trial = block.records(trialIdx, :);

%% 2. Evaluate the trial
% summary = experimentSummary(DataObject, blockIdx, trialIdx);
[ outcomeKind, outcomeLevel, outcomeColorIdx, trueProb, randDraw ] = evaluateTrial(trial);

%% 3. Draw the trial
% 0. Open PTB window if it isn't yet opened (`isempty(Screen('Windows'))`)
standalone = false;
if isempty(Screen('Windows'))
  standalone = true;
  settings = loadPTB(settings);
end
% 1. Use drawLotto and drawRef to show the lotto
drawLotto(trial, settings);
settings.game.referenceDrawFn(settings, trial);
Screen(settings.device.windowPtr, 'Flip');
% 2. Disappear the non-picked choice
WaitSecs(5);
switch trial.choseLottery
  case 0
    settings.game.referenceDrawFn(settings, trial);
    msg = 'You have chosen the alternative to the gamble.';
  case 1
    % Determine message to display
    msg = 'You chose the gamble. Random draw got you a ';
    msg = [msg settings.objects.lottery.box.colorKey{outcomeColorIdx} ' marble.'];
    %  (3. Re-paint lottery with true probability layout

    if trial.ambigs > 0
      trial.ambigs = 0;
      trial.probs = trueProb;
    end
    drawLotto(trial, settings);
    %  4. Draw a line through the chosen random number
    %  5. Highlight the winning amount)
  otherwise
    msg = 'No choice made in this trial.';
end
Screen(settings.device.windowPtr, 'Flip');

% 6. Display the final outcome
WaitSecs(1);
if trial.choseLottery == 0
  settings.game.referenceDrawFn(settings, trial);
elseif trial.choseLottery == 1
  drawLotto(trial, settings);
end
txtDims = getTextDims(settings.device.windowPtr, msg);
xDim = settings.device.screenDims(3)/2 - txtDims(1)/2;
yDim = settings.device.screenDims(4) - 20;
DrawFormattedText(settings.device.windowPtr, msg, xDim, yDim, [200 200 200]);
Screen(settings.device.windowPtr, 'Flip');
disp(randDraw);

% 7. Wait for keypress
waitForKey(settings.device.breakKeys);

% 8. If this was a one-off show, close screen
if standalone
  unloadPTB(settings);
end
end

function [ outcomeKind, outcomeLevel, outcomeColorIdx, trueLotteryProb, randomDraw ] = evaluateTrial(trial)
% EvaluateTrial Given a trial row, evaluates it.
if trial.choseLottery == 0
  outcomeKind = 'Reference';
  outcomeLevel = trial.reference;
  trueLotteryProb = NaN;
  randomDraw = NaN;
  outcomeColorIdx = [];
else
  % Conduct lottery
  ambig = trial.ambigs;
  if ambig > 0
    minProb = (1 - ambig) / 2;
    trueLotteryProb = round(minProb + ambig * rand, 2);
  else
    trueLotteryProb = trial.probs;
  end

  randomDraw = rand;
  if randomDraw <= trueLotteryProb
    outcomeKind = 'Win';
    outcomeLevel = trial.stakes;
    outcomeColorIdx = trial.colors;
  else
    outcomeKind = 'Loss';
    outcomeLevel = trial.stakes_loss;
    outcomeColorIdx = 2 - (trial.colors - 1); % FIXME: Ugly hack, assumes only two colors indexed 1 and 2
  end
  randomDraw = round(randomDraw, 2);
end
end
