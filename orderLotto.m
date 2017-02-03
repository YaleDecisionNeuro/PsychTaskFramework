function [probOrder, amtOrder] = orderLotto(settings, trial)
  winProb = settings.game.probs(trial);
  winAmt = settings.game.stakes(trial);

  % Only two options -> hard-code the default, flip if necessary
  probOrder = [winProb, 1 - winProb];
  amtOrder = [winAmt, 0];

  % NOTE: We could just go to Data.colors(trial) and compute reminder, & involve colors later
  if settings.game.colors(trial) == 1
    probOrder = fliplr(probOrder);
    amtOrder = fliplr(amtOrder);
  end
end
