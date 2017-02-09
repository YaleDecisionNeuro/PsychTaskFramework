function [ textureId, imgDims ] = imgLookup(keyIdx, fnameLookupTbl, textureLookupTbl)
  % Assumes a `fnameLookupTbl` has a list of image filenames. If
  % `textureLookupTbl` is provided, it is assumed it was created by
  % `loadTexturesFromConfig` and is up-to-date. If not, a texture is made for
  % the image.
  img = fnameLookupTbl{keyIdx};

  if exist('textureLookupTbl', 'var') && isa(textureLookupTbl, 'containers.Map')
    % Re-use texture made by `loadTexturesFromConfig`
    try % FIXME: This is lazy. Check with strcmp(img, keys(textureLookupTbl))
      textureStruct = textureLookupTbl(img);
      textureId = textureStruct.textureId;
      imgDims = textureStruct.dims;
    catch
      error(['Texture lookup table did not contain %s. Check that you are' ...
        ' generating textures correctly.'], img);
    end
  else
    % Generate texture from scratch
    error(['Textures not provided in the correct format. Generate a ' ...
      'texture lookup table with extractImagesFromConfig.']);
  end
end
