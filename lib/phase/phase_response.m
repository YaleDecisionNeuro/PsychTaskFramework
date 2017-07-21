function [ trialData ] = phase_response(trialData, blockConfig, phaseConfig)
% The response script that handles the display of the response
%   prompt and the eventual response or non-response. 
%
% Takes standard phase script arguments.
%
% Args:
%   trialData: The participant data from a trial
%   blockConfig: The block settings
%   phaseConfig: The phase settings
%
% Returns:
%   trialData: The participant data from a trial.

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
% Time the duration and record the participant response.
%
% Args:
%   trialData: The participant data from a trial
%   blockConfig: The block settings
%
% Returns:
%   trialData: The participant data from a trial.

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
  [ refSide, ~ ] = getReferenceSideAndValue(trialData, blockConfig);
  trialData.choseLottery = keyToChoice(trialData.choice, refSide);
end
