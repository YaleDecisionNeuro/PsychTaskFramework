function [ beneficiary ] = SODM_extractBeneficiary(blockSettings)
  try
    blockKind = strsplit(blockSettings.runSetup.blockName, ' ');
    beneficiary = blockKind{end};
  catch
    beneficiary = '';
  end
end
