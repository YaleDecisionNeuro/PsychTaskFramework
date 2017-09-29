function tbl = generateValuesForMissing(tbl, levelConfig)
% If any of the columns in `tbl` have NaN in row, it will select a value
% randomly from the corresponding field of `levelConfig`.
%
% Args:
%   tbl: An arbitrary table with some NaN values
%   levelConfig: A struct that contains value options to replace NaN in the given columns
%
% Returns:
%   tbl: A new table with missing values generated.
tblCols = tbl.Properties.VariableNames;
knownLevels = fieldnames(levelConfig);

for k = 1:numel(tblCols)
  colName = tblCols{k};
  if ~ismember(colName, knownLevels)
    continue
  end
  col = tbl.(colName);
  changable = isnan(col);
  changableIdx = find(changable); % Get non-zero values
  if sum(changable) > 0
    numOptions = length(levelConfig.(colName));
    for l = 1:length(changableIdx)
      tbl(changableIdx(l), k) = {levelConfig.(colName)(randi(numOptions))};
    end
  end
end
end
