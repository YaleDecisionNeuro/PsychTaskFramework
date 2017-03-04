function [ trialData ] = handleResponse(trialData, trialSettings, blockSettings, callback)
% HANDLERESPONSE The draw script that handles the display of the response
%   prompt and the eventual response or non-response. Takes standard draw
%   script arguments.

%% Helper values
W = blockSettings.device.screenDims(3); % width
H = blockSettings.device.screenDims(4); % height
center = [W / 2, H / 2];
windowPtr = blockSettings.device.windowPtr;

%% Response prompt
Screen('FillOval', windowPtr, blockSettings.objects.prompt.color, ...
  centerRectDims(center, blockSettings.objects.prompt.dims));

% Note when the prompt appeared
Screen('flip', windowPtr);
trialData.respStartTime = datevec(now);

%% Wrap up
trialData = timeAndRecordResponse(trialData, trialSettings, blockSettings);
if exist('callback', 'var') && isa(callback, 'function_handle')
  trialData = callback(trialData, trialSettings, blockSettings);
end
end

function trialData = timeAndRecordResponse(trialData, trialSettings, blockSettings)
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
