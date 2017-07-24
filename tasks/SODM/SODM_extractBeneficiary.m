function [ beneficiary ] = SODM_extractBeneficiary(blockConfig)
% Extracts the beneficiary (self or other) for each block.
%
% Args:
%   blockConfig: The block settings
%
% Returns:
%   beneficiary: An array of possible beneficiaries (self or other). 

  try
    beneficiary = blockConfig.runSetup.conditions.beneficiary;
  catch
    beneficiary = '';
  end
end
