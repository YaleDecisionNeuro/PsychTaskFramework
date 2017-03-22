function [ Summary ] = experimentSummary(Data, blockId, trialId, bagMap)
% EXPERIMENTSUMMARY Selects block and trial from Data.blocks.recorded and
%   returns information necessary for lottery realization in a per-trial
%   struct. If `bagMap` is supplied, it will use it instead of the default
%   lookup map. NOTE: This is different from the original behavior of
%   `experimentSummary`, which returned a human-readable struct array that
%   encompassed *all* trials.
%
% NOTE: You might want to load the bagMap via `readtable` from a CSV/XLS file.

if ~exist('bagMap', 'var')
  probs = [.5 .5 .5 .5 .25 .25 .75 .75]';
  ambigs = [0 .24 .5 .74 0 0 0 0]';
  colors = [NaN NaN NaN NaN 1 2 1 2]';
  bagNumber = [4 10 11 12 3 5 3 5]';
  bagMap = table(probs, ambigs, colors, bagNumber);
end

if ~exist('blockId', 'var') || ~exist('trialId', 'var')
  error('You must provide blockId and trialId!');
end

% Get the trials (and warn if they are unavailable)
totalBlocks = numel(Data.blocks.recorded);
if blockId <= totalBlocks
  block = Data.blocks.recorded{blockId};
else
  error('You selected block %d, but there are only %d blocks.', ...
    blockId, totalBlocks);
end

totalTrials = height(block.records);
if trialId <= totalTrials
  trial = block.records(trialId, :);
else
  error('Cannot retrieve trial %d from block %d: only %d records available.', ...
    trialId, blockId, totalTrials);
end

% Save info to a, p, c for easy comparison to bag lookup table
a = trial.ambigs;
p = trial.probs;
c = trial.colors;

mask = (bagMap.probs == p & bagMap.ambigs == a);
if sum(mask) > 1 % If the color actually makes a difference
  mask = (bagMap.probs == p & bagMap.ambigs == a & bagMap.colors == c);
end
bag = bagMap.bagNumber(mask);

if ismember('choseLottery', trial.Properties.VariableNames)
  choseLottery = trial.choseLottery;
else
  choseLottery = keyToChoice(trial.choice, block.settings.perUser.refSide);
end

% Is there a look-up table for stakes? If so, use it!
settings = block.settings;
if isfield(settings, 'lookups')
  lookupTable = settings.lookups.stakes.txt;
  w = textLookup(trial.stakes, lookupTable);
  l = textLookup(trial.stakes_loss, lookupTable);
  r = textLookup(trial.reference, lookupTable);
else
  w = dollarFormatter(trial.stakes);
  l = dollarFormatter(trial.stakes_loss);
  r = dollarFormatter(trial.reference);
end

Summary.bagNumber = bag;
Summary.winningColor = block.settings.objects.lottery.box.colorKey{c};
Summary.lotteryWin = w;
Summary.lotteryLoss = l;
switch choseLottery
  case 0
    Summary.choice = 'Reference';
  case 1
    Summary.choice = 'Lottery';
  otherwise % because NaN never equals any value, even NaN
    Summary.choice = 'None';
end
Summary.referenceValue = r;
end
