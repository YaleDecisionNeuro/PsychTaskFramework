function [ phases_RA ] = legacyPhaseStruct
% Default phase config for R&A-based tasks. Deprecated.
%
% If you're only changing some element of a phase, but you're happy with the
% standard order of phases (i.e. choice display, response prompt, feedback,
% intertrial), you can substitute a function here. It should take, and return,
% the same arguments that the phase function in lib/phase does. (In general,
% this is `sampleFn(trialData, blockConfig, phaseConfig)`.)
%
% By design, showChoicePhaseFn is left blank. `runRATrial` will complain if it is
% not set, or if any of the phase function handles below are unset. While you
% might avoid setting it by writing your own trial script, it is recommended
% that you still leverage these config; it will make your task easier to
% maintain and understand for your collaborators.
%
% By design, s.game.responsePhaseFn is set to @phase_response; however, if your
% showChoice function collects responses during the display, it can be set to
% NaN.

phases_RA.showChoice = struct;
phases_RA.showChoice.phaseScript = @phase_showChoice;
phases_RA.showChoice.action = NaN; % @action_display;
phases_RA.showChoice.duration = 6;

phases_RA.response = struct;
phases_RA.response.phaseScript = @phase_response;
phases_RA.response.action = NaN; % @action_collectResponse;
phases_RA.response.duration = 3.5;

phases_RA.feedback = struct;
phases_RA.feedback.phaseScript = @phase_feedback;
phases_RA.feedback.action = NaN; % @action_display;
phases_RA.feedback.duration = 0.5;

phases_RA.intertrial = struct;
phases_RA.intertrial.phaseScript = @phase_ITI;
phases_RA.intertrial.action = NaN; % @action_display;
phases_RA.intertrial.duration = NaN;
% Might be deprecated even within the legacy use?
%
% [4 * ones(1, 10), 6 * ones(1, 10), 8 * ones(1, 10)];
%
% These have to be in each block, in some order -- in most fMRI block designs,
% the block has to be constant. Some designs might want to shuffle these in
% particular ways, just like items in `s.trial.generate`; other designs might want
% to omit ITIs altogether.
%
% However, current method of shuffling ITIs will work as long as their number
% divides the number of trials within a block without remainder.
% Color indices. Currently, they refer to `s.objects.lottery.box.probColors`
% and `s.objects.lottery.box.colorKey`.
end
