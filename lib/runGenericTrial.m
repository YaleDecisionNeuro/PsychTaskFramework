function trialData = runGenericTrial(trialData, blockSettings)
% RunGenericTrial Fully generalized workhorse function to display any phases of
%   an individual trial, as defined using PhaseConfig objects in
%   blockSettings.trial.phases.

% Record the properties of this trial to trialData
trialData.trialStartTime = datevec(now);

% Create convenience variables
s = blockSettings.trial;
phases = s.phases;
phaseCount = numel(phases);
if phaseCount == 0
  error(['config.trial.phases is empty; check your setup. Are you sure you', ...
    'want @runGenericTrial to be your trial function?']);
end

% Run through all phases
for k = 1:numel(phases)
  phaseSettings = phases{k};
  trialData = runPhase(trialData, blockSettings, phaseSettings);
end

% Print choice to stdout
disp(choiceReport(trialData));

trialData.trialEndTime = datevec(now);
end
