function s = RA_config()
% CONFIG_RA Return general block settings for the monetary risk & ambiguity
%   task by modifying the default ones from `config`.

% Only small modifications are necessary, as `config` caters to this paradigm

% Load defaults
s = config();

%% Machine settings
s.task.taskPath = ['tasks' filesep 'RA'];
s.task.constantTrialDuration = true; % This is fMRI, so intertrial compensates for any fast responses in order to make each trial last a constant amount of time

%% Game settings
s.task.taskName = 'MonetaryRA';
s.game.block.name = 'Gains';
s.task.blockLength = 31; % Useful for generation purposes

s.task.fnHandles.trialFn = @runRATrial; % RA-specific trial function
s.game.showChoicePhaseFn = @phase_showChoice;
s.task.fnHandles.referenceDrawFn = @drawRef;
s.task.fnHandles.preBlockFn = @preBlock;

s.game.showChoiceActionFn = @action_display;
s.game.responseActionFn = @action_collectResponse;
s.game.feedbackActionFn = @action_display;

%% Available trial values to be used for trial generation
s.game.levels.stakes = [5, 6, 7, 8, 10, 12, 14, 16, 19, 23, 27, 31, 37, 44, 52, 61, 73, 86, 101, 120];
s.game.levels.probs = [.25 .5 .75];
s.game.levels.ambigs = [.24 .5 .74];
s.game.levels.stakes_loss = 0;
s.game.levels.reference = 5;
s.game.levels.colors = [1 2];
s.game.levels.repeats = 1;

s.game.block.repeatIndex = 1; % where will the test of stochastic dominance be
s.game.block.repeatRow = table(4, 0.5, 0, 0, 5, randperm(2, 1), 10, ...
  'VariableNames', {'stakes', 'probs', 'ambigs', 'stakes_loss', 'reference', ...
  'colors', 'ITIs'});
end
