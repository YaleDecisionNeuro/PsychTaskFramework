function s = MDM_config_monetary(initial_config)
% MDM_CONFIG Return settings specific to the monetary portion of MDM by
%   modifying the general MDM_config pass as argument.

% Load defaults
s = initial_config;

%% Block properties
s.game.block.name = 'Monetary';
s.game.optionsPhaseFn = @RA_drawTask;
s.game.referenceDrawFn = @RA_drawRef;
s.game.block.length = 12;

% Useful for generation purposes
% s.game.block.repeatIndex = NaN;
% s.game.block.repeatTrial = NaN;

%% Available trial values
s.game.levels.stakes = [5 8 12 25]; % Levels are translated via lookup table
s.game.levels.probs = [.25 .5 .75];
s.game.levels.ambigs = [.24 .5 .74];
s.game.levels.stakes_loss = 0;
s.game.levels.reference = 5;
s.game.levels.colors = [1 2];
s.game.levels.repeats = 1;
end
