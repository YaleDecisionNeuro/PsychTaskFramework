function [ combinations ] = generateCombinations(generative, complementary, startTable)
% Generates chosen combinations of generative and complementary properties 
%
% Args:
%   generative: a `struct` in which each field is a matrix of numerical values
%     that you'd like all possible combinations of
%   complementary (optional): a `struct` in which each field is a matrix of numerical values
%     that you'd like distributed evenly, once per combination
%   startTable (optional, deprecated): a `table` to vertically concatenate the
%     results with prior to the addition of complementary values
%
% Returns:
%   a `table` with duly combined and distributed values
%
% Warning:
%   Strings in `generative` will not work. If you need them, use placeholder
%   values and substitute the strings in later.

if isstruct(generative) && ~isempty(generative) && length(fieldnames(generative)) > 0
  values = struct2cell(generative);
  names = fieldnames(generative);

  % Trick to record an arbitrary # of outputs & pass an arbitrary # of inputs:
  allComb = cell(1, numel(names));
  [allComb{:}] = ndgrid(values{:});
  allComb = cellfun(@(x) x(:), allComb, 'UniformOutput', false);
  allGenerative = horzcat(allComb{:});

  combinations = array2table(allGenerative, 'VariableNames', names);
else
  combinations = table;
  warning('No generative properties provided.');
end

if exist('startTable', 'var') 
  if istable(startTable)
    combinations = vertcat(startTable, combinations);
  else
    warning('startTable must be type table; skipping.');
  end
end

if isempty(combinations)
  return;
end

if exist('complementary', 'var') && isstruct(complementary)
  combinations = addDispersedColumns(combinations, complementary);
end
end
