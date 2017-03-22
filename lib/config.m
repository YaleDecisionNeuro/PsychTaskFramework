function s = config(changes)
% Default documented settings for all tasks in a freely modifiable struct.
%
% Although `config` contains task-wide settings, it is typically modified with
% block-specific settings right before being passed to `runBlock` or
% equivalent.
%
% Colors, when given, are RGB colors. PTB also accepts RGBA and CLUT.
%
% The defaults used here err on the side of catering to LevyLab's R&A paradigm.
% If you're not using it, nuke s.objects from high orbit.
%
% TODO: Implement `changes` to bring some order to post-return alterations.

%%% Defaults
%% Debugging
% This will run PsychDebugWindowConfiguration unless overruled in a downstream
% config. (This means skipping sync checks and transparent background.)
%
% You should turn it off when your task is ready.
s.debug = true;

%% Machine settings
% This is where you set properties important for PsychToolBox to function
% properly. Consult PTB manual if these are unclear.
s.device.KbName = 'UnifyKeyNames';
s.device.screenId = max(Screen('Screens'));
s.device.windowPtr = NaN; % Must get filled in with Screen('Open')
s.device.screenDims = NaN; % Screen('Open') will open in this `rect`. If not set, will be set by Screen('Open').
s.device.sleepIncrements = 0.01; % In seconds, how often do we check for keyboard presses, or whether enough time elapsed in a period? 0 for as often as possible

% Should runBlock automatically save the user data file? If so, when?
s.device.saveAfterBlock = true;
s.device.saveAfterTrial = false;

% Which keys does the device listen to?
% `breakKeys` are what "press key to start" phases will wait for. The default
%   is '5%', as that's what many fMRI scanners use to signal the start of
%   recording.
s.device.breakKeys = {'5%'};
% `choiceKeys` are the keys that the subject is directed to use to signal their
%   choice.
s.device.choiceKeys = {'1!', '2@'};

%% Graphics defaults
% To prevent yourself from having to change many settings in many places, use
% `s.graphicDefault.X` to define property `X` for a particular display feature. This
% way, you'll only have to change it in one spot,
s.graphicDefault.fontName = 'Arial';
s.graphicDefault.fontColor = [255 255 255];
s.graphicDefault.fontSize = 42;
s.graphicDefault.bgrColor = [0 0 0];
s.graphicDefault.padding = 10; % px to leave between objects

%% Features of objects that your task displays
% This is the Wild West portion of property settings. s.(object) should contain
% whatever properties your drawX script will require to properly draw them. By
% current convention, this does not have to include specific coordinates, which
% your display script might calculate on the basis of specific device
% properties (like screen width & height). However, only the draw scripts you
% write will rely on these values; the way you choose to encode them in the
% settings is up to you. (This might change in future versions.)
%
% The defaults pertain to R&A task objects. This chiefly means the lottery
% box and associated labels; the reference value (i.e. alternative to the
% lottery); and the graphical properties of the response prompt, feedback
% display, and intertrial-interval indicator.

% R&A: Box properties
s.objects.lottery.box.dims = [150 300];
s.objects.lottery.box.probColors = [255 0 0; 0 0 255];
s.objects.lottery.box.ambigColors = [127 127 127];
s.objects.lottery.box.occluderWidth = 170;

% What are the "human" names of the lottery colors? These should be in the same
% order as `.box.probColors` set above.
%
% Useful for contexts in which color indices need to be translated, especially
% for a choice evaluation for the participant's eyes.
s.objects.lottery.box.colorKey = {'blue', 'red'};

s.objects.lottery.stakes.fontSize = s.graphicDefault.fontSize;
s.objects.lottery.stakes.fontColor = s.graphicDefault.fontColor;

s.objects.lottery.probLabels.fontSize = 20;
s.objects.lottery.probLabels.fontColor = s.graphicDefault.fontColor;

% R&A: Reference properties
s.objects.reference.fontSize = s.graphicDefault.fontSize;
s.objects.reference.fontColor = s.graphicDefault.fontColor;

% R&A: Indicator properties
s.objects.prompt.dims = [40 40];
s.objects.prompt.color = [0 255 0];
s.objects.prompt.pos = 'center'; % TODO: This should be a special value
s.objects.prompt.shape = 'Oval';

s.objects.feedback.colorNoAnswer = [255 255 255];
s.objects.feedback.colorAnswer = [255 255 0];
s.objects.feedback.dims = [40 40];
s.objects.feedback.shape = 'Rect';

s.objects.intertrial.color = [255 255 255];
s.objects.intertrial.shape = 'Oval';
s.objects.intertrial.dims = [40 40];

%% Settings for the task as a whole
% Obligatory: set it to identify the task for the datafiles
s.task.taskName = char.empty;
s.task.taskPath = char.empty;

% Should the intertrial period be extended to last as long as the sum of each
% phase's maximum durations? In other words, should the ITI display duration
% ensure that each trial lasts an exactly set time, regardless of the
% participants's choices that might accelerate the trial timeline?
%
% If the task is set in a scanner, you almost certainly want to set it to true.
s.task.constantTrialDuration = false;

% How many blocks and sessions should be generated? (Currently, PTF only
% supports equal-length blocks and sessions. In the future)
s.task.numBlocks = NaN; % Overall number of blocks in the task
s.task.blocksPerSession = NaN; % Number of blocks in each session
s.task.blockLength = 1; % NOTE: Deprecated in favor of numBlocks

% (Maximum) durations of the various trial phases
s.game.durations.showChoice = 6;
s.game.durations.response = 3.5;
s.game.durations.feedback = 0.5;
s.game.durations.ITIs = [4 * ones(1, 10), 6 * ones(1, 10), 8 * ones(1, 10)];
% These have to be in each block, in some order -- in most fMRI block designs,
% the block has to be constant. Some designs might want to shuffle these in
% particular ways, just like items in `s.game.levels`; other designs might want
% to omit ITIs altogether.
%
% However, current method of shuffling ITIs will work as long as their number
% divides the number of trials within a block without remainder.

%% Block properties
% Naming. Useful to quickly identify the properties used to run a trial -- it's
% to your benefit to make sure that this uniquely identifies your setting for
% the specific task and task block
s.game.block.name = NaN;

% NOTE: If you have a trial you'd like to repeat in every trial in a particular
%   place in the block, you'll define it in .repeatTrial and the in-block
%   position(s) in .repeatIndex
% s.game.block.repeatIndex = NaN;
% s.game.block.repeatTrial = [];

%% Available trial values
% Up to you how you use these -- it's suggested that you pass them to a trial
% generating function that will re-make them into an orderly shuffled table
%
% The following values are just samples of what you can use.
s.game.levels.stakes = [5, 6, 7, 8];
s.game.levels.probs = [.25 .5 .75];
s.game.levels.ambigs = [.24 .5 .74];
s.game.levels.stakes_loss = 0;
s.game.levels.reference = 5;
s.game.levels.colors = [1 2];
s.game.levels.repeats = 1;

%% Execution functions
% To re-use the infrastructure this framework provides, you can supply only the
% change that you need for your own task. You can do this by providing a
% "function handle" - a reference to a function you wrote preceded by the @
% sign. (For instance, as of 13 Mar 2017, the self/other decision-making task
% draws backgrounds using @SODM_drawBgr and displays choices using
% @SODM_showChoice.)
%
% IMPORTANT: These are *crucial* items to set, as they define what components
% your task will be using.
%
% NOTE: It is important to ensure that whatever trial script you'll be using
% will be on the MATLAB path, i.e. added with `addpath(script_location)`.
%
% You can learn more about function handles at
% https://www.mathworks.com/help/matlab/matlab_prog/creating-a-function-handle.html.)

% %% Trial script: trialFn
% trialFn defines what trial script each `runBlock` should use to conduct the
% trials. The trial script is responsible for the order in which task phases
% are invoked.
%
% If you wish to re-use the standard R&A task designs, you'll want to keep this
% set to @runRATrial (which you can find in lib/). If you wish to take
% advantage of the generic phase interface, use @runGeneralTrial.

s.game.trialFn = @runRATrial;

% %% Phase scripts
% NOTE: This section only applies if you're using @runRATrial as your trial
% script. @runGenericTrial does not check these settings.
%
% If you're only changing some element of a phase, but you're happy with the
% standard order of phases (i.e. choice display, response prompt, feedback,
% intertrial), you can substitute a function here. It should take, and return,
% the same arguments that the phase function in lib/phase does. (In general,
% this is `sampleFn(trialData, blockSettings, phaseSettings)`.)
%
% By design, showChoicePhaseFn is left blank. `runRATrial` will complain if it is
% not set, or if any of the phase function handles below are unset. While you
% might avoid setting it by writing your own trial script, it is recommended
% that you still leverage these settings; it will make your task easier to
% maintain and understand for your collaborators.
%
% By design, s.game.responsePhaseFn is set to @phase_response; however, if your
% showChoice function collects responses during the display, it can be set to
% NaN.

s.game.showChoicePhaseFn = NaN;
s.game.responsePhaseFn = @phase_response;
s.game.feedbackPhaseFn = @phase_feedback;
s.game.intertrialPhaseFn = @phase_ITI;

% %% (Optional) phase action scripts
s.game.showChoiceActionFn = NaN;
s.game.responseActionFn = NaN;
s.game.feedbackActionFn = NaN;
s.game.intertrialActionFn = NaN;

% %% Reference draw script
% Reference draw script defines how the "reference" (value alternative to the
% gamble) will be drawn. It is specific to the kind of choices you present. Its
% default arguments are drawRef(blockSettings, trialData).

s.game.referenceDrawFn = @drawRef;

% %% Background draw script
% The default background draw script is called between the phases to set
% background and font properties back to default. You might wish to alter it
% to, e.g., to make sure that the reference is drawn at all times.
%
% By convention, the background draw script only takes block settings and a
% potential callback function as an argument, and does not access nor modify
% collected data. Optionally, you can specify the callback function in
% s.game.bgrDrawCallbackFn(blockSettings).

s.game.bgrDrawFn = @drawBgr;
s.game.bgrDrawCallbackFn = NaN;

%% Event functions
% Functions that are automatically executed before and after every block these
% settings are applied to.

% @preBlock is a helpful default in `lib/phase` - displays block number before
% every block, waits for the press of '5%' button to start first trial.

s.game.preBlockFn = @preBlock;
s.game.postBlockFn = NaN;

%% Lookup tables
% If you're using any images or map your payoff values to a textual label,
% you'd define the lookup tables here! For an example, see MDM_config. For an
% explanation, see the README.

% s.lookups.stakes.txt = {'destitution', 'status quo', 'unimaginable riches'}

%% Changes
% FIXME: This fails with sub-subfields, or rather, replaces them wholesale
% TODO: Make recursive
% TODO: Scream when changes contains a field that the skeleton doesn't
if exist('changes', 'var')
  props = fieldnames(changes);
  for i = 1:numel(props)
    % s.(props{i}) = changes.(props{i});
  end
end

end
