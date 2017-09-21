function c = RA_lossConfig(gains_config)
% Returns loss block config for the monetary R&A task by
% modifying the ones created for the gains block.
%
% Args:
%   gains_config: Config returned from `RA_gainsConfig`
%
% Returns:
%   Config struct specific to the RA loss condition

  c = gains_config;

  c.runSetup.blockName = 'Loss';
  c.runSetup.conditions.domain = 'Loss';
  c.trial.generate.stakes = -1 * c.trial.generate.stakes;
  c.trial.generate.reference = -1 * c.trial.generate.reference;
  c.trial.generate.catchTrial.stakes = -4;
  c.trial.generate.catchTrial.reference = -5;
end
