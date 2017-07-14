# Defining payoffs in R&A tasks *(outdated)*

Default: dollar values

### Displaying values slightly differently

Use existing formatters, or write your own! See `lib/draw/helpers/dollarFormatter.m` and how the `RA` task uses it in `tasks/RA/RA_drawTask.m`.

### Using images as stakes

PsychToolBox doesn't load images directly. Instead, it makes something called a "texture" from the image you supply, and gives you its ID. This seems annoying, but it's a good design choice -- loading images is computationally expensive and this allows PTB to keep your script spry and its timing reliable.

So how do you make it work when you're defining your task stakes in `settings.game.levels.stakes`?

My current implementation is as follows.

1. In `.levels.stakes`, define your payoffs as integers (e.g. `[1, 4:5]`). Same goes for your reference.

2. In `.lookups.stakes.img`, list in a cell array the paths to the images you'd like to represent each payoff.

   Note 1: **The innermost field must always be named `.img`.** The function we'll introduce in the next step, `createTexturesFromConfig`, will only automatically load and convert to textures the filepaths that it finds in `.img` subfields of your configuration.

   Note 2: **The order in which you list the images matters!** First image in the list will correspond to the payoff of `1`. If you defined `.game.levels.stakes` as `[1: 4:5]`, your `.game.levels.reference` as `7`, and provided `{'img/2.jpg', 'img/5.jpg', 'img/9.jpg'}` in `.lookups.stakes.img`, this will result in your payoff `1` displaying `2.jpg` and it will leave the other payoffs unassociated with any image whatsoever.

   This is because in MATLAB, the invisible "index" of the array is `{1: 'img/2.jpg', 2: 'img/5.jpg', 3: 'img/8.jpg'}`. This is why, if you called `settings.lookups.stakes.img{3}`, you'd get `'img/9.jpg'` as a result.

3. The function that creates the association between your stakes, your images, and PsychToolBox textures is `createTexturesFromConfig`. You should call it before you run your first block, but after you open a PTB window with `Screen('OpenWindow')`, and save its output to `settings`, like so:

   ```matlab
   settings.textures = loadTexturesFromConfig(settings);
   ```

4. When you want to display the texture, you'll use the function `imgLookup` to get the texture from a payoff value, like so:

   ```matlab
   % Draw images
   [ texture1, textureDims1 ] = imgLookup(amtOrder(1), blockSettings.lookups.stakes.img, ...
     blockSettings.textures);
   [ texture2, textureDims2 ] = imgLookup(amtOrder(2), blockSettings.lookups.stakes.img, ...
     blockSettings.textures);

   Screen('DrawTexture', windowPtr, texture1, [], [xCoords(1) yCoords(1) xCoords(1) + textureDims1(1) yCoords(1) + textureDims1(2)]);
   Screen('DrawTexture', windowPtr, texture2, [], [xCoords(2) yCoords(2) xCoords(2) + textureDims2(1) yCoords(2) + textureDims2(2)]);
   ```

This code is lifted verbatim from `tasks/MDM/MDM_drawTask.m`. It's a little abstruse, but: `amtOrder(1)` and `amtOrder(2)` are the top and bottom payoff, respectively. You then supply both the payoff-to-image-path table and the path-to-textureId table that you created and saved earlier. Finally, you display it with coordinates you had computed earlier.

In general, you should look at the scripts that implement `MDM` (i.e. `MDM.m', 'MDM_config.m`, and everything in `tasks/MDM/*`) to understand how this works together.

### Text as values

This is similar as the case for images. Your `stakes` are indices for a lookup table that you'll place in `settings.lookups.(object).txt`. You'll then use `textLookup` in a similar fashion, with one difference: to obtain the text's dimensions, you'll need to supply the ID of the window that PsychToolBox opened to you. If you follow best practice (see e.g. `RA.m`), you'll find this ID in `settings.device.windowPtr`.

The same script I cited earlier, `tasks/MDM/MDM_drawTask.m`, retrieves the text that corresponds to a payoff value in the following way:

```matlab
% Draw text
[ txt1, txtDims1 ] = textLookup(amtOrder(1), blockSettings.lookups.stakes.txt, ...
  blockSettings.device.windowPtr);
[ txt2, txtDims2 ] = textLookup(amtOrder(2), blockSettings.lookups.stakes.txt, ...
  blockSettings.device.windowPtr);

DrawFormattedText(windowPtr, txt1, ...
  xCoords(1), yCoords(1), blockSettings.objects.lottery.stakes.fontColor);
DrawFormattedText(windowPtr, txt2, ...
  xCoords(2), yCoords(2), blockSettings.objects.lottery.stakes.fontColor);
```

Again, `amtOrder(1)` and `amtOrder(2)` are the top and bottom payoff. `blockSettings.lookups.stakes.txt` is the lookup table, and the window pointer is where we said it was. Finally, you display it with the PTB function for text display.

# Other properties of R&A lotteries

## Property definitions *(incomplete)*

- `color` should really be `winColor`; it defines the color that is associated with the winning payoff. It can range from one to the number of rows of `s.draw.lottery.box.probColors`, which is an n-by-3 matrix that has an RGB color in each row. 
  - By convention, the first color is the top of the lottery box in the second quarter is the bottom of the lottery box — there is no reversal.
  - Optionally, `s.draw.lottery.box.colorKey` is a cell array of translations, in which i-th element of the array is  a translation of the RGB on the i-th row of the matrix. The levels of the colors are not authoritative.
- `refSide`, or reference side, refers conventionally to the left or the top choice. 
  - Ideally, it ranges from 1 to n, where n is the number of keys in `s.device.choiceKeys`.