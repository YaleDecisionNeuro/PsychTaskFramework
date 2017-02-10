function s = RA_config()
% CONFIG_RA Return general block settings for the monetary risk & ambiguity
%   task by modifying the default ones from `config`.

% Only small modifications are necessary, as `config` caters to this paradigm

% Load defaults
s = config();

%% Machine settings
s.device.screenId = 1; % 0 for current screen, 1 for a second screen

%% Game settings
s.game.name = 'MonetaryRA';
s.game.block.name = 'Gains';
s.game.block.length = 31; % Useful for generation purposes
s.game.block.repeatIndex = 1; % where will the test of stochastic dominance be
% FIXME: The repeating row should be explicitly defined here?

s.game.trialFn = @RA_drawTrial;
s.game.preBlockFn = @preBlock;

%% Available trial values
s.game.levels.stakes = [5, 6, 7, 8, 10, 12, 14, 16, 19, 23, 27, 31, 37, 44, 52, 61, 73, 86, 101, 120];
s.game.levels.probs = [.25 .5 .75];
s.game.levels.ambigs = [.24 .5 .74];
s.game.levels.stakes_loss = 0;
s.game.levels.reference = 5;
s.game.levels.colors = [1 2];
s.game.levels.repeats = 1;
end
