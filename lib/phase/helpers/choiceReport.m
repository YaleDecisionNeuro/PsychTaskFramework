function report = choiceReport(trialData)
% Prints to stdout what the choice in `trialData` was and what the properties 
%   in `trialData` were.
%
% Args:
%   trialData: A table of trial information
%
% Returns:
%   report: A summary of participant answers in the context of the
%     question.

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
