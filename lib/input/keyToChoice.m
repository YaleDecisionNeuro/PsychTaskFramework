function [ choseLottery ] = keyToChoice(recordedChoice, refSide)
% Return how often subject chose to gamble (picked lottery over reference).
%
% Based on the choice recorded according to current rules (0 = no
%   response, 1 = choice on left, 2 = choice on right) and the knowledge of
%   which side has the reference, output whether the subject chose the
%   gamble as true / false / NaN.
%
% Args:
%   recordedChoice: A record of participant choice 
%   refSide: A variable determining which option is a reference and which
%     is a lottery.
%
% Returns:
%   choseLottery: A dictionary of choice events related to how often
%     subject gambled.

% Strategy: build a dictionary for which recordedChoice will be an index.

% If refSide is 1, lottery is 2, and vice versa.
dict = [0 1];
if refSide == 2
  dict = 1 - dict; % Flip
end
dict = [NaN dict];

% Voila.
choseLottery = dict(recordedChoice + 1);
end
