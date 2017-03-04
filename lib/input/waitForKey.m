function [keyIsDown, duration, keyCode, deltaSecs] = waitForKey(keyName, until)
% WaitForKey Wait until the key supplied by `keyName` is pressed
%   (or, optionally, until `until` seconds elapse).
%
% FIXME: Use KbQueueCheck instead of KbCheck, as per Harvard CBS FAQ
% FIXME: Return the pressed key(s) instead of keyCode

% Don't stop waiting if until is not set
if ~exist('until', 'var')
    until = Inf;
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

% FIXME: Use `RestrictKeysForKbCheck`?
initialTime = GetSecs();
secs = initialTime;
while secs - initialTime < until
    WaitSecs(0.01);
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    if keyIsDown && any(keyCode(breakKey)) == 1
        break
    end
end
duration = secs - initialTime;
end
