function [ outcomeKind, outcomeLevel ] = pickAndEvaluateTrial(DataObject, config)
% Picks a recorded trial at random, evaluates it, and displays the outcome.
%
% This can be run as a post-block callback. To do this, include
% `blockConfig.task.fnHandles.postBlockFn = @pickAndEvaluateTrial` in your
% configuration file.
%
% Args:
%   DataObject: An object with participant records & other session info
%   config: A standard block setting (from trial to block to Screen)
%
% Returns:
%   2-element tuple containing
%
%   - **outcomeKind**: Type of outcome picked (reference, win, or loss)
%   - **outcomeLevel**: Type of choice picked (reference or lottery)
%
% Warning: 
%   This was written in a hurry, and should at some point be refactored.

0; % to prevent sphinx from thinking that the next comment is more docstring

%% 1. Pick an available trial at random
blockIdx = randi(DataObject.numFinishedBlocks);
block = DataObject.blocks{blockIdx};
trialIdx = randi(height(block.data));
trial = block.data(trialIdx, :);
trial.refSide = 1; % Fix the display

% Grab config from the block if it hadn't been passed
% FIXME: This will not work if (a) there are multiple block kinds, (b) there
%   are multiple sessions. We might get the wrong blockConfig and think that
%   it has the right `screenId` / doesn't need `loadPTB`.
if ~exist('config', 'var')
  if ~isempty(Screen('Windows'))
    warning(['PTB seems to be running, but you didn''t pass in the config ', ...
      'argument to use. If you observe unexpected behavior, this might be why.'])
  end
  config = block.config;
end

%% 2. Evaluate the trial
% summary = experimentSummary(DataObject, blockIdx, trialIdx);
[ outcomeKind, outcomeLevel, outcomeColorIdx, trueProb, randDraw ] = evaluateTrial(trial);

%% 3. Draw the trial
% 0. Open PTB window if it isn't yet opened (`isempty(Screen('Windows'))`)
standalone = false;
if isempty(Screen('Windows'))
  standalone = true;
  config = loadPTB(config);
end

% 1. Use drawLotto and drawRef to show the lotto
drawLotto(trial, config);
config.task.fnHandles.referenceDrawFn(config, trial);
Screen(config.device.windowPtr, 'Flip');
% 2. Disappear the non-picked choice
WaitSecs(5);
switch trial.choseLottery
  case 0
    config.task.fnHandles.referenceDrawFn(config, trial);
    msg = 'You have chosen the alternative to the gamble.';
  case 1
    % Determine message to display
    msg = 'You chose the gamble. Random draw got you a ';
    msg = [msg config.draw.lottery.box.colorKey{outcomeColorIdx} ' marble.'];
    %  (3. Re-paint lottery with true probability layout

    if trial.ambigs > 0
      trial.ambigs = 0;
      trial.probs = trueProb;
    end
    drawLotto(trial, config);
    %  4. Draw a line through the chosen random number
    %  5. Highlight the winning amount)
  otherwise
    msg = 'No choice made in this trial.';
end
Screen(config.device.windowPtr, 'Flip');

% 6. Display the final outcome
WaitSecs(1);
if trial.choseLottery == 0
  config.task.fnHandles.referenceDrawFn(config, trial);
elseif trial.choseLottery == 1
  drawLotto(trial, config);
end
txtDims = getTextDims(config.device.windowPtr, msg);
xDim = config.device.screenDims(3)/2 - txtDims(1)/2;
yDim = config.device.screenDims(4) - 20;
DrawFormattedText(config.device.windowPtr, msg, xDim, yDim, [200 200 200]);
Screen(config.device.windowPtr, 'Flip');
disp(randDraw);

% 7. Wait for keypress
waitForKey(config.device.breakKeys);

% 8. If this was a one-off show, close screen
if standalone
  unloadPTB(config);
end
end

function [ outcomeKind, outcomeLevel, outcomeColorIdx, trueLotteryProb, randomDraw ] = evaluateTrial(trial)
% Given a trial row, evaluates it.
%
% Args:
%   trial: A (repeated) type of test within each block
%
% Returns:
%   5-element tuple containing
%
%   - **outcomeKind**: Type of outcome (reference, win, or loss).
%   - **outcomeLevel**: Type of choice (reference or lottery).
%   - **outcomeColorIdx**: An index of the chosen outcome color. 
%   - **trueLotteryProb**: A probability of the lottery that takes into
%     account ambiguity when present.
%   - **randomDraw**: A random selection of a lottery outcome as a win or
%     loss based on the trial probability.

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
