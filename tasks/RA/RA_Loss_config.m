function s = RA_Loss_config(gains_config)
% RA_LOSS_CONFIG Returns loss block settings for the monetary R&A task by
%   modifying the ones created for the gains block.
s = gains_config;

s.game.block.name = 'Loss';
s.game.levels.stakes = -1 * s.game.levels.stakes;
s.game.levels.reference = -1 * s.game.levels.reference;
s.game.block.repeatRow.stakes = -4;
s.game.block.repeatRow.reference = -5;
end
