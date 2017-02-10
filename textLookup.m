function [ txt, txtDims ] = textLookup(keyIdx, lookupTable, windowPtr)
% TEXTLOOKUP Given an index in `keyIdx`, returns the (presumed character array)
%   value corresponding to that index in `lookupTable` cell array. If provided
%   `windowPtr`, also returns the dimensions that the text would take up under
%   the current settings in that PTB window.

  txt = lookupTable{keyIdx};
  if exist('windowPtr', 'var')
    txtDims = getTextDims(windowPtr, txt);
  end
end
