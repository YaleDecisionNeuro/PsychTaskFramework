function s = MDM_config()
% MDM_CONFIG Return general block settings for the medical decision-making
%   task by modifying the default ones from `config`.

% Load defaults
s = config();

%% Machine settings
s.device.screenId = 1; % 0 for current screen, 1 for a second screen
s.device.taskPath = ['tasks' filesep 'MDM'];
s.device.imgPath = [s.device.taskPath filesep 'img'];

%% Features of objects that your task displays
% Inheriting all objects from `config`

%% Non-display settings for the game
% (Maximum) durations of the various stages, in seconds
s.game.constantTrialDuration = false;
s.game.durations.choice = 10;
s.game.durations.response = 0;
s.game.durations.feedback = 0.5;
s.game.durations.ITIs = 2;
% All ITI durations will be 2 -- see default for variable length ITIs

%% Block properties
s.game.name = 'MDM';
s.game.block.name = 'Medical';
s.game.optionsPhaseFn = @SODM_drawTask;
s.game.responsePhaseFn = NaN;
s.game.referenceDrawFn = @SODM_drawRef;
s.game.preBlockFn = @preBlock;

% Useful for generation purposes
s.game.block.length = 10;
% s.game.block.repeatIndex = NaN;
% s.game.block.repeatTrial = NaN;

%% Available trial values
s.game.levels.stakes = 1:5; % Levels are translated via lookup table
s.game.levels.probs = [.25 .5 .75];
s.game.levels.ambigs = [.24 .5 .74];
s.game.levels.stakes_loss = 1;
s.game.levels.reference = 2;
s.game.levels.colors = [1 2];
s.game.levels.repeats = 1;

%% Lookup tables
s.lookups.stakes.txt = {'no effect'; ...
  'slight improvement'; 'moderate improvement'; 'major improvement'; ...
  'recovery'};
s.lookups.stakes.img = {'no effect.jpg'; 'slight improvement.jpg'; ...
  'moderate improvement.jpg'; 'major improvement.jpg'; 'recovery.jpg'};
% Fix images to path
s.lookups.stakes.img = prependPath(s.lookups.stakes.img, s.device.imgPath);
end

function fullpaths = prependPath(filenames, path)
  if ~strcmp(path(end), '/') && ~strcmp(path(end), '\')
    path = [path filesep];
  end
  fullpaths = cellfun(@(x) [path x], filenames, 'UniformOutput', 0);
end
