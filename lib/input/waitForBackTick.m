function waitForBackTick
% WAITFORBACKTICK Until the key "5%" (above QWERTY) is pressed, keep looping.

% TODO: Make modular
% TODO: Return the key that broke the while
% FIXME: Use KbQueueCheck instead of KbCheck, as per Harvard CBS FAQ
while 1
    [keyisdown, secs, keyCode, deltaSecs] = KbCheck;
    if keyisdown && keyCode(KbName('5%'))==1
        break
    end
end
end
