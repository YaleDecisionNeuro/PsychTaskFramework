function [out] = SODM_generateOrderedBlocks(subjectId, config) 
% Generate a cell array of all blocks from all four SODM conditions
%
% Args:
%   subjectId: a positive integer that identifies the participant
%   config: the default config struct from which each condition's config will
%     inherit
%
% Returns:
%   cell array of block structs arranged in a proper counterbalanced order
if ~exist('config', 'var')
  config = SODM_blockDefaults();
end

% Before we get started with condition-specific changes, let's sort out the
% alluvia in .generate: extract core and complementary properties & split
% them up
coreNames = {'probs', 'ambigs', 'stakes', 'stakes_loss', 'reference'};
fillNames = {'colors', 'ITIs'};
allGenerateNames = fieldnames(config.trial.generate);
removeAlways = {allGenerateNames{~ismember(allGenerateNames, coreNames) & ...
  ~ismember(allGenerateNames, fillNames)}};
config.trial.coreGenerate = rmfield(config.trial.generate, [removeAlways, fillNames]);
config.trial.fillGenerate = rmfield(config.trial.generate, [removeAlways, coreNames]);
% Matlab Lamentation #311: believe it or not, this is the most
% straightforward way to select multiple fields in a struct

% Create separate full config structs for each of the four conditions
medSelfConfig = SODM_medicalConfig(config);
medSelfConfig.runSetup.conditions.beneficiary = 'Self';
medOtherConfig = SODM_medicalConfig(config);
medOtherConfig.runSetup.conditions.beneficiary = 'Friend';

monSelfConfig = SODM_monetaryConfig(config);
monSelfConfig.runSetup.conditions.beneficiary = 'Self';
monOtherConfig = SODM_monetaryConfig(config);
monOtherConfig.runSetup.conditions.beneficiary = 'Friend';

% This takes advantage of the fact that each config is treated the same way.
% We start with a cell array of the four configs we created...
allConditions = {medSelfConfig, monSelfConfig, medOtherConfig, monOtherConfig};
% ...and then we call SODM_generateBlocksForCondition (a local function defined
% below) on them, the outcome of which is a cell array of blocks for each
% condition. We now have a cell array of four elements; each of the elements
% is itself a cell array of block structs:
allConditionsWithBlocks = cellfun(@SODM_generateBlocksForCondition, allConditions, ...
  'UniformOutput', false);

% Penultimately, determine the order in which the blocks will be arranged.
% (Here, 1 refers to medSelfConfig-based blocks, 2 refers to monSelfConfig,
% and so on -- they're the indices of `allConditions`.)
orderToUse = [1 1 2 2 3 3 4 4];
if exist('subjectId', 'var')
  orderToUse = rotateBlockOrder(orderToUse, subjectId);
end

% Finally, this function uses the order we derived to "flatten"
% allConditionsWithBlocks to create a cell array of block structs
out = orderBlocksAcrossConditions(orderToUse, allConditionsWithBlocks{:});
end


%% Helpers
function [ blockArray ] = SODM_generateBlocksForCondition(condition)
  % Generates the condition's trials, randomly sorts them, & splits them into blocks
  %
  % (Although this function is named with an SODM prefix, this really
  % generalizes to all risk-and-ambiguity tasks.)

  % For the current iteration of R&A tasks, we are peculiar about the property
  % combinations of our trials -- specifically, we only have ambiguous trials
  % with an equal midpoint (P = 0.5), so we don't want to mix ambiguity and
  % risk up:
  fillOnly = condition.trial.fillGenerate;
  coreOnly = condition.trial.coreGenerate;
  ambiguityCore = coreOnly;
  ambiguityCore.probs = 0.5;
  riskCore = coreOnly;
  riskCore.ambigs = 0;

  trialTblSingle = [generateCombinations(riskCore); ...
    generateCombinations(ambiguityCore)];

  % That only generated a single combination for each possibility, but we often
  % want to repeat constellations. We certainly want to do that at least once:
  if isfield(condition.trial.generate, 'repeats')
    repeats = condition.trial.generate.repeats;
  else
    repeats = 1;
  end

  trialTbl = table;
  for k = 1:repeats
    trialTbl = [trialTbl; trialTblSingle];
  end

  % Do note that we're doing this just to demonstrate how to generate trials
  % programmatically; if we were importing ready-made combinations from a file,
  % almost all of the code in this function thus far (and some of the code in
  % the main function) would be made unnecessary.

  % Randomize the order of trials
  trialTbl = trialTbl(randperm(height(trialTbl)), :);

  % Add the "non-core" columns to each row
  trialTbl = addDispersedColumns(trialTbl, fillOnly);

  % Finally, split up the single table of trials into as many blocks as
  % `condition` requires in its config. (See `getBlockLengths` for the rules.)
  blockArray = splitTrialsIntoBlocks(trialTbl, condition);
end
