function [ Data ] = handleResponse(Data, settings, callback)
%% Helper values
W = settings.device.screenDims(3); % width
H = settings.device.screenDims(4); % height
center = [W / 2, H / 2];
windowPtr = settings.device.windowPtr;
trial = Data.currTrial;

%% Response prompt
Screen('FillOval', windowPtr, settings.prompt.color, ...
  centerRectDims(center, settings.prompt.dims));

% Note when the prompt appeared
Screen('flip', windowPtr);
Data.trialTime(trial).respStartTime = datevec(now);

%% Wrap up
Data = timeAndRecordResponse(Data, settings);
if exist('callback', 'var') && isHandle(callback)
  Data = callback(Data, settings);
end
end

function Data = timeAndRecordResponse(Data, settings)
  % TODO: If s.game.responseWindowDur == 0, there shouldn't be a while condition
  % TODO: Abstract into `waitForBackTick`-like function
  % TODO: `elapsedTime` - better name?
  trial = Data.currTrial;
  elapsedTime = etime(datevec(now), Data.trialTime(trial).respStartTime);
  while elapsedTime < settings.game.responseWindowDur
    % Add sleep(0.05) to not fry the computer?
    [keyisdown, secs, keycode, deltaSecs] = KbCheck;
    % breakKeys = [KbName('2@'), KbName('1!')]
    if keyisdown && (keycode(KbName('2@')) || keycode(KbName('1!')))
      elapsedTime = etime(datevec(now), Data.trialTime(trial).respStartTime);
      break
    end
    elapsedTime = etime(datevec(now), Data.trialTime(trial).respStartTime);
  end
  Data.rt(trial) = elapsedTime;
  Data.rt_ci(trial) = deltaSecs;

  %% Record choice & assign feedback color
  % TODO: If a function can translate choice + refSide into a lottery choice,
  % this could flag stochastic dominance violations as they happen
  % (or at least make it clearer whether the participant opted for lottery
  % both for evaluation and later analysis)
  if keyisdown && keycode(KbName('1!'))
      Data.choice(trial) = 1;
  elseif keyisdown && keycode(KbName('2@'))
      Data.choice(trial) = 2;
  else % non-press
      Data.choice(trial) = 0;
      Data.rt(trial) = NaN;
  end
end
