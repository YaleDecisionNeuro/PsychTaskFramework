function [ Data, blockConfig ] = SODM_preBlock(Data, blockConfig)
% Insert beneficiary condition into blockName, then call preBlock with it
blockConfig.runSetup.blockName = [blockConfig.runSetup.blockName ' / ' ...
  SODM_extractBeneficiary(blockConfig)];
[ Data, blockConfig ] = preBlock(Data, blockConfig);
end
