# Imperative Visualizer

## About

This project was made to bring movement to some album cover art I made for a release. Please consider having a listen [here](https://estlinmusic.com/imperative). Thank you :)

---

## The Visualizer

The visualizer was made using the open-source graphics library [Processing](https://processing.org/) which is very well documented and versatile. My program uses 2D rendering techniques and randomness combined with some external libraries to create a spherical visualizer with many moving parts.

[Youtube video with music](https://youtu.be/2v8b7Y9G5-A)

![GIF in case video doesn't work](https://media.giphy.com/media/StFujEqufPip1Fhqej/giphy.gif)

(The logo and writing are not part of the program.)

## Features and Configuration

The program includes two different modes: Real-time and export. In real time, the specified song will be visualized without exporting anything. It runs smoothly on my low-spec gaming machine and is fairly light-weight. Export mode will first create a text file with all audio information, reading it bit by bit to create a smooth animated video. This can't be done real time as audio and video will be out of sync due to minor lag. It is also useful for higher resolution renders as it captures the full size not just the screen size.

### Libraries

The Minim and VideoExport libraries need to be installed in order for the visualizer to work. You can do this in Processing by going to Sketch->Import Library->Add Library...

From there you can search for Minim and Video Export.

### Following are some parameters you can alter:

**canvasHeight & canvasWidth** - Change to anything you like. Square format recommended.

**audioFileName** - A file you have placed in the data folder. Please use name and extension.

**export** - Boolean deciding whether to use export mode (true), or real-time mode (false).

**generateAudioTxtFile** - If in export mode, this Boolean can be toggled to regenerate the txt file for making the visualization. Otherwise, if the file already exists, it won't recreate it. You can either toggle this option, or delete the .txt file containing the information in the data folder.

**fps** - Set the fps of real-time and export.

**smoothingFactor** - Smoothes the reaction to audio information. Too slow will causes unresponsiveness while too fast will make it very jittery.

## Notes

- The audio can be a bit out of sync when directly exporting, so I recommend using an editing software to sync them up accurately.
- You will also need to cut some of the beginning, as it will record the setting up process of the program.
- An example audio file from the EP has been included.
- Press "q" to quitthe program and process the export at any time. Will work better than exiting the program using ESC or the stop button.

## The License

I have chosen to release this under a GNU v3.0 license. Check out [this](https://choosealicense.com/licenses/gpl-3.0/) website for more information, or read the license included in this repository. Essentially, you can use it for any project personal or commercial as long as you disclose the source, and keep the same kind of license. I believe this overall creates a better, more supportive community.

## PS:

I know I'm not the best coder, but I hope you can do something with this. I'd love to see what you make with it, so feel free to contact me!