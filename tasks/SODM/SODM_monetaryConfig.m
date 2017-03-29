function c = SODM_monetaryConfig(initial_config)
% SODM_CONFIG_MONETARY Configure monetary blocks of the self/other task
if exist('initial_config', 'var')
  c = initial_config;
else
  c = config();
end

c.runSetup.blockName = 'Monetary';
c.runSetup.conditions.payoffKind = 'Monetary';

%% Lookup tables
c.runSetup.lookups.txt = {'$0'; '$5'; '$8'; '$12'; '$25'};
c.runSetup.lookups.img = {'0.jpg'; '5.jpg'; '8.jpg'; '12.jpg'; '25.jpg'};
% Fix images to path
c.runSetup.lookups.img = prependPath(c.runSetup.lookups.img, c.task.imgPath);
end
