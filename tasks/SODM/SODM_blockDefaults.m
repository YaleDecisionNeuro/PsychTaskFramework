function s = SODM_blockDefaults()
% Return general block config for the medical decision-making task by modifying
% the default ones from `configDefaults`.
%
% Returns:
%   The config struct with settings shared across all SODM conditions.

s = configDefaults(); % Load defaults

%% Machine config
s.task.taskPath = ['tasks' filesep 'SODM'];
s.task.imgPath = [s.task.taskPath filesep 'img'];

%% Features of objects that your task displays
% Inheriting all objects from `config`

%% Non-display config for the game
% (Maximum) durations of the various stages, in seconds
s.trial.legacyPhases = legacyPhaseStruct;
s.trial.legacyPhases.showChoice.duration = 10;
s.trial.legacyPhases.response.duration = 0;
s.trial.legacyPhases.feedback.duration = 0.5;
s.trial.legacyPhases.intertrial.duration = 2;

s.task.constantBlockDuration = false; % Early choice won't add to ITI

%% Block properties
s.task.taskName = 'SODM';
s.task.blockLength = 19;
s.task.blocksPerSession = 8;
s.task.numBlocks = 8;
s.task.blocksPerCondition = 2; % self and other are separate conditions

s.task.fnHandles.trialFn = @runRATrial; % RA-specific trial function
s.task.fnHandles.preBlockFn = @SODM_preBlock;
s.trial.legacyPhases.showChoice.phaseScript = @SODM_showChoice;
s.trial.legacyPhases.showChoice.action = @action_collectResponse;
s.trial.legacyPhases.response.phaseScript = NaN;
s.trial.legacyPhases.response.action = NaN;
s.trial.legacyPhases.feedback.action = @action_display;

s.task.fnHandles.referenceDrawFn = @drawRef;
s.task.fnHandles.bgrDrawFn = @drawBgr;
s.task.fnHandles.bgrDrawCallbackFn = @SODM_drawCondition;

%% Graphical setup for the condition
s.draw.condition.position = [100 100];

%% Available trial values
s.trial.generate.probs = [.25 .5 .75];
s.trial.generate.ambigs = [.24 .5 .74];
s.trial.generate.colors = [1 2];
s.trial.generate.repeats = 2;
s.trial.generate.stakes = 3:5;
% Actually 2:5, but 3:5 is used for automated trial generation
s.trial.generate.stakes_loss = 1;
s.trial.generate.reference = 2;
s.trial.generate.ITIs = s.trial.legacyPhases.intertrial.duration;

s.trial.generate.catchIdx = 1;
catchVals = struct('stakes', 2, 'probs', 0.5, 'ambigs', [], ...
  'stakes_loss', 1, 'reference', 2, 'colors', 1, 'ITIs', 5);
s.trial.generate.catchTrial = generateTrials(catchVals);
end
