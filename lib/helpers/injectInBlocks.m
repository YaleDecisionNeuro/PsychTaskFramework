function [ blocksOut ] = injectInBlocks(blockArray, fields, insertion) 
% Adds/changes the value of nested config structs within a block array
%
% Args:
%   blockArray: cell array of block structs
%   fields: a cell array that gives the "adress" for injection. If you wish to
%     change `config.runSetup.authorName` in every block, you would use
%     `{'runSetup', 'authorName'}`
%   insertion: if it is a function handle, it will be called with the value of
%     the target field as argument, and the output will replace that value. If
%     it is any other variable kind, it will simply be set as the value of the
%     target field.

if isFunction(insertion)
  blocksOut = cellfun(@(block) setfield(s, fields{:}, ...
    insertion(getfield(s, fields{:}))), ...   
    'UniformOutput', false);
else
  blocksOut = cellfun(@(block) setfield(s, fields{:}, insertion), ...
    'UniformOutput', false);
end
end
