function [probOrder, amtOrder] = orderLotto(trialData)
% Set up the probability and win/loss amount for each lottery. 
%
% Given the win color for the trial, it returns two sorted matrices with the
% probability (and, respectively, payoff) values sorted such that the first
% will appear on top and the second on the bottom of the drawLotto display.
%
% Args:
%   trialData: The data stored for each trial
%
% Returns:
%   2-element tuple containing
%
%   - **probOrder**: A probability matrix of a win versus a loss.
%   - **amtOrder**: A matrix of the amount that was won or lost.

  winProb = trialData.probs;
  winAmt = trialData.stakes;
  lossAmt = trialData.stakes_loss;

  % Only two options -> hard-code the default, flip if necessary
  probOrder = [winProb, 1 - winProb];
  amtOrder = [winAmt, lossAmt];

  % NOTE: We could just go to Data.colors(trial) and compute reminder, & involve colors later
  if trialData.colors == 2
    probOrder = fliplr(probOrder);
    amtOrder = fliplr(amtOrder);
  end
end
