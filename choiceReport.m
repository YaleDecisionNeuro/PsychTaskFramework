function report = choiceReport(Data, trial)
  choice = Data.choice(trial);
  if choice == 0
    answer = 'Failed to answer ';
  else
    answer = sprintf('Answered %d ', choice);
  end
  context = sprintf('on trial %d: payoff %d, probability %.2f, ambiguity %.2f', ...
      trial, Data.vals(trial), Data.probs(trial), Data.ambigs(trial));
  report = [answer context];

end
