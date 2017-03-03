function waitForKey(keyName)
% WaitForKey Until the key supplied by `keyName` is pressed, keep looping.
% TODO: Return the key that broke the while, and getSecs of the event
% FIXME: Use KbQueueCheck instead of KbCheck, as per Harvard CBS FAQ
% FIXME: Deal with an array of possible keys

breakKey = KbName(keyName);

while 1
    [keyisdown, secs, keyCode, deltaSecs] = KbCheck;
    if keyisdown && keyCode(breakKey) == 1
        break
    end
end
end
