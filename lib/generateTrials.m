function [ trialTbl ] = generateTrials(levelSettings)
% GENERATETRIALS Generates a table of risk&ambiguity trials that contain all
%   combinations of `levelSettings` struct subfields.
%
% NOTE: The generator is specific to the risk/ambiguity task. It expects that %
% the struct will contain `stakes` and at least one of (`probs`, `ambigs`)
% fields.  % It will also combine them in a particular way (specifically,
% assuming that all ambiguous % trials are coupled with .5 probability, and all
% probability trials have at % least one appearance with zero ambiguity). It
% distributes all other subfields % it finds randomly across thus generated
% trials.
%
% If you wish to omit any ambiguous trials but do not wish to delete the struct
% field, you can also pass an empty matrix to achieve the same result.
%
% Generally speaking: if your task only differs slightly from the monetary R&A
% task, you should be able to use this script with minimum alteration. If your
% task is substantially different, you might have to roll your own.

%% 1. Generate the basics -- assuming field names contain well-defined content
allStakes = levelSettings.stakes;
allProbs = existingValueOrDefault(levelSettings, 'probs', []);
allAmbigs = existingValueOrDefault(levelSettings, 'ambigs', []);
trialRepeats = existingValueOrDefault(levelSettings, 'repeats', 1);

if trialRepeats == 0
  warning('As repeats in levelSettings were set to 0, no trials were generated.');
  return
end

if isempty(allProbs) && isempty(allAmbigs)
  warning(['As no available probability or ambiguity values were passed, no ' ...
    'trials were generated.']);
  return
end

% Generate all values for trials, so that they can be concatenated later
[stakes_P, trialProbs] = ndgrid(allStakes, allProbs, 1:trialRepeats);
[stakes_A, trialAmbigs] = ndgrid(allStakes, allAmbigs, 1:trialRepeats);
% NOTE: The reason this works is that while `ndgrid` creates an n-dimensional
%   matrix for each argument that has size > 1, all the values are extracted
%   with `var(:)`, rendering dimensionality moot. (It works with empty
%   matrices.)

stakes = [stakes_P(:); stakes_A(:)];
probs  = [trialProbs(:); 0.5 * ones(size(trialAmbigs(:)))];
ambigs = [zeros(size(trialProbs(:))); trialAmbigs(:)];

% Create return value
trialTbl = table(stakes, probs, ambigs);

%% 2. If other values exist, generate them and add as columns
numTrials = height(trialTbl);
excludeFields = {'stakes', 'probs', 'ambigs', 'repeats'};
allFields = fieldnames(levelSettings);
getFields = allFields(~ismember(allFields, excludeFields));

for k = 1:numel(getFields)
  varName = getFields{k};
  varVals = levelSettings.(varName);
  varVals = varVals(:); % get rid of dimensionality

  % Extend the field to length of numTrials
  l = length(varVals);
  if l > numTrials
    warning('Field %s is longer than the trial list (length %d, numTrials %d)', ...
      varName, l, numTrials);
    column = varVals(1 : numTrials);
  else
    column = repmat(varVals(:), floor(numTrials / l), 1);
    remainder = rem(numTrials, l);
    if remainder > 0
      warning(['Field %s contains %d elements, which cannot divide the %d' ...
        'generated trials without remainder: selecting the first %d values.'], ...
        varName, l, numTrials, remainder);
      column = [column; varVals(1 : remainder)];
    end
  end

  % Randomize order
  column = column(randperm(numTrials));

  % Add column to table
  trialTbl.(varName) = column;
end
end

function val = existingValueOrDefault(structVar, fieldname, default)
  if ~exist('default', 'var')
    default = NaN;
  end

  if isfield(structVar, fieldname)
    val = structVar.(fieldname);
  else
    val = default;
  end
end
