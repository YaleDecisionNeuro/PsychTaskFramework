function rect = xyAndDimsToRect(xy, dims)
  rect = [xy(1), xy(2), xy(1) + dims(1), xy(2) + dims(2)];
end
