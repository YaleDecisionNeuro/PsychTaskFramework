function [ beneficiary ] = SODM_extractBeneficiary(blockConfig)
  try
    beneficiary = blockConfig.runSetup.conditions.beneficiary;
  catch
    beneficiary = '';
  end
end
