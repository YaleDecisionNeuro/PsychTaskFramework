function [ trialData ] = phase_response(trialData, blockConfig, phaseConfig)
% PHASE_RESPONSE The response script that handles the display of the response
%   prompt and the eventual response or non-response. Takes standard phase
%   script arguments.

%% Helper values
windowPtr = blockConfig.device.windowPtr;

%% Response prompt
drawResponsePrompt(trialData, blockConfig);

%% Draw
[~, ~, phaseConfig.startTimestamp, ~, ~] = Screen('flip', windowPtr);
trialData.responseStartTime = datevec(now);
trialData.responseStartTS = phaseConfig.startTimestamp;

%% Handle housekeeping
if exist('phaseConfig', 'var') && isfield(phaseConfig, 'action') ...
    && isa(phaseConfig.action, 'function_handle')
  trialData = phaseConfig.action(trialData, blockConfig, phaseConfig);
else
  trialData = timeAndRecordResponse(trialData, blockConfig);
end
end

function trialData = timeAndRecordResponse(trialData, blockConfig)
  [keyisdown, trialData.rt, keycode, trialData.rt_ci] = ...
    waitForKey({'1!', '2@'}, blockConfig.trial.legacyPhases.response.duration);

  %% Record choice & assign feedback color
  if keyisdown && keycode(KbName('1!'))
      trialData.choice = 1;
  elseif keyisdown && keycode(KbName('2@'))
      trialData.choice = 2;
  else % non-press
      trialData.choice = 0;
      trialData.rt = NaN;
  end
  trialData.choseLottery = keyToChoice(trialData.choice, ...
    blockConfig.runSetup.refSide);
end
