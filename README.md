## MovieClipX
MovieClipX (mcx) is a very slick library based off the original MovieClip library for Corona SDK. It adds a few very awesome features including
* mcx objects. A MovieClip master object capable of housing multiple different MovieClip animations.
* Retina display support.
* Animation speed control.
* And more features coming soon.

__I'd recommend following the tutorial listed [here](http://igaret.com/tutorials/using-movieclipx-with-your-corona-sdk-projects/ "iGaret MovieClipX Tutorial") to learn the proper way to use MovieClipX.__

## Basic Usage Tutorial
1. Make sure your `config.lua` file has this tag in it:

`imageSuffix = { ["@2x"] = 2 }`


2. Make sure you have copies of all your images, one for the high resolution graphic for the retina screen and one halfsized for old devices. You must name the files like so: 
Retina graphic = filename@2x.png
Non-Retina = filename.png
> __note: they don't have to be .png files.__


3. Now you must create a new mcx object. To create a new object use `myMCXObject = mcx.new()`
 

4. Now to animate you'll have to add a new animation to the object using `myMCXObject:newAnim("animation_name", {frames}, width, height, speed)`
> __note: you must enter the width and height of the non-retina graphic. So if the retina graphic is 128x128 you'd enter 64 for the width and height.__

5. To play one of the animations in the mcx object, use `myMCXObject:play("animation_name")`

__Extra tip: to automatically scale down your graphics for older phones use my utility MultiRezer instead of doing your sprites one by one!__
MultiRezer download: http://project239.com/multirezer


## Functions
`mcx.new()`
> Creates a new mcx object

`myMCXObject:newAnim(newAnim("animation_name", {frames}, width, height, speed)`
> Creates a new animation in an mcx object

`myMCXObject:play("animation_name")`
> Plays an animation in an mcx object

`myMCXObject:pause()`
> Pauses the current animation in an mcx object

`myMCXObject:togglePause()`
> Toggles between the playing/paused states

`myMCXObject:stop()`
> Stops an animation in an mcx object

`myMCXObject:currentAnimation()`
> Returns the name of the current animation

`myMCXObject:isPaused()`
> Returns a boolean with the current paused state

## Credits
Garet McKinley (iGARET.com)

## Not satisfied?
If you've found a problem or want to make a suggestion please by all means, do so! I love to hear feedback! It's what makes it grow with features that people really need.

### Thanks for using the MovieClipX library!
