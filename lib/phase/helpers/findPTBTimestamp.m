function [ PTBTimestamp, found ] = findPTBTimestamp(trialData, phaseConfig)
% Return the right timestamp from the (optional) structures, or getSecs() if
%   nothing suitable is found.
%
% Args:
%   trialData: A table of trial information
%   phaseConfig: Phase configuration
% 
% Returns:
%   PTBTimestamp: A record of the trial timestamp. 
%   found: A variable to determine what timestamp measure to use.
%
% Suitable locations: `startTimestamp` field in `phaseConfig`,
% `${PHASENAME}Start` or `${PHASENAME}StartTS` in `trialData`.

% If nothing is found, earlier timestamp is better than later
PTBTimestamp = GetSecs();
found = false;

if exist('phaseConfig', 'var')
  phaseName = phaseConfig.name;
  if isfield(phaseConfig, 'startTimestamp')
    PTBTimestamp = phaseConfig.startTimestamp;
    found = true;
    return;
  end

  % Nested call because if phaseConfig isn't provided, no way to identify
  % the right timestamp
  if exist('trialData', 'var')
    nameWithoutTS = sprintf('%sStart', phaseName);
    nameWithTS = sprintf('%sTS', nameWithoutTS);
    if isfield(trialData, nameWithTS)
      PTBTimestamp = trialData.(nameWithTS);
      found = true;
      return;
    elseif isfield(trialData, nameWithoutTS)
      PTBTimestamp = trialData.(nameWithoutTS);
      found = true;
      return;
    end
  end
end
end
