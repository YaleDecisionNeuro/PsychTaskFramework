function fixGStreamer()
%FIXGSTREAMER Add GStreamer, if available, back into the system path

% FIXME: Doesn't work!
return

systempath = getenv('PATH');
gstreamer = { ...
    getenv('GSTREAMER_1_0_ROOT_X86_64'); ...
    getenv('GSTREAMER_1_0_ROOT_X86')};
gstreamer = DeEmptify(gstreamer);
gstreamer = gstreamer{1};
systempath = [
  [gstreamer, 'bin'], ';', ...
   systempath];
setenv('PATH', systempath);
end