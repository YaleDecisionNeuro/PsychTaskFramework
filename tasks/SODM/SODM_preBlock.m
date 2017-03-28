function [ Data, blockSettings ] = SODM_preBlock(Data, blockSettings)
% Insert beneficiary condition into blockName, then call preBlock with it
blockSettings.runSetup.blockName = [blockSettings.runSetup.blockName ' / ' ...
  SODM_extractBeneficiary(blockSettings)];
[ Data, blockSettings ] = preBlock(Data, blockSettings);
end
