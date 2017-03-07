function [ Data ] = RA(observer)
% RA Runs the requisite scripts (Day 1 or Day 2, order by condition) for VA_RA_PTB.
%
% If folder doesn't exist / data files don't contain records, run Day 1;
% Otherwise, run Day 2
%
% If observer ends in 12569, run L-G / G-L; otherwise, run the opposite

% Get records from data files
dataFolder = fullfile('data', num2str(observer));
if ~exist(dataFolder, 'dir')
  mkdir(dataFolder);
  gainsBlocksRecorded = 0;
  lossBlocksRecorded = 0;
else
  [ gainsBlocksRecorded, lossBlocksRecorded, dateBegun ] = recordedSessionsInDataFiles(observer);
end

% Back up data folder
copyfile('data', fullfile('..', sprintf('data-%s', datetime)));

% What order should the blocks be run in?
lastDigit = mod(observer, 10);
lossStartDigits = [1 2 4 6 9];
startLoss = ismember(lastDigit, lossStartDigits);

% runFunctions{i}(observer) will run the function at i-th position with `observer` as arg
if startLoss
  runFunctions = {@RA_Loss1_v7, @RA_Gains1_v7, @RA_Gains2_v7, @RA_Loss2_v7};
else
  runFunctions = {@RA_Gains1_v7, @RA_Loss1_v7, @RA_Loss2_v7, @RA_Gains2_v7};
end

% Cases: no records, half-Day-1 records, Day 1 records, half-Day-2 records, Day 2 records
aborted = false;
if gainsBlocksRecorded + lossBlocksRecorded == 0
  % No records yet!
  response = prompt(sprintf('Participant %d appears to be a new subject. Continue? (y/[n])', observer), 's');
  if strcmp(response, 'y')
    runFunctions{1}(observer);
    runFunctions{2}(observer);
  end
elseif gainsBlocksRecorded + lossBlocksRecorded < 4
  % Some Day 1, but not all
  response = prompt(sprintf(['Participant %d appears to have an interrupted Day 1 ', ...
    'session (two blocks). This will run the other two blocks from Day 1. Continue? (y/[n])', observer), 's');
  if strcmp(response, 'y')
    if gainsBlocksRecorded < 2
      RA_Gains1_v7(observer);
    else
      RA_Loss1_v7(observer);
    end
  end
elseif gainsBlocksRecorded + lossBlocksRecorded == 4
  % All of Day 1, none of Day 2
  response = prompt(sprintf(['Participant %d appears to have done Session 1. ', ...
    'Continue with Session 2? (y/[n])'], observer), 's');
  if strcmp(response, 'y')
    runFunctions{3}(observer);
    runFunctions{4}(observer);
  end
elseif gainsBlocksRecorded + lossBlocksRecorded < 8
  % Some of Day 2, but not all
  response = prompt(sprintf(['Participant %d appears to have an interrupted Session 2 (two blocks). ', ...
    'This will run the other two blocks. Continue? (y/[n])', observer), 's');
  if strcmp(response, 'y')
    if gainsBlocksRecorded < 4
      RA_Gains2_v7(observer);
    else
      RA_Loss2_v7(observer);
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
[ gainsBlocksRecorded, lossBlocksRecorded, dateBegun ] = function recordedSessionsInDataFiles(observer)
folder = fullfile('data', num2str(observer), 'RA_%s_%d');
lossFile = sprintf(folder, 'LOSS', observer);
gainFile = sprintf(folder, 'GAINS', observer);

lossData = getfield(load(lossFile, 'Data'), 'Data');
gainData = getfield(load(gainFile, 'Data'), 'Data');

dateFormat = 'yyyymmddThhMMss';
lossDate = datenum(lossData.date, dateFormat);
gainsDate = datenum(gainsData.date, dateFormat);

dateBegun = datestr(min(lossDate, gainsDate));
end
