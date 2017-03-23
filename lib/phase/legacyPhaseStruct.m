function [ phases_RA ] = legacyPhaseStruct
% Default phase settings for R&A-based tasks. Deprecated.
  phases_RA.showChoice = struct;
  phases_RA.showChoice.phaseScript = @phase_showChoice;
  phases_RA.showChoice.action = @action_display;
  phases_RA.showChoice.duration = 6;

  phases_RA.response = struct;
  phases_RA.response.phaseScript = @phase_response;
  phases_RA.response.action = @action_collectResponse;
  phases_RA.response.duration = 3.5;

  phases_RA.feedback = struct;
  phases_RA.feedback.phaseScript = @phase_feedback;
  phases_RA.feedback.action = @action_display;
  phases_RA.feedback.duration = 0.5;

  phases_RA.intertrial = struct;
  phases_RA.intertrial.phaseScript = @phase_intertrial;
  phases_RA.intertrial.action = @action_display;
  phases_RA.intertrial.duration = NaN;
end
