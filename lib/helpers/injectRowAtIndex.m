function tbl = injectRowAtIndex(tbl, row, rowIndex, levelConfig)
% Insert a tabular `row` into a table at all specified indices.
%
% If any of the named fields is NaN and levelConfig is provided,
% the function invokes `generateValuesForMissing` to generate a value from that
% field from levels.
%
% Args:
%   tbl: The original table
%   row: A (usually single-row) table to be inserted at specified indices
%   rowIndex: A row index or a matrix of the row indices 
%   levelConfig (optional):  A configuration level containing replacement
%     information for use by `generateValuesForMissing`
%
% Returns:
%   tbl: A new table with a row at every index.
%
% Warning:
%   The function assumes that the row can be concatenated with the output of
%   `tbl`.  If the row doesn't have all the same columns as tbl, the injection
%   will fail with a hard error.

if exist('levelConfig', 'var')
  row = generateValuesForMissing(row, levelConfig);
end

rowIndex = sort(rowIndex);
for idx = 1:length(rowIndex)
  tbl_pre = tbl(1:(rowIndex(idx) - 1), :);
  tbl_post = tbl(rowIndex(idx):end, :);
  % FIXME: Use join in case `row` orders the same variables differently
  tbl = [tbl_pre; row; tbl_post];
end
end
