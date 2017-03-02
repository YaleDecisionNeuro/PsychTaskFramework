function [ exportTable ] = export(DataObject, fname)
% EXPORT Given a DataObject, it extracts all recorded blocks to a file.
%
% The file format has to be any that `writetable` can handle; consult its docs.

src = DataObject.blocks;
exportTable = table();
if src.numRecorded == 0
  % FIXME: This is not a sufficient test.
  warning('DataObject contains no recorded blocks.');
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
  taskName = blk.settings.game.name;
  blockName = blk.settings.game.block.name;

  finalRecords = blk.records;
  finalRecords = addConstantColumnToTable(finalRecords, 'taskName', taskName);
  finalRecords = addConstantColumnToTable(finalRecords, 'blockName', blockName);
  finalRecords = addConstantColumnToTable(finalRecords, 'blockId', blockId);

  % FIXME: What if one of the blocks is different from the others? Should the
  %   export be "by block kind", or should the table that's being built be a
  %   "big-tent table" that adds columns as needed?
  exportTable = [exportTable; finalRecords];
end
writetable(exportTable, fname);
end

function [ tbl ] = addConstantColumnToTable(tbl, colName, constVal)
% AddConstantColumnToTable Repeat constant value to form another column of tbl.
nRows = height(tbl);
column = cutArrayToSize(constVal, nRows);
tbl.(colName) = column;
end
