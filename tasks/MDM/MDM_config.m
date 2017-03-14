function s = MDM_config()
% MDM_CONFIG Return general block settings for the medical decision-making
%   task by modifying the default ones from `config`.

% Load defaults
s = config();

%% Machine settings
s.device.taskPath = ['tasks' filesep 'MDM'];
s.device.imgPath = [s.device.taskPath filesep 'img'];

%% Features of objects that your task displays
% Inheriting all objects from `config`

%% Non-display settings for the game
% (Maximum) durations of the various stages, in seconds
s.game.constantTrialDuration = true;
s.game.durations.showChoice = 6;
s.game.durations.response = 3.5;
s.game.durations.feedback = 0.5;
s.game.durations.ITIs = [4 * ones(1, 6), 5 * ones(1, 8), 6 * ones(1, 6)];

%% Common block properties
s.game.name = 'MDM';
s.game.preBlockFn = @preBlock;

s.game.trialFn = @runRATrial; % RA-specific trial function
s.game.showChoicePhaseFn = @phase_showChoice;
s.game.referenceDrawFn = @drawRef;
s.game.block.length = 21;

s.game.showChoiceActionFn = @action_display;
s.game.responseActionFn = @action_collectResponse;
s.game.feedbackActionFn = @action_display;

%% Available trial values - are shared across med & monetary tasks!
s.game.levels.stakes = 2:5; % Levels are translated via lookup table
s.game.levels.probs = [.25 .5 .75];
s.game.levels.ambigs = [.24 .5 .74];
s.game.levels.stakes_loss = 1;
s.game.levels.reference = 2;
s.game.levels.colors = [1 2];
s.game.levels.repeats = 4;

% Useful for generation purposes
s.game.block.repeatIndex = 1;
% s.game.block.repeatRow = table(2, NaN, 0, 1, 2, NaN, 5, ...
%   'VariableNames', {'stakes', 'probs', 'ambigs', 'stakes_loss', 'reference', ...
%   'colors', 'ITIs'});
s.game.block.catchTrial = struct('stakes', 2, 'probs', NaN, 'ambigs', [], ...
  'stakes_loss', 1, 'reference', 2, 'colors', NaN, 'ITIs', 5);
s.game.block.repeatRow = generateTrials(s.game.block.catchTrial);
end
