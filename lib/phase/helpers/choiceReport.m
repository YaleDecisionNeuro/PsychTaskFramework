function report = choiceReport(trialData)
% Prints to stdout participant choice and decision properties.
%
% Args:
%   trialData: A table of trial information
%
% Returns:
%   boolean: Whether participant chose the lottery and what the properties of
%   the offered lottery were.

  choice = trialData.choice;
  if choice == 0
    answer = 'Failed to answer ';
  else
    answer = sprintf('Answered %d ', choice);
  end
  context = sprintf(['with payoff %d, reference %d, probability %.2f, ' ...
    'ambiguity %.2f'], trialData.stakes, trialData.reference, ...
    trialData.probs, trialData.ambigs);
  report = [answer context];
end
