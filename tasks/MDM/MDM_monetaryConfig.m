function c = MDM_monetaryConfig(initial_config)
% MDM_CONFIG Return config specific to the monetary portion of MDM by
%   modifying the general MDM_blockDefaults pass as argument.

% Load defaults
c = initial_config;

%% Block properties
c.runSetup.blockName = 'Monetary';
c.runSetup.conditions.payoffKind = 'Monetary';
c.runSetup.conditions.domain = char.empty;

%% Lookup tables
c.runSetup.lookups.txt = {'$0'; '$5'; '$8'; '$12'; '$25'};
c.runSetup.lookups.img = {'0.jpg'; '5.jpg'; '8.jpg'; '12.jpg'; '25.jpg'};
% Fix images to path
c.runSetup.lookups.img = prependPath(c.runSetup.lookups.img, c.task.imgPath);
end
