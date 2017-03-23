function s = MDM_config()
% MDM_CONFIG Return general block settings for the medical decision-making
%   task by modifying the default ones from `config`.

% Load defaults
s = config();

%% Machine settings
s.task.taskPath = ['tasks' filesep 'MDM'];
s.task.imgPath = [s.task.taskPath filesep 'img'];

%% Features of objects that your task displays
% Inheriting all objects from `config`

%% Non-display settings for the game
% (Maximum) durations of the various stages, in seconds
s.task.constantBlockDuration = true;
s.game.durations.showChoice = 6;
s.game.durations.response = 3.5;
s.game.durations.feedback = 0.5;
s.game.durations.ITIs = [4 * ones(1, 6), 5 * ones(1, 8), 6 * ones(1, 6)];

%% Common block properties
s.task.taskName = 'MDM';
s.task.fnHandles.preBlockFn = @preBlock;

s.task.fnHandles.trialFn = @runRATrial; % RA-specific trial function
s.game.showChoicePhaseFn = @phase_showChoice;
s.task.fnHandles.referenceDrawFn = @drawRef;
s.task.blockLength = 21;

s.game.showChoiceActionFn = @action_display;
s.game.responseActionFn = @action_collectResponse;
s.game.feedbackActionFn = @action_display;

%% Available trial values - are shared across med & monetary tasks!
s.trial.generate.stakes = 2:5; % Levels are translated via lookup table
s.trial.generate.probs = [.25 .5 .75];
s.trial.generate.ambigs = [.24 .5 .74];
s.trial.generate.stakes_loss = 1;
s.trial.generate.reference = 2;
s.trial.generate.colors = [1 2];
s.trial.generate.repeats = 4;

% Useful for generation purposes
s.trial.generate.catchIdx = 1;
% s.trial.generate.catchTrial = table(2, NaN, 0, 1, 2, NaN, 5, ...
%   'VariableNames', {'stakes', 'probs', 'ambigs', 'stakes_loss', 'reference', ...
%   'colors', 'ITIs'});
s.game.block.catchVals = struct('stakes', 2, 'probs', NaN, 'ambigs', [], ...
  'stakes_loss', 1, 'reference', 2, 'colors', NaN, 'ITIs', 5);
s.trial.generate.catchTrial = generateTrials(s.game.block.catchVals);
end
