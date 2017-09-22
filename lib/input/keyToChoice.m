function [ choseLottery ] = keyToChoice(recordedChoice, refSide)
% Convert the pressed key to a boolean of whether the subject chose the lottery.
%
% Based on the choice recorded according to current rules (0 = no
%   response, 1 = choice on left, 2 = choice on right) and the knowledge of
%   which side has the reference, output whether the subject chose the
%   gamble as true / false / NaN.
%
% Note: 
%   The "pressed key" code is not actually the key itself; it is the index of
%   the key in blockConfig.device.choiceKeys.
%
% Args:
%   recordedChoice: Index of recorded key press; 0 if none was recorded.
%   refSide: Which side was the reference displayed on? (1 or 2)
%
% Returns:
%   choseLottery: Boolean of whether the subject chose the lottery, or NaN if
%     no choice was made.

0; % to prevent sphinx from thinking that the next comment is more docstring

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
