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
s.trial.legacyPhases = legacyPhaseStruct;
s.trial.legacyPhases.showChoice.duration = 6;
s.trial.legacyPhases.response.duration = 3.5;
s.trial.legacyPhases.feedback.duration = 0.5;
s.trial.legacyPhases.intertrial.duration = [4 * ones(1, 6), 5 * ones(1, 8), 6 * ones(1, 6)];

%% Common block properties
s.task.taskName = 'MDM';
s.task.fnHandles.preBlockFn = @preBlock;

s.task.fnHandles.trialFn = @runRATrial; % RA-specific trial function
s.trial.legacyPhases.showChoice.phaseScript = @phase_showChoice;
s.task.fnHandles.referenceDrawFn = @drawRef;
s.task.blockLength = 21;
s.task.blockNum = 4;
s.task.blocksPerSession = 4;

s.trial.legacyPhases.showChoice.action = @action_display;
s.trial.legacyPhases.response.action = @action_collectResponse;
s.trial.legacyPhases.feedback.action = @action_display;

%% Available trial values - are shared across med & monetary tasks!
s.trial.generate.stakes = 2:5; % Levels are translated via lookup table
s.trial.generate.probs = [.25 .5 .75];
s.trial.generate.ambigs = [.24 .5 .74];
s.trial.generate.stakes_loss = 1;
s.trial.generate.reference = 2;
s.trial.generate.colors = [1 2];
s.trial.generate.repeats = 4;
s.trial.generate.ITIs = s.trial.legacyPhases.intertrial.duration;

% Useful for generation purposes
s.trial.generate.catchIdx = 1;
% s.trial.generate.catchTrial = table(2, NaN, 0, 1, 2, NaN, 5, ...
%   'VariableNames', {'stakes', 'probs', 'ambigs', 'stakes_loss', 'reference', ...
%   'colors', 'ITIs'});
catchVals = struct('stakes', 2, 'probs', NaN, 'ambigs', [], ...
  'stakes_loss', 1, 'reference', 2, 'colors', NaN, 'ITIs', 5);
s.trial.generate.catchTrial = generateTrials(catchVals);
end
