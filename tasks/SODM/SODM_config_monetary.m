function s = SODM_config_monetary(initial_config)
% SODM_CONFIG_MONETARY Configure monetary blocks of the self/other task
% FIXME: For simplicity, these block settings are only displaying dollar
% values without the images. This should change.
  if exist('initial_config', 'var')
    s = initial_config;
  else
    s = config();
  end

  addpath('./tasks/RA'); % borrowing RA functions for now

  s.runSetup.blockName = 'Monetary';
  s.runSetup.conditions.payoffKind = 'Monetary';

  %% Lookup tables
  s.runSetup.lookups.txt = {'$0'; '$5'; '$8'; '$12'; '$25'};
  s.runSetup.lookups.img = {'0.jpg'; '5.jpg'; '8.jpg'; '12.jpg'; '25.jpg'};
  % Fix images to path
  s.runSetup.lookups.img = prependPath(s.runSetup.lookups.img, s.task.imgPath);
end
