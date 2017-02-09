function [ txt, txtDims ] = textLookup(keyIdx, lookupTable, windowPtr)
  txt = lookupTable{keyIdx};
  if exist('windowPtr', 'var')
    txtDims = getTextDims(windowPtr, txt);
  end
end
