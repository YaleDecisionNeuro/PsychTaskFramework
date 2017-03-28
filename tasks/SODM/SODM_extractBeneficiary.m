function [ beneficiary ] = SODM_extractBeneficiary(blockSettings)
  try
    beneficiary = blockSettings.runSetup.conditions.beneficiary;
  catch
    beneficiary = '';
  end
end
