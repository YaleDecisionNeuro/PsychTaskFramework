function s = UVRA_config()
  s = config(); % Get defaults from lib/config

  s.device.taskPath = fullfile('tasks', 'UVRA');
  % See lib/config for other things that s.device can contain

  % Meta
  s.game.name = 'UVRA';
  s.game.block.name = 'Gains';
  % This marks the default block name, will be displayed in pre-block screen,
  %   and marks the block in data export.

  % Fitting trials into blocks and blocks into sessions
  s.game.block.length = 20; % trials per block
  s.game.block.numBlocks = 6; % blocks per game
  s.game.block.sessionLengths = [3 3]; % sessions per game

  % Winning pay-offs
  s.game.levels.stakes = [5, 8, 12, 17, 25];
  s.game.levels.stakes_loss = 0;
  s.game.levels.reference = 5;
  s.game.levels.probs = [.25 .5 .75];
  s.game.levels.ambigs = [.24 .5 .74];
  s.game.levels.colors = [1 2];
  s.game.levels.repeats = 4;

  % Set durations of choice & intertrial period
  s.game.durations.choice = Inf;
  s.game.durations.ITIs = 1;
  s.game.constantTrialDuration = false; % don't need to fit fMRI time blocks

  % What phase and draw functions should runTrial use?
  s.game.preBlockFn = @preBlock;
  s.game.optionsPhaseFn = @UVRA_drawTask;
  s.game.referenceDrawFn = @UVRA_drawRef;
  s.game.responsePhaseFn = NaN;
  s.game.feedbackPhaseFn = @UVRA_feedback;

  % Graphical adjustments
  s.objects.lottery.offCenterByPx = [0 200]; % refSide switches this around
end
