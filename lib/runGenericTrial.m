function trialData = runGenericTrial(trialData, blockConfig)
% RunGenericTrial Fully generalized workhorse function to display any phases of
%   an individual trial, as defined using PhaseConfig objects in
%   blockConfig.trial.phases.

% Record the properties of this trial to trialData
trialData.trialStartTime = datevec(now);

% Create convenience variables
s = blockConfig.trial;
phases = s.phases;
phaseCount = numel(phases);
if phaseCount == 0
  error(['config.trial.phases is empty; check your setup. Are you sure you', ...
    'want @runGenericTrial to be your trial function?']);
end

% Run through all phases
for k = 1:numel(phases)
  phaseConfig = phases{k};
  trialData = runPhase(trialData, blockConfig, phaseConfig);
end

% Print choice to stdout
disp(choiceReport(trialData));

trialData.trialEndTime = datevec(now);
end
