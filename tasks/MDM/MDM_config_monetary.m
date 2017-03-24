function s = MDM_config_monetary(initial_config)
% MDM_CONFIG Return settings specific to the monetary portion of MDM by
%   modifying the general MDM_config pass as argument.

% Load defaults
s = initial_config;

%% Block properties
s.runSetup.blockName = 'Monetary';

%% Lookup tables
s.runSetup.lookups.txt = {'$0'; '$5'; '$8'; '$12'; '$25'};
s.runSetup.lookups.img = {'0.jpg'; '5.jpg'; '8.jpg'; '12.jpg'; '25.jpg'};
% Fix images to path
s.runSetup.lookups.img = prependPath(s.runSetup.lookups.img, s.task.imgPath);
end
