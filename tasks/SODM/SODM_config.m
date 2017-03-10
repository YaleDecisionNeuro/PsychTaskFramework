function s = SODM_config()
% SODM_CONFIG Return general block settings for the medical decision-making
%   task by modifying the default ones from `config`.

% Load defaults
s = config();

%% Machine settings
s.device.taskPath = ['tasks' filesep 'SODM'];
s.device.imgPath = [s.device.taskPath filesep 'img'];

%% Features of objects that your task displays
% Inheriting all objects from `config`

%% Non-display settings for the game
% (Maximum) durations of the various stages, in seconds
s.game.durations.choice = 10;
s.game.durations.response = 0;
s.game.durations.feedback = 0.5;
s.game.durations.ITIs = 2;

s.game.constantTrialDuration = false; % Early choice won't add to ITI

%% Block properties
s.game.name = 'SODM';
s.game.responsePhaseFn = NaN;
s.game.preBlockFn = @SODM_preBlock;
s.game.bgrDrawFn = @SODM_drawBgr;
s.game.optionsPhaseFn = @SODM_drawTask;
s.game.referenceDrawFn = @MDM_drawRef;
s.game.bgrDrawFn = @SODM_drawBgr;
% FIXME: Is this the best way of showing the context? Why not SODM_drawTask?

% Useful for generation purposes
s.game.block.length = 19;

%% Available trial values
s.game.levels.probs = [.25 .5 .75];
s.game.levels.ambigs = [.24 .5 .74];
s.game.levels.colors = [1 2];
s.game.levels.repeats = 2;
s.game.levels.stakes = 3:5;
% Actually 2:5, but 3:5 is used for automated trial generation
s.game.levels.stakes_loss = 1;
s.game.levels.reference = 2;

s.game.block.repeatIndex = 1;
s.game.block.catchTrial = struct('stakes', 2, 'probs', NaN, 'ambigs', [], ...
  'stakes_loss', 1, 'reference', 2, 'colors', NaN, 'ITIs', 5);
s.game.block.repeatRow = generateTrials(s.game.block.catchTrial);
end
