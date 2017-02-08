function [ trialData ] = handleResponse(trialData, trialSettings, blockSettings, callback)
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
if exist('callback', 'var') && isHandle(callback)
  trialData = callback(trialData, trialSettings, blockSettings);
end
end

function trialData = timeAndRecordResponse(trialData, trialSettings, blockSettings)
  % TODO: If s.game.durations.response == 0, there shouldn't be a while condition
  % TODO: Abstract into `waitForBackTick`-like function
  % TODO: `elapsedTime` - better name?
  elapsedTime = etime(datevec(now), trialData.respStartTime);
  while elapsedTime < blockSettings.game.durations.response
    % Add sleep(0.05) to not fry the computer?
    [keyisdown, secs, keycode, deltaSecs] = KbCheck;
    % breakKeys = [KbName('2@'), KbName('1!')]
    if keyisdown && (keycode(KbName('2@')) || keycode(KbName('1!')))
      elapsedTime = etime(datevec(now), trialData.respStartTime);
      break
    end
    elapsedTime = etime(datevec(now), trialData.respStartTime);
  end
  trialData.rt = elapsedTime;
  trialData.rt_ci = deltaSecs;

  %% Record choice & assign feedback color
  % TODO: If a function can translate choice + refSide into a lottery choice,
  % this could flag stochastic dominance violations as they happen
  % (or at least make it clearer whether the participant opted for lottery
  % both for evaluation and later analysis)
  if keyisdown && keycode(KbName('1!'))
      trialData.choice = 1;
  elseif keyisdown && keycode(KbName('2@'))
      trialData.choice = 2;
  else % non-press
      trialData.choice = 0;
      trialData.rt = NaN;
  end
end
