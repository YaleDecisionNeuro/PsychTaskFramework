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
s.game.constantTrialDuration = true;
s.game.durations.choice = 6;
s.game.durations.response = 3.5;
s.game.durations.feedback = 0.5;
s.game.durations.ITIs = 2;
% All ITI durations will be 2 -- see default for variable length ITIs

%% Block properties
s.game.name = 'MDM';
s.game.preBlockFn = @preBlock;

% Useful for generation purposes
end
