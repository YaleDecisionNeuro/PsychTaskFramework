function s = RA_config()
% CONFIG_RA Return general block settings for the monetary risk & ambiguity
%   task by modifying the default ones from `config`.

% Only small modifications are necessary, as `config` caters to this paradigm

% Load defaults
s = config();

%% Machine settings
s.task.taskPath = ['tasks' filesep 'RA'];
s.task.constantBlockDuration = true; % This is fMRI, so intertrial compensates for any fast responses in order to make each trial last a constant amount of time
% FIXME: Add durations

%% Game settings
s.task.taskName = 'MonetaryRA';
s.game.block.name = 'Gains';
s.task.blockLength = 31; % Useful for generation purposes

s.task.fnHandles.trialFn = @runRATrial; % RA-specific trial function
s.trial.legacyPhases = legacyPhaseStruct;
s.trial.legacyPhases.showChoice.phaseScript = @phase_showChoice;
s.task.fnHandles.referenceDrawFn = @drawRef;
s.task.fnHandles.preBlockFn = @preBlock;

s.trial.legacyPhases.showChoice.action = @action_display;
s.trial.legacyPhases.response.action = @action_collectResponse;
s.trial.legacyPhases.feedback.action = @action_display;

%% Available trial values to be used for trial generation
s.trial.generate.stakes = [5, 6, 7, 8, 10, 12, 14, 16, 19, 23, 27, 31, 37, 44, 52, 61, 73, 86, 101, 120];
s.trial.generate.probs = [.25 .5 .75];
s.trial.generate.ambigs = [.24 .5 .74];
s.trial.generate.stakes_loss = 0;
s.trial.generate.reference = 5;
s.trial.generate.colors = [1 2];
s.trial.generate.repeats = 1;
s.trial.generate.ITIs = [4 * ones(1, 10), 6 * ones(1, 10), 8 * ones(1, 10)];

s.trial.generate.catchIdx = 1; % where will the test of stochastic dominance be
s.trial.generate.catchTrial = table(4, 0.5, 0, 0, 5, randperm(2, 1), 10, ...
  'VariableNames', {'stakes', 'probs', 'ambigs', 'stakes_loss', 'reference', ...
  'colors', 'ITIs'});
end
