function waitForBackTick;
while 1
    [keyisdown, secs, keyCode, deltaSecs] = KbCheck;
    if keyisdown && keyCode(KbName('5%'))==1
        break
    end
end
end
