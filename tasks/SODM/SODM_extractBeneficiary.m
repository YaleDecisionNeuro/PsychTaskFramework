function [ beneficiary ] = SODM_extractBeneficiary(blockConfig)
% Extracts the beneficiary (self or other) for each block.
%
% Args:
%   blockConfig: The block settings
%
% Returns:
%   beneficiary: String naming the beneficiary for the current condition

  try
    beneficiary = blockConfig.runSetup.conditions.beneficiary;
  catch
    beneficiary = '';
  end
end
