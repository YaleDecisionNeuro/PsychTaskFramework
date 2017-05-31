function s = HLFF_blockDefaults()
% HLFF_CONFIG Return general block config for the high-/low-fat food task
%   designed by Sarah Healy by modifying the default ones from `config`.

% Load defaults
s = configDefaults();

%% Machine config
s.task.taskPath = ['tasks' filesep 'HLFF'];
s.task.imgPath = [s.task.taskPath filesep 'img'];

%% Features of objects that your task displays
% Inheriting all objects from `config`

%% Non-display config for the game
% (Maximum) durations of the various stages, in seconds
% s.trial.legacyPhases.showChoice.duration = 10;
% s.trial.legacyPhases.response.duration = 0;
% s.trial.legacyPhases.feedback.duration = 0.5;
% s.trial.legacyPhases.intertrial.duration = 2;

s.task.constantBlockDuration = false; % Early choice won't add to ITI

%% Block properties
s.task.taskName = 'HLFF';
s.task.fnHandles.trialFn = @runGenericTrial;
% See lib/phase/phaseConfig.m for meaning
s.trial.phases = { ...
  phaseConfig('showChoice', Inf, @phase_showChoice, @action_collectResponse), ...
  phaseConfig('feedback', 0.5, @phase_generic, @action_display, @drawFeedback), ...
  phaseConfig('ITI', 2, @phase_ITI, @action_display)};
s.task.fnHandles.referenceDrawFn = @drawRef;

% Useful for generation purposes
s.task.blockLength = 20;
s.task.numBlocks = 6;

%% Available trial values
s.trial.generate.probs = [.25 .5 .75];
s.trial.generate.ambigs = [];
s.trial.generate.colors = [1 2];
s.trial.generate.repeats = 4;
s.trial.generate.stakes = 2:5;
s.trial.generate.stakes_loss = 1;
s.trial.generate.reference = 2;

catchVals = struct('stakes', 2, 'probs', NaN, 'ambigs', [], ...
  'stakes_loss', 1, 'reference', 2, 'colors', NaN, 'ITIs', 5);
s.trial.generate.catchTrial = generateTrials(catchVals);
s.trial.generate.catchIdx = 1;
end
