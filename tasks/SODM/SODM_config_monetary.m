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

  s.game.block.name = 'Monetary';

  %% Lookup tables
  s.lookups.stakes.txt = {'$0'; '$5'; '$8'; '$12'; '$25'};
  s.lookups.stakes.img = {'0.jpg'; '5.jpg'; '8.jpg'; '12.jpg'; '25.jpg'};
  % Fix images to path
  s.lookups.stakes.img = prependPath(s.lookups.stakes.img, s.task.imgPath);
end
