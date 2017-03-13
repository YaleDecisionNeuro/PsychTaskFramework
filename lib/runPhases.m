function trialData = runPhases(trialData, blockSettings)
% RUNPHASES Fully generalized workhorse function to display any phases of an
%   individual trial, as defined using PhaseConfig objects in
%   blockSettings.game.phases.

% Record the properties of this trial to trialData
trialData.trialStartTime = datevec(now);

% Create convenience variables
s = blockSettings.game;
phases = s.phases;

% Run through all phases
for k = 1:numel(phases)
  phaseSettings = phases{k};
  trialData = runPhase(trialData, blockSettings, phaseSettings);
end

% Print choice to stdout
disp(choiceReport(trialData));

trialData.trialEndTime = datevec(now);
end
