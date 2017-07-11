function [ exportTable ] = exportSubject(DataObject, fname)
% Given a DataObject, it unites all records in one table. 
%
% If given fname, it will also write the table into a file.
%
% The file format has to be any that `writetable` can handle; consult its docs.
%
% Args:
%   DataObject: An object containing participant data.
%   fname: Optionally, a file name to save the resultant table in.
%
% Returns:
%   exportTable: A table containing all recorded information in all blocks.

subjId = DataObject.subjectId;
exportTable = table();
if ~isfield(DataObject, 'blocks')
  warning('DataObject for %d contains no planned or recorded blocks.', subjId);
  return;
end

if isLegacyDataObject(DataObject)
  warning(['This file was collected using a legacy version of the toolbox.', ...
      ' If you encounter any errors, attempt to export it using the version', ...
      ' you collected the data with.']);
  subjId = DataObject.observer;
  src = DataObject.blocks;
  if ~isfield(src, 'recorded') || numel(src.recorded) == 0
    warning('DataObject for %d contains no recorded blocks.', subjId);
    return;
  end
  blocks = src.recorded;
else
  subjId = DataObject.subjectId;
  blocks = DataObject.blocks;
end

n = numel(blocks);
if ~iscell(blocks) || n == 0
  warning('DataObject for %d contains no recorded blocks.', subjId);
  return;
end

% Basic approach: Iterate through recorded blocks, concatenating the tables.
for blockId = 1:n
  blk = blocks{blockId};
  if isLegacyDataObject(DataObject)
    finalRecords = blk.records;
  else
    finalRecords = blk.data;
  end
  
  if isempty(finalRecords)
    continue;
  end

  % Add task name, block name and block id as columns
  % FIXME: Generally, which fields should get extracted from the `config`
  % struct? Should this be user-definable in some way, shape, or form?
  if isLegacyDataObject(DataObject)
    taskName = blk.settings.game.name;
    blockName = blk.settings.game.block.name;
    conds.legacy = blockName; % duplication workaround
  else
    taskName = blk.config.task.taskName;
    blockName = blk.config.runSetup.blockName;
    conds = blk.conditions;
  end
  
  cond_names = fieldnames(conds);
  for k = 1:numel(cond_names)
    cond_name = cond_names{k};
    finalRecords = addConstantColumnToTable(finalRecords, sprintf('condition_%s', cond_name), conds.(cond_name));
  end

  finalRecords = addConstantColumnToTable(finalRecords, 'taskName', taskName);
  finalRecords = addConstantColumnToTable(finalRecords, 'blockName', blockName);
  finalRecords = addConstantColumnToTable(finalRecords, 'blockId', blockId);
  finalRecords = addConstantColumnToTable(finalRecords, 'subjectId', subjId);

  % FIXME: What if one of the blocks is different from the others? Should the
  %   export be "by block kind", or should the table that's being built be a
  %   "big-tent table" that adds columns as needed?
  exportTable = [exportTable; finalRecords];
end
if exist('fname', 'var')
  writetable(exportTable, fname);
end
end

%% Helper function
function [ tbl ] = addConstantColumnToTable(tbl, colName, constVal)
% Repeat constant value to form another column of tbl.
%
% Args:
%   tbl: An existing table
%   colName: A defined column title
%   constVal: A constant value
% 
% Returns:
%   tbl: A new table with a constant value column.
nRows = height(tbl);
column = cutArrayToSize(constVal, nRows);
tbl.(colName) = column;
end
