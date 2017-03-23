function s = RA_Loss_config(gains_config)
% RA_LOSS_CONFIG Returns loss block settings for the monetary R&A task by
%   modifying the ones created for the gains block.
s = gains_config;

s.game.block.name = 'Loss';
s.trial.generate.stakes = -1 * s.trial.generate.stakes;
s.trial.generate.reference = -1 * s.trial.generate.reference;
s.trial.generate.catchTrial.stakes = -4;
s.trial.generate.catchTrial.reference = -5;
end
