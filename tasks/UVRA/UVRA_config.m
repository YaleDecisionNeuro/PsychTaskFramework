function s = UVRA_config()
  s = config(); % Get defaults from lib/config

  s.device.taskPath = fullfile('tasks', 'UVRA');
  s.device.breakKeys = {'Space', '5%'};
  s.device.choiceKeys = {'UpArrow', 'DownArrow'};
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
  s.game.durations.showChoice = Inf;
  s.game.durations.ITIs = 1;
  s.game.constantTrialDuration = false; % don't need to fit fMRI time blocks

  % What phase and draw functions should runRATrial use?
  s.game.trialFn = @runRATrial; % RA-specific trial function
  s.game.preBlockFn = @preBlock;
  s.game.showChoicePhaseFn = @UVRA_showChoice;
  s.game.responsePhaseFn = NaN;
  s.game.feedbackPhaseFn = @UVRA_feedback;
  s.game.referenceDrawFn = @drawRef;

  s.game.showChoiceActionFn = @action_collectResponse;
  s.game.feedbackActionFn = @action_display;

  % Graphical adjustments
  s.objects.lottery.offCenterByPx = [0 200]; % refSide switches this around
  s.objects.lottery.verticalLayout = true;
  % s.objects.reference.offCenterByPx = [0 -200];
end
