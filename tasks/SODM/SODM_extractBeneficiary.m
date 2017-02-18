function [ beneficiary ] = SODM_extractBeneficiary(blockSettings)
  try
    blockKind = strsplit(blockSettings.game.block.name, ' ');
    beneficiary = blockKind{end};
  catch
    beneficiary = '';
  end
end
