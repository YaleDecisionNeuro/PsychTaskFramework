function s = UVRA_config()
  s = config(); % Get defaults from lib/config

  s.task.taskPath = fullfile('tasks', 'UVRA');
  s.device.breakKeys = {'Space', '5%'};
  s.device.choiceKeys = {'UpArrow', 'DownArrow'};
  % See lib/config for other things that s.device can contain

  % Meta
  s.task.taskName = 'UVRA';
  s.game.block.name = 'Gains';
  % This marks the default block name, will be displayed in pre-block screen,
  %   and marks the block in data export.

  % Set durations of choice & intertrial period
  s.trial.legacyPhases = legacyPhaseStruct;
  s.trial.legacyPhases.showChoice.duration = Inf;
  s.trial.legacyPhases.intertrial.duration = 1;
  s.task.constantBlockDuration = false; % don't need to fit fMRI time blocks

  % Fitting trials into blocks and blocks into sessions
  s.task.blockLength = 20; % trials per block
  s.task.numBlocks = 6; % blocks per game
  s.task.blocksPerSession = 2;

  % Winning pay-offs
  s.trial.generate.stakes = [5, 8, 12, 17, 25];
  s.trial.generate.stakes_loss = 0;
  s.trial.generate.reference = 5;
  s.trial.generate.probs = [.25 .5 .75];
  s.trial.generate.ambigs = [.24 .5 .74];
  s.trial.generate.colors = [1 2];
  s.trial.generate.repeats = 4;
  s.trial.generate.ITIs = s.trial.legacyPhases.intertrial.duration;

  % What phase and draw functions should runRATrial use?
  s.task.fnHandles.trialFn = @runRATrial; % RA-specific trial function
  s.task.fnHandles.preBlockFn = @preBlock;
  s.trial.legacyPhases.showChoice.phaseScript = @UVRA_showChoice;
  s.trial.legacyPhases.response.phaseScript = NaN;
  s.trial.legacyPhases.feedback.phaseScript = @UVRA_feedback;
  s.task.fnHandles.referenceDrawFn = @drawRef;

  s.trial.legacyPhases.showChoice.action = @action_collectResponse;
  s.trial.legacyPhases.feedback.action = @action_display;

  % Graphical adjustments
  s.objects.lottery.offCenterByPx = [0 200]; % refSide switches this around
  s.objects.lottery.verticalLayout = true;
  % s.objects.reference.offCenterByPx = [0 -200];
end
