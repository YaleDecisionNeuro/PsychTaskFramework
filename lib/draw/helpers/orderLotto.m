function [probOrder, amtOrder] = orderLotto(trialSettings)
% ORDERLOTTO Given the win color for the trial, it returns two sorted matrices
%   with the probability (and, respectively, payoff) values sorted such that
%   the first will appear on top and the second on the bottom of the drawTask
%   display.

  winProb = trialSettings.probs;
  winAmt = trialSettings.stakes;
  lossAmt = trialSettings.stakes_loss;

  % Only two options -> hard-code the default, flip if necessary
  probOrder = [winProb, 1 - winProb];
  amtOrder = [winAmt, lossAmt];

  % NOTE: We could just go to Data.colors(trial) and compute reminder, & involve colors later
  if trialSettings.colors == 1
    probOrder = fliplr(probOrder);
    amtOrder = fliplr(amtOrder);
  end
end
