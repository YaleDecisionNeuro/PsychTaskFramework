function [probOrder, amtOrder] = orderLotto(trialSettings)
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
