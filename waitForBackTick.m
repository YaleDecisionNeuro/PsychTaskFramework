function waitForBackTick;
    % TODO: get default from settings
    % TODO: Allow change through argument
while 1
    [keyisdown, secs, keyCode, deltaSecs] = KbCheck;
    if keyisdown && keyCode(KbName('5%'))==1
        break
    end
end
end
