function dims = centerRectDims(center, rectSize, pxOffCenter)
  dims = [center - rectSize/2, center + rectSize/2];
  if exist('pxOffCenter', 'var')
    dims = dims + [pxOffCenter, pxOffCenter];
  end
end
