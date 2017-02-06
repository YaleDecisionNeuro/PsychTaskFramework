function [ trialTbl ] = RA_generateTrialOrder(allStakes, allProbs, allAmbigs, allColors, trialRepeats, includeTrial, includeIndex)
% RA_GENERATETRIALORDER Generates a random order of trials that contain all
%   combinations of the `all*` variables (except `allColors`), `nRepeat` times.
%   It will also add to the final trial table the row `includeTrial` at indices
%   passed in `includeIndex`. It returns a randomly sorted table containing all
%   changing elements of the monteray R&A trials.

% TODO: Replace all input arguments with `settings`?
% TODO: does `trialRepeats` do what I think it does?
if ~exist('allColors', 'var')
  allColors = [1 2];
end

%% Generate all values for trials, so that they can be concatenated later
[stakes_P, trialProbs] = ndgrid(allStakes, allProbs, 1:trialRepeats);
[stakes_A, trialAmbigs] = ndgrid(allStakes, allAmbigs, 1:trialRepeats);

stakes = [stakes_P(:); stakes_A(:)];
probs  = [trialProbs(:); 0.5 * ones(size(trialAmbigs(:)))];
ambigs = [zeros(size(trialProbs(:))); trialAmbigs(:)];

if length(stakes) ~= length(probs) || ...
   length(stakes) ~= length(ambigs)
  error('Trial component length not equal; the generating algorithm is broken in an unforeseen way');
end
numTrials = length(stakes);

%% Assign random win_colors for each trial
colors = repmat(allColors, 1, floor(numTrials / length(allColors)));
% FIXME: Default trials should be included in blockSize but subtracted for these purposes?
remainder = rem(numTrials, length(allColors));
if remainder ~= 0
  colors = [colors, allColors(1 : remainder)];
end
% TODO: assign rules to the randomization
colors = colors(randperm(numTrials))';

%% Randomize order of trials
randomOrder = randperm(numTrials)';

trialTbl = table(stakes, probs, ambigs, colors, randomOrder);
trialTbl = sortrows(trialTbl, 'randomOrder');
trialTbl(:, {'randomOrder'}) = []; % no need for the convenience column

trialTbl = injectRowAtIndex(trialTbl, includeTrial, includeIndex);
end

% Helper function
function tbl = injectRowAtIndex(tbl, row, rowIndex)
  % INJECTROWATINDEX Put a constant `row` at all indices in `rowIndex`.
  %   Assumes that the row can be concatenated with the output of `trialTbl`.
  rowIndex = sort(rowIndex);
  for idx = 1:length(rowIndex)
    tbl_pre = tbl(1:(rowIndex(idx) - 1), :);
    tbl_post = tbl(rowIndex(idx):end, :);
    tbl = [tbl_pre; row; tbl_post];
  end
end
