function [ Data ] = RA(observer)
% RA Runs the requisite scripts (Day 1 or Day 2, order by condition) for VA_RA_PTB.
%
% Does the work of "what script to run" behind the screens.

% Get records from data files
dataFolder = fullfile('data', num2str(observer));
if ~exist(dataFolder, 'dir')
  mkdir(dataFolder);
  gainsBlocksRecorded = 0;
  lossBlocksRecorded = 0;
else
  [ gainsBlocksRecorded, lossBlocksRecorded, dateBegun ] = getInfoFromDataFiles(observer);
  fprintf('Reading existing data files from %s; experiment started on %s!\n', dataFolder, dateBegun);
end

% Back up data folder
if ~exist('backup', 'dir')
  mkdir('backup');
end
copyfile('data', fullfile('backup', sprintf('data-%s', datetime)));

% What order should the blocks be run in?
lastDigit = mod(observer, 10);
lossStartDigits = [1 2 4 6 9];
startLoss = ismember(lastDigit, lossStartDigits);

% runFunctions{i}(observer) will run the function at i-th position with `observer` as arg
if startLoss
  runFunctions = {@RA_Loss1_v6, @RA_Gains1_v6, @RA_Gains2_v6, @RA_Loss2_v6};
else
  runFunctions = {@RA_Gains1_v6, @RA_Loss1_v6, @RA_Loss2_v6, @RA_Gains2_v6};
end

% Cases: no records, half-Day-1 records, Day 1 records, half-Day-2 records, Day 2 records
if gainsBlocksRecorded + lossBlocksRecorded == 0
  % No records yet!
  response = input(sprintf('Participant %d appears to be a new subject. Continue? (y/[n])', observer), 's');
  if strcmp(response, 'y')
    runFunctions{1}(observer);
    runFunctions{2}(observer);
  end
elseif gainsBlocksRecorded + lossBlocksRecorded < 4
  % Some Day 1, but not all
  response = input(sprintf(['Participant %d appears to have an interrupted Day 1 ', ...
    'session (two blocks). This will run the other two blocks from Day 1. Continue? (y/[n])'], observer), 's');
  if strcmp(response, 'y')
    if gainsBlocksRecorded < 2
      RA_Gains1_v6(observer);
    else
      RA_Loss1_v6(observer);
    end
  end
elseif gainsBlocksRecorded + lossBlocksRecorded == 4
  % All of Day 1, none of Day 2
  response = input(sprintf(['Participant %d appears to have done Session 1. ', ...
    'Continue with Session 2? (y/[n])'], observer), 's');
  if strcmp(response, 'y')
    runFunctions{3}(observer);
    runFunctions{4}(observer);
  end
elseif gainsBlocksRecorded + lossBlocksRecorded < 8
  % Some of Day 2, but not all
  response = input(sprintf(['Participant %d appears to have an interrupted Session 2 (two blocks). ', ...
    'This will run the other two blocks. Continue? (y/[n])'], observer), 's');
  if strcmp(response, 'y')
    if gainsBlocksRecorded < 4
      RA_Gains2_v6(observer);
    else
      RA_Loss2_v6(observer);
    end
  end
else
  % Everything recorded
  error('Participant %d appears to have full records from both sessions. Aborting.', observer);
end

if ~strcmp(response, 'y')
  error('Double-check participant ID or downgrade to individual block scripts.');
end
end

%% Helper functions
function [ gainsBlocksRecorded, lossBlocksRecorded, dateBegun ] = getInfoFromDataFiles(observer)
% getInfoFromDataFiles Loads available data files and counts recorded blocks.
folder = fullfile('data', num2str(observer), 'RA_%s_%d.mat');
lossFile = sprintf(folder, 'LOSS', observer);
gainsFile = sprintf(folder, 'GAINS', observer);

dateFormat = 'yyyymmddThhMMss';
if exist(lossFile, 'file')
  lossData = getfield(load(lossFile, 'Data'), 'Data');
  lossDate = datenum(lossData.date, dateFormat);
  lossBlocksRecorded = numTrialsToBlocks(lossData.choice);
else
  lossDate = Inf;
  lossBlocksRecorded = 0;
end

if exist(gainsFile, 'file')
  gainsData = getfield(load(gainsFile, 'Data'), 'Data');
  gainsDate = datenum(gainsData.date, dateFormat);
  gainsBlocksRecorded = numTrialsToBlocks(gainsData.choice);
else
  gainsDate = Inf;
  gainsBlocksRecorded = 0;
end

if isinf(lossDate) && isinf(gainsDate)
  dateBegun = NaN;
else
  dateBegun = datestr(min(lossDate, gainsDate));
end
end

function [ numBlocks ] = numTrialsToBlocks(choiceData, trialsPerBlock)
% numTrialsToBlocks From the number of participant choices, infer the number of blocks recorded.
%
% If `trialsPerBlock` is not provided, it assumes that there are 31 per block.
if ~exist('trialsPerBlock', 'var')
  trialsPerBlock = 31;
end
numBlocks = length(choiceData) / trialsPerBlock;
end
