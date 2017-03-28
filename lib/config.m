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
s.device.screenId = max(Screen('Screens'));
s.device.windowPtr = NaN; % Must get filled in with Screen('Open')
s.device.screenDims = NaN; % Screen('Open') will open in this `rect`. If not set, will be set by Screen('Open').

% Machine / MATLAB settings
s.device.sleepIncrements = 0.01; % In seconds, how often do we check for keyboard presses, or whether enough time elapsed in a period? 0 for as often as possible
s.device.rngAlgorithm = 'mt19937ar'; % see RandStream.list for other options
s.device.rngSeed = sum(100 * clock);

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
% for a choice evaluation for the subject's eyes.
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
% Obligatory: set it to identify the task for the datafiles and load images
s.task.taskName = char.empty;
s.task.taskPath = char.empty;
s.task.imgPath = char.empty;

% Should the intertrial period be extended to last as long as the sum of each
% phase's maximum durations? In other words, should the ITI display duration
% ensure that each trial lasts an exactly set time, regardless of the
% subjects's choices that might accelerate the trial timeline?
%
% If the task is set in a scanner, you almost certainly want to set it to true.
s.task.constantBlockDuration = false;

% How many blocks and sessions should be generated? (Currently, PTF only
% supports equal-length blocks and sessions. In the future)
s.task.numBlocks = NaN; % Overall number of blocks in the task
s.task.blocksPerSession = NaN; % Number of blocks in each session
s.task.blockLength = 1; % NOTE: Deprecated in favor of numBlocks

% %%% General functions that your task will re-use
% To re-use the infrastructure this framework provides, you can supply only the
% change that you need for your own task. You can do this by providing a
% "function handle" - a reference to a function you wrote preceded by the @
% sign. (For instance, the self/other decision-making task draws additional
% condition information into the backgrounds using @SODM_drawCondition set as
% bgrDrawCallbackFn.)

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
s.task.fnHandles.trialFn = @runRATrial;

% %% Event functions
% Functions that are automatically executed before and after every block these
% settings are applied to.

% @preBlock is a helpful default in `lib/phase` - displays block number before
% every block, waits for the press of `breakKeys` button to start first trial.
s.task.fnHandles.preBlockFn = @preBlock;
s.task.fnHandles.postBlockFn = NaN;

% %% Background draw script
% The default background draw script is called between the phases to set
% background and font properties back to default. You might wish to alter it
% to, e.g., to make sure that the reference is drawn at all times.
%
% By convention, the background draw script only takes block settings and a
% potential callback function as an argument, and does not access nor modify
% collected data. Optionally, you can specify the callback function in
% s.task.fnHandles.bgrDrawCallbackFn(blockSettings).
s.task.fnHandles.bgrDrawFn = @drawBgr;
s.task.fnHandles.bgrDrawCallbackFn = NaN;

% %% Reference draw script
% Reference draw script defines how the "reference" (value alternative to the
% gamble) will be drawn. It is specific to the kind of choices you present. Its
% default arguments are drawRef(blockSettings, trialData).
s.task.fnHandles.referenceDrawFn = @drawRef;

%%% Trial-specific settings
% Configure what values your trials will be generated with, and what functions
% and actions each trial's phases should use.

% `.phases` is a cell array of PhaseConfigs (see lib/phase/phaseConfig.m).
% Each cell defines what phase function oversees the execution of the
% phase, what action should be taken at the end of the phase, how long the
% phase should last and, optionally, what draw scripts should be invoked.
% See tasks/HLFF/HLFF_config for an example.
s.trial.phases = cell.empty;

% %% Legacy phase scripts
% NOTE: This section only applies if you're using @runRATrial as your trial
% script. @runGenericTrial does not check these settings.
%
% If you wish to run "old-school" Levylab R&A task with legacy settings,
% you should fill `s.legacyPhases` with a call to `legacyPhaseStruct`. (You can,
% and should, run the task with the new phase architecture, but this will
% remain an option.) Check out lib/phase/legacyPhaseStruct.m for details.
s.trial.legacyPhases = struct.empty;

%% What values should the trial be generated with?
% These values are R&A-centric in that generateTrials and generateBlocks only
% knows how to generate different combinations of stakes, probs, and ambigs.
% If you want to generate combinations beyond that, you might have to write
% your own functions for it.

% Stakes, or payoffs, are the possible win-values in the lottery. Stakes_loss
% are the possible loss values in the lottery. Reference is the available
% no-risk alternative.
%
% If you're using images or textual labels, you will need to use *indices* of
% s.runSetup.lookups.txt and s.runSetup.lookups.img. For instance, if the textual
% description of possible outcomes is {"no cookies", "one cookie", "two
% cookies", "a dozen cookies"}, and you want possible lottery win values to be
% two cookies, loss value to be no cookie and sure option to be one cookie,
% you'd need to use
%
%   stakes = [2]; stakes_loss = 0; reference = 1;
%
% in order to get s.runSetup.lookups.txt{2} in case of a win.
s.trial.generate.stakes = [5, 6, 7, 8];
s.trial.generate.stakes_loss = 0;
s.trial.generate.reference = 5;

% Probabilities for full-information trials.
s.trial.generate.probs = [.25 .5 .75];

% Ambiguities for partial-information trials. The default trial-generation
% procedure only uses P = .5, but the drawLotto script can handle any base
% probability value that's larger than half the ambiguity.
s.trial.generate.ambigs = [.24 .5 .74];

% How much "hang time" should there be between trials?
%
% If a single value n is provided, then all intertrial periods will be n
% seconds long. If multiple values are provided -- ideally as many as there
% will be trials in the block -- they will be randomly distributed among the
% trials within the block.
%
% If you need trials of constant length, intertrial period should be extended
% by whatever time the subjects saved by answering early. In order to do
% that, set `s.task.constantBlockDuration` to `true`.
s.trial.generate.ITIs = 5;
% NOTE: Values for the fMRI R&A task are
%   [4 * ones(1, 10), 6 * ones(1, 10), 8 * ones(1, 10)];

% Color indices. Currently, they refer to `s.objects.lottery.box.probColors`
% and `s.objects.lottery.box.colorKey`.
s.trial.generate.colors = [1 2];

% How many times should a unique stakes-prob-ambig combination be repeated in
% the generation process?
s.trial.generate.repeats = 1;

% If there is an additional trial (or trials) that you wish to run in every
% block, this is where you would define them. See the implemented task configs
% for examples.
%
% If `.catchIdx` is left as NaN, the catch trial(s) will be inserted into
% a random position in the block. If it is a number n, it will be injected at
% n-th row.
%
% NOTE: The ITI for the catch trial(s) should be defined here, not in the `ITIs`
% field above.
s.trial.generate.catchTrial = table.empty;
s.trial.generate.catchIdx = NaN;

%%% Run settings
% This will be specific to each block that you run. None of these settings have
% a default, although default is suggested.

%% Block properties
% Block name is useful to quickly identify the properties used to run a trial
% -- it's to your benefit to make sure that this uniquely identifies your
% setting for the specific task and task block. It is used this way in data
% export.
s.runSetup.blockName = char.empty;

%% Lookup tables
% If you're using any images or map your payoff values to a textual label,
% you'd define the lookup tables here! For an example, see MDM_config. For an
% explanation, see the README.
s.runSetup.lookups.txt = cell.empty;
s.runSetup.lookups.img = cell.empty;

%% Textures
% As a rule, if your lookups contain any images, you will need to generate
% PsychToolBox textures. This framework expects you to do this by populating
%
%   settings.runSetup.textures = loadTexturesFromConfig(settings);
%
% at a point in your task master script when PTB is already loaded.
s.runSetup.textures = cell.empty;

%% Conditions
% PTF allows you to define arbitrary conditions. The conditions are used *in
% addition to*, rather than instead of, block-specific configuration;
% primarily, they allow for readable data export. It is heavily recommended
% that you label your conditions in your per-block configs.
%
% PTF uses a struct to store the conditions. While you can store any value in
% each struct field, it is recommended that you stick to numbers and strings.
% Here's an example set of conditions:
%
% s.runSetup.conditions.domain = 'Gains';
% s.runSetup.conditions.payoffKind = 'Monetary';
%
% As default, PTF will set an empty `payoffKind` condition that you should
% change in your task/block config file:
s.runSetup.conditions.payoffKind = char.empty;

% %% Changes
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
