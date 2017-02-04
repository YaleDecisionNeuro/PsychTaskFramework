function [orderedValues, orderedProbs, orderedAmbigs, orderedColors] = generateTrialOrder(vals, probs, ambigs, colors, trialRepeats, blockSize, includeTrial)
% TODO: Replace all input arguments with `settings`
if ~exists('colors', 'var')
  colors = [1 2];
end

[allTrialValues_P, trialProbs] = ndgrid(vals, probs, 1:trialRepeats);
[allTrialValues_A, trialAmbigs] = ndgrid(vals, ambigs, 1:trialRepeats);

allTrialValues = [allTrialValues_P(:), allTrialValues_A(:)];
allTrialProbs  = [trialProbs, 0.5 * ones(size(ambigs(:)))];
allTrialAmbigs = [zeros(size(probs(:))), ambigs(:)];

if length(allTrialValues) ~= length(allTrialProbs) | ...
   length(allTrialValues) ~= length(allTrialAmbigs)
  error('Trial component length not equal; the generating algorithm is broken in an unforeseen way');
end

allTrialColors = repmat(colors, 1, floor(length(allTrialValues) / length(colors)));
% FIXME: Default trials should be included in blockSize but subtracted for these purposes?
if exists('blockSize', 'var')
  if rem(length(allTrialValues), blockSize) == 0
  % TODO: Reshape, randperm in every row, reshape again
  end
end
remainder = rem(length(allTrialValues, length(colors)));
if remainder ~= 0
  allTrialColors = [allTrialColors, colors(1 : remainder)];
end

  function table = injectRowAtIndex(row, rowIndex)

  end
end
