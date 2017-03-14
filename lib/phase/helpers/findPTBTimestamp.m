function [ PTBTimestamp, found ] = findPTBTimestamp(trialData, phaseSettings)
% Return the right timestamp from the (optional) structures, or getSecs() if
%   nothing suitable is find.
%
% Suitable locations: `startTimestamp` field in `phaseSettings`,
% `${PHASENAME}Start` or `${PHASENAME}StartTS` in `trialData`.

% If nothing is found, earlier timestamp is better than later
PTBTimestamp = GetSecs();
found = false;

if exist('phaseSettings', 'var')
  phaseName = phaseSettings.name;
  if isfield(phaseSettings, 'startTimestamp')
    PTBTimestamp = phaseSettings.startTimestamp;
    found = true;
    return;
  end

  % Nested call because if phaseSettings isn't provided, no way to identify
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
