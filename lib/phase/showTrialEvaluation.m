function [outcomeKind, outcomeLevel] = showTrialEvaluation(trial, config)
% Allow users to call this function from wherever they want 
% Be able to receive the trial specification, block configuration. 

% Evaluate the trial: adapted lines 92-end of pickAndEvaluateTrial.
%% 2. Evaluate the trial
% summary = experimentSummary(block, blockIdx, trialIdx);
[ outcomeKind, outcomeLevel, outcomeColorIdx, trueProb, randDraw ] = evaluateTrial(trial);

%% 3. Draw the trial
% 0. Open PTB window if it isn't yet opened (`isempty(Screen('Windows'))`)
standalone = false;
if isempty(Screen('Windows'))
  standalone = true;
  config = loadPTB(config);
  config.runSetup.textures = loadTexturesFromConfig(config);
end


% 1. Use drawLotto and drawRef to show the lotto
config.task.fnHandles.bgrDrawFn(config, trial);
drawLotto(trial, config);
config.task.fnHandles.referenceDrawFn(config, trial);
Screen(config.device.windowPtr, 'Flip');
% 2. Disappear the non-picked choice
WaitSecs(5);
switch trial.choseLottery
  case 0
    config.task.fnHandles.referenceDrawFn(config, trial);
    msg = 'You chose the certain option.';
  
  case 1
  windowPtr = config.device.windowPtr;
    % Determine message to display
    
    % For monetary gamble 
    if strcmp(config.runSetup.blockName, "Monetary") == 1   
        lookupTbl = config.runSetup.lookups.txt;
        message = textLookup(outcomeLevel, lookupTbl, windowPtr);
        msg = 'You chose the gamble. Random draw got you ';
        msg = [msg message];
    end 
    
    % For medical gamble
    if strcmp(config.runSetup.blockName, "Medical") == 1   
        lookupTbl = config.runSetup.lookups.txt;
        message = textLookup(outcomeLevel, lookupTbl, windowPtr);
        msg = 'You chose the experimental treatment. The final result was ';
        msg = [msg message];
    end 
        
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
yDim = config.device.screenDims(4) - 100; %moved text up from bottom of screen
DrawFormattedText(config.device.windowPtr, msg, xDim, yDim, [200 200 200]);
Screen(config.device.windowPtr, 'Flip');
disp(randDraw);

% 7. Wait for keypress
waitForKey(config.device.breakKeys, 5);

% 8. If this was a one-off show, close screen
if standalone
  unloadPTB(config);
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

