function report = choiceReport(trialData, trialSettings)
% CHOICEREPORT Prints to stdout what the choice in `trialData` was and what
%   the properties in `trialSettings` were.

  choice = trialData.choice;
  if choice == 0
    answer = 'Failed to answer ';
  else
    answer = sprintf('Answered %d ', choice);
  end
  context = sprintf('with payoff %d, probability %.2f, ambiguity %.2f', ...
      trialSettings.stakes, trialSettings.probs, trialSettings.ambigs);
  report = [answer context];
end
