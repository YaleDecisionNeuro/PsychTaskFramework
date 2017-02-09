function MDM(observer)
% Modeled on (and largely copy-pasted from) RA.m, to test out image
% implementation

%% Load settings
settings = config_MDM();

%% Setup
% Not setting up saving
KbName(settings.device.KbName);
s = RandStream.create('mt19937ar', 'seed', sum(100*clock));
RandStream.setGlobalStream(s);

Data.observer = observer;
Data.date = datestr(now, 'yyyymmddTHHMMSS'); % FIXME: This should be conditional
if mod(observer, 2) == 0
    settings.perUser.refSide = 1;
else
    settings.perUser.refSide = 2;
end

%% Generate trials
trials = RA_generateTrialOrder(settings.game.levels);
numTrials = height(trials);

trials.stakes_loss = repmat(settings.game.levels.stakes_loss, numTrials, 1);
trials.reference = repmat(settings.game.levels.reference, numTrials, 1);

perBlockITIs = settings.game.durations.ITIs;
trials.ITIs = repmat(perBlockITIs, numTrials / length(perBlockITIs), 1);


% Open window
[settings.device.windowPtr, settings.device.screenDims] = ...
  Screen('OpenWindow', settings.device.screenId, ...
  settings.background.color);

%% Finalize settings
settings.game.trials = trials(1:3, :);
settings.game.trialFn = @MDM_drawTrial;
settings.textures = loadTexturesFromConfig(settings);
% NOTE: Can only load textures with an open window

% Run
Data = runBlock(Data, settings);

% Close window
Screen('CloseAll');
end
