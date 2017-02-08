function [ DataObject ] = addBlock(DataObject, blockData, blockSettings)
  if ~isfield(DataObject, 'recordedBlocks')
    DataObject.recordedBlocks = cell(0);
    n = 1;
  else
    n = length(DataObject.recordedBlocks) + 1;
  end

  DataObject.recordedBlocks{n}.records = blockData;
  DataObject.recordedBlocks{n}.settings = blockSettings;
end
