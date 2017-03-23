function s = SODM_config()
% SODM_CONFIG Return general block settings for the medical decision-making
%   task by modifying the default ones from `config`.

% Load defaults
s = config();

%% Machine settings
s.task.taskPath = ['tasks' filesep 'SODM'];
s.task.imgPath = [s.task.taskPath filesep 'img'];

%% Features of objects that your task displays
% Inheriting all objects from `config`

%% Non-display settings for the game
% (Maximum) durations of the various stages, in seconds
s.game.durations.showChoice = 10;
s.game.durations.response = 0;
s.game.durations.feedback = 0.5;
s.game.durations.ITIs = 2;

s.task.constantTrialDuration = false; % Early choice won't add to ITI

%% Block properties
s.task.taskName = 'SODM';
s.task.blockLength = 19;

s.task.fnHandles.trialFn = @runRATrial; % RA-specific trial function
s.game.responsePhaseFn = NaN;
s.task.fnHandles.preBlockFn = @preBlock;
s.game.showChoicePhaseFn = @SODM_showChoice;
s.task.fnHandles.referenceDrawFn = @drawRef;
s.task.fnHandles.bgrDrawFn = @drawBgr;
s.task.fnHandles.bgrDrawCallbackFn = @SODM_drawCondition;

s.game.showChoiceActionFn = @action_collectResponse;
s.game.feedbackActionFn = @action_display;

%% Graphical setup for the condition
s.objects.condition.position = [100 100];

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
