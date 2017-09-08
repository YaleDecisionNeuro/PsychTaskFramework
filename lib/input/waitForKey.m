function [keyIsDown, responseTime, keyCode, deltaSecs] = waitForKey(keyName, seconds)
% Wait until the key supplied by `keyName` is pressed
%   (or, optionally, until `seconds` seconds elapse).
%
% Args:
%   keyName: A PsychToolBox key code of keys that can terminate the wait. It
%     can either be a single character array or a cell array of key codes.
%   seconds: An integer count of seconds, after which the function will stop
%     even if the desired key was not pressed.
%
% Returns:
%   4-element tuple containing
%
%   - **keyIsDown**: A boolean of whether the key was pressed.
%   - **responseTime**: The time elapsed until the key was pressed.
%   - **keyCode**: Key code of the pressed key.
%   - **deltaSecs**: The length of time it took for key to be pressed.
%
% Note: 
%   If you require precision, bear in mind that some time elapsed between
%   drawing your phase and calling this function. To that end, you should
%   supply `phaseConfig.duration - (GetSecs() - phaseStartTS)` rather than the
%   mere `phaseConfig.duration` as the `seconds` argument.
%
% Todo: 
%   * Use KbQueueCheck instead of KbCheck, as per Harvard CBS FAQ.
%   * Return the pressed key(s) instead of keyCode.

0; % to prevent sphinx from thinking that the next comment is more docstring

% Don't stop waiting if seconds is not set
if ~exist('seconds', 'var')
    seconds = Inf;
end

% To avoid logic duplication, convert any argument into cell array
if ischar(keyName)
    keyName = {keyName};
end

if ~iscell(keyName)
    % Was neither string nor cell array -> invalid argument
    error('waitForKey: supply a string or an array of strings.');
else
    breakKey = cell2mat(cellfun(@(x) KbName(x), keyName, 'UniformOutput', false));
end
% Special case: zero duration
if seconds == 0
    [~, ~, keyCode, ~] = KbCheck;
    keyIsDown = false;
    responseTime = 0;
    deltaSecs = NaN;
    return;
end
% FIXME: Use `RestrictKeysForKbCheck`?
initialTime = GetSecs();
KbCheckTimestamp = initialTime;
while KbCheckTimestamp - initialTime <= seconds
    WaitSecs(0.01);
    [keyIsDown, KbCheckTimestamp, keyCode, deltaSecs] = KbCheck;
    if keyIsDown && any(keyCode(breakKey)) == 1
        break
    end
end
responseTime = KbCheckTimestamp - initialTime;
end
