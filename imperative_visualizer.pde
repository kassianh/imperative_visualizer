// Under GNU v3.0 License
// Made by Estlin (Kassian Houben) for his 5 track EP "Imperative"
// Find it on all major platforms

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import com.hamoid.*;

VideoExport videoExport;

// Configuration variables
// ------------------------
int canvasWidth = 1080;
int canvasHeight = 1080;

String audioFileName = "kingfisher.mp3"; // Audio file in data folder

boolean export = false; // Either export or real time
boolean generateAudioTxtFile = false; // Will auto generate if export is true and no audio txt file exists

float fps = 30;
float smoothingFactor = 0.25; // FFT audio analysis smoothing factor
// ------------------------

// Global variables

// Export variables
String SEP = "|";
float frameDuration = 1 / fps;
BufferedReader audioReader;
String[] fftFile;
String songName;

// Real time variables
AudioPlayer track;
FFT fft;
Minim minim;  

// General
int bands = 256; // must be multiple of two
float[] spectrum = new float[bands];
float[] sum = new float[bands];


// Graphics
float unit;
int groundLineY;
PVector center;


// Processing 3.0 function for setting size() with variables
void settings() {
  size(canvasWidth, canvasHeight);
  smooth(8);
}


void setup() {
  hint(ENABLE_STROKE_PURE);
  
  if (!export) {
    frameRate(fps);
  }
  
  if (export) {
    // Produce the video as fast as possible
    frameRate(1000);
  }

  // Graphics related variable setting
  unit = height / 100; // Everything else can be based around unit to make it change depending on size 
  strokeWeight(unit / 10.24);
  groundLineY = height * 3/4;
  center = new PVector(width / 2, height * 3/4);
  
  // Set up .mp4 export
  if (export) {
    File tempFile = new File(dataPath(audioFileName + ".txt"));
  
    // Make sure txt file exists
    if (!tempFile.exists() || generateAudioTxtFile) {
      if(!audioToTextFile(audioFileName)) {
        exit();
      }
    }
    
    // Now open the text file we just created for reading
    audioReader = createReader(audioFileName + ".txt");

    // Set up the video exporting
    videoExport = new VideoExport(this);
    videoExport.setFrameRate(fps);
    
    try {
      videoExport.setAudioFileName(audioFileName);
    }
    catch (Exception e){
      println("Could not set video export audio file");
    }
    videoExport.startMovie();
    
  }
  else { // Real time
    minim = new Minim(this);
    track = minim.loadFile(audioFileName, 2048);
    
    track.loop();
    
    fft = new FFT( track.bufferSize(), track.sampleRate() );
    
    fft.linAverages(bands);
    
    // track.cue(60000); // Cue in miliseconds
  }
}


void draw() {

  // If exporting to mp4
  if (export) {
    String line;
    try {
      line = audioReader.readLine(); // Reads txt file line by line
    }
    catch (IOException e) {
      e.printStackTrace();
      line = null;
    }
    if (line == null) {
      // Done reading the file.
      // Close the video file.
      
      if (export) {
        videoExport.endMovie();
      }
      
      exit();
    } else {
      if (export) { // remove first frame from visualizer
        if (frameCount == 1) {
          return;
        }
      }
      
      String[] p = split(line, SEP);
  
      float soundTime = float(p[0]);
      
      //println("Current export time: " + videoExport.getCurrentTime());
      //println("Sound time: " + soundTime);

      while (videoExport.getCurrentTime() < soundTime + frameDuration * 10) {  // frameDuration * delay -- need to experiment
        spectrum = new float[bands];
        
        // Iterate over all our data points (different
        for (int i=1; i<p.length; i += 2) { // Iterate through pairs of L/R
          spectrum[((i + 1) / 2) - 1] = (float(p[i]) + float(p[i + 1])) / 2; // Average of left right and add to spectrum
          
          // Smooth the FFT spectrum data by smoothing factor
          sum[((i + 1) / 2) - 1] += (abs(spectrum[((i + 1) / 2) - 1]) - sum[((i + 1) / 2) - 1]) * smoothingFactor;
        }
        
        // Reset canvas
        fill(0);
        noStroke();
        rect(0, 0, width, height);
        noFill();
        
        drawAll(sum);
      
        if (export) {
          videoExport.saveFrame();
        }
      }
    }
  }
  else { // Real time
    fft.forward( track.mix );
    
    spectrum = new float[bands];
    
    for(int i = 0; i < fft.avgSize(); i++)
    {
      spectrum[i] = fft.getAvg(i) / 2 + fft.getAvg(i) / 2; // Average of left right and add to spectrum
          
      // Smooth the FFT spectrum data by smoothing factor
      sum[i] += (abs(spectrum[i]) - sum[i]) * smoothingFactor;
    }
    
    // Reset canvas
    fill(0);
    noStroke();
    rect(0, 0, width, height);
    noFill();
    
    drawAll(sum);
  }
}


// Get the Y position at position X of ground sine wave
float getGroundY(float groundX) {

  float angle = 1.1 * groundX / unit * 10.24;

  float groundY = sin(radians(angle + frameCount * 2)) * unit * 1.25 + groundLineY - unit * 1.25;

  return groundY;
}


// Does circle contain point
boolean circleContains(PVector position, PVector center, float radius) {
  // If distance between center and point is less than radius, then circle contains
  if (dist(position.x, position.y, center.x, center.y) < radius) {
    return true;
  }
  return false;
}


// Minim based audio FFT to data text file conversion.
boolean audioToTextFile(String fileName) {
  PrintWriter output;

  Minim minim = new Minim(this);
  output = createWriter(dataPath(fileName + ".txt"));
  
  AudioSample track;

  try {
    track = minim.loadSample(fileName, 2048);
  }
  
  catch (Exception e) {
    println("Error: " + e);
    println("Could not get audio file titled: " + fileName);
    return false;
  }

  int fftSize = 1024;
  float sampleRate = track.sampleRate();

  float[] fftSamplesL = new float[fftSize];
  float[] fftSamplesR = new float[fftSize];

  float[] samplesL = track.getChannel(AudioSample.LEFT);
  float[] samplesR = track.getChannel(AudioSample.RIGHT);  

  FFT fftL = new FFT(fftSize, sampleRate);
  FFT fftR = new FFT(fftSize, sampleRate);

  //fftL.logAverages(86, 1);
  //fftR.logAverages(86, 1);
  
  fftL.linAverages(bands);
  fftR.linAverages(bands);
  

  int totalChunks = (samplesL.length / fftSize) + 1;
  int fftSlices = fftL.avgSize();

  for (int ci = 0; ci < totalChunks; ++ci) {
    int chunkStartIndex = ci * fftSize;   
    int chunkSize = min( samplesL.length - chunkStartIndex, fftSize );

    System.arraycopy( samplesL, chunkStartIndex, fftSamplesL, 0, chunkSize);      
    System.arraycopy( samplesR, chunkStartIndex, fftSamplesR, 0, chunkSize);      
    if ( chunkSize < fftSize ) {
      java.util.Arrays.fill( fftSamplesL, chunkSize, fftSamplesL.length - 1, 0.0 );
      java.util.Arrays.fill( fftSamplesR, chunkSize, fftSamplesR.length - 1, 0.0 );
    }

    fftL.forward( fftSamplesL );
    fftR.forward( fftSamplesL );

    // The format of the saved txt file.
    // The file contains many rows. Each row looks like this:
    // T|L|R|L|R|L|R|... etc
    // where T is the time in seconds
    // Then we alternate left and right channel FFT values
    // The first L and R values in each row are low frequencies (bass)
    // and they go towards high frequency as we advance towards
    // the end of the line.
    StringBuilder msg = new StringBuilder(nf(chunkStartIndex/sampleRate, 0, 3).replace(',', '.'));
    for (int i=0; i<fftSlices; ++i) {
      msg.append(SEP + nf(fftL.getAvg(i), 0, 4).replace(',', '.'));
      msg.append(SEP + nf(fftR.getAvg(i), 0, 4).replace(',', '.'));
    }
    output.println(msg.toString());
  }
  track.close();
  output.flush();
  output.close();
  println("Sound analysis done");
  
  return true;
}


void keyPressed() {
  if (key == 'q') {
    if (export) {
      videoExport.endMovie();
    }
    
    exit();
  }
}
