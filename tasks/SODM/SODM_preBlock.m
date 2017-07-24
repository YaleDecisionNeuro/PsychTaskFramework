function [ Data, blockConfig ] = SODM_preBlock(Data, blockConfig)
% Insert beneficiary condition into blockName, then call preBlock with it.
%
% Args:
%   Data: The information collected from task trials
%   blockConfig: The block settings
%
% Returns:
%   2-element tuple containing
%
%   - **Data**: The information collected from task trials.
%   - **blockConfig**: The block settings.

blockConfig.runSetup.blockName = [blockConfig.runSetup.blockName ' / ' ...
  SODM_extractBeneficiary(blockConfig)];
[ Data, blockConfig ] = preBlock(Data, blockConfig);
end
