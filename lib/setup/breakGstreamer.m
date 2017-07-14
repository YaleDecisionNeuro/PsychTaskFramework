function breakGstreamer()
%breakGstreamer Remove GStreamer, if available, from the system path
systempath = getenv('PATH');
systempath = erase(systempath, ...
  {[getenv('GSTREAMER_1_0_ROOT_X86_64'), 'bin'], ...
   [getenv('GSTREAMER_1_0_ROOT_X86'), 'bin']});
setenv('PATH', systempath);
end

