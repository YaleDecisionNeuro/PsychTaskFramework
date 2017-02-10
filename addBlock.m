function [ DataObject ] = addBlock(DataObject, blockData, blockSettings)
% ADDBLOCK Appends `blockData` to the cell array `DataObject.recordedBlocks`.
%   Stores records in `.records` and the settings used for the block in
%   `.settings`.

  if ~isfield(DataObject, 'recordedBlocks')
    DataObject.recordedBlocks = cell(0);
    n = 1;
  else
    n = length(DataObject.recordedBlocks) + 1;
  end

  DataObject.recordedBlocks{n}.records = blockData;
  DataObject.recordedBlocks{n}.settings = blockSettings;
end
