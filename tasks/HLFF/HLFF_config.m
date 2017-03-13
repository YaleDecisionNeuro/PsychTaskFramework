function s = HLFF_config()
% HLFF_CONFIG Return general block settings for the high-/low-fat food task
%   designed by Sarah Healy by modifying the default ones from `config`.

% Load defaults
s = config();

%% Machine settings
s.device.taskPath = ['tasks' filesep 'HLFF'];
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
s.game.name = 'HLFF';
s.game.trialFn = @runPhases;
% See lib/phase/phaseConfig.m for meaning
s.game.phases = { ...
  phaseConfig('showChoice', Inf, @phase_showChoice, @action_collectResponse), ...
  phaseConfig('feedback', 0.5, @phase_generic, @action_display, @drawFeedback), ...
  phaseConfig('ITI', 2, @phase_ITI, @action_display)};
s.game.referenceDrawFn = @drawRef;

% Useful for generation purposes
s.game.block.length = 12;
s.game.block.numBlocks = 2;

%% Available trial values
s.game.levels.probs = [.25 .5 .75];
s.game.levels.ambigs = [];
s.game.levels.colors = [1 2];
s.game.levels.repeats = 2;
s.game.levels.stakes = 2:5;
s.game.levels.stakes_loss = 1;
s.game.levels.reference = 2;
end
