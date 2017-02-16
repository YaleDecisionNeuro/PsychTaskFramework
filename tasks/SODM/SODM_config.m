function s = SODM_config()
% SODM_CONFIG Return general block settings for the medical decision-making
%   task by modifying the default ones from `config`.

% Load defaults
s = config();

%% Machine settings
s.device.screenId = 1; % 0 for current screen, 1 for a second screen
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
s.game.preBlockFn = @preBlock;

% Useful for generation purposes
s.game.block.length = 10; % FIXME: How many trials in each block?

%% Available trial values
s.game.levels.probs = [.25 .5 .75];
s.game.levels.ambigs = [.24 .5 .74];
s.game.levels.colors = [1 2];
s.game.levels.repeats = 1;
end
