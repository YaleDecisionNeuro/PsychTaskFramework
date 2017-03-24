function [ exportTable ] = exportParticipant(DataObject, fname)
% ExportParticipant Given a DataObject, it unites all records in one table.
%   If given fname, it will also write the table into a file.
%
% The file format has to be any that `writetable` can handle; consult its docs.

subjId = DataObject.observer;
exportTable = table();
if ~isfield(DataObject, 'blocks')
  warning('DataObject for %d contains no planned or recorded blocks.', subjId)
  return;
end

src = DataObject.blocks;
if ~isfield(src, 'recorded') || numel(src.recorded) == 0
  warning('DataObject for %d contains no recorded blocks.', subjId);
  return;
end

% Basic approach: Iterate through recorded blocks, concatenating the tables.
blocks = src.recorded;
n = numel(blocks);

for blockId = 1:n
  blk = blocks{blockId};

  % Add task name, block name and block id as columns
  % FIXME: Generally, which fields should get extracted from the `settings`
  % struct? Should this be user-definable in some way, shape, or form?
  taskName = blk.settings.task.taskName;
  blockName = blk.settings.runSetup.blockName;

  finalRecords = blk.records;
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

function [ tbl ] = addConstantColumnToTable(tbl, colName, constVal)
% AddConstantColumnToTable Repeat constant value to form another column of tbl.
nRows = height(tbl);
column = cutArrayToSize(constVal, nRows);
tbl.(colName) = column;
end
