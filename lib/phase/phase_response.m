function [ trialData ] = phase_response(trialData, blockSettings, phaseSettings)
% PHASE_RESPONSE The response script that handles the display of the response
%   prompt and the eventual response or non-response. Takes standard phase
%   script arguments.

%% Helper values
windowPtr = blockSettings.device.windowPtr;

%% Response prompt
drawResponsePrompt(trialData, blockSettings);

%% Draw
[~, ~, phaseSettings.startTimestamp, ~, ~] = Screen('flip', windowPtr);
trialData.respStartTime = datevec(now);

%% Handle housekeeping
if exist('phaseSettings', 'var') && isfield(phaseSettings, 'action') ...
    && isa(phaseSettings.action, 'function_handle')
  trialData = phaseSettings.action(trialData, blockSettings, phaseSettings);
else
  trialData = timeAndRecordResponse(trialData, blockSettings);
end
end

function trialData = timeAndRecordResponse(trialData, blockSettings)
  % TODO: If s.game.durations.response == 0, there shouldn't be a while condition
  % TODO: Abstract into `waitForBackTick`-like function
  % TODO: `elapsedTime` - better name?

  [keyisdown, trialData.rt, keycode, trialData.rt_ci] = ...
    waitForKey({'1!', '2@'}, blockSettings.game.durations.response);

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
    blockSettings.perUser.refSide);
end
