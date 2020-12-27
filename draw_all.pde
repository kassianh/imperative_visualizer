int sphereRadius;

float spherePrevX;
float spherePrevY;

int yOffset;

boolean initialStatic = true;
float[] extendingSphereLinesRadius;


// Draw static parts - prevents re-calculation - faster real time render
void drawStatic() {
  
  if (initialStatic) {
    extendingSphereLinesRadius = new float[241];
    
    for (int angle = 0; angle <= 240; angle += 4) {
      extendingSphereLinesRadius[angle] = map(random(1), 0, 1, sphereRadius, sphereRadius * 7);
    }
    
    initialStatic = false;
  }

  // More extending lines
  for (int angle = 0; angle <= 240; angle += 4) {
  
    float x = round(cos(radians(angle + 150)) * sphereRadius + center.x);
    float y = round(sin(radians(angle + 150)) * sphereRadius + groundLineY - yOffset);
    
    float xDestination = x;
    float yDestination = y;

    // Draw lines in small increments to make it easier to work with 
    for (int i = sphereRadius; i <= extendingSphereLinesRadius[angle]; i++) {
      float x2 = cos(radians(angle + 150)) * i + center.x;
      float y2 = sin(radians(angle + 150)) * i + groundLineY - yOffset;
      
      if (y2 <= getGroundY(x2)) { // Make sure it doesnt go into ground
        xDestination = x2;
        yDestination = y2;
      }
    }
    
    stroke(255);
    
    if (y <= getGroundY(x)) {
      line(x, y, xDestination, yDestination);
    }
  }
}


// Draws everything
void drawAll(float[] sum) {
  // Center sphere
  sphereRadius = 15 * round(unit);

  spherePrevX = 0;
  spherePrevY = 0;

  yOffset = round(sin(radians(150)) * sphereRadius);

  drawStatic();
  
  // Lines surrounding
  float x = 0;
  float y = 0;
  int surrCount = 1;
  
  boolean direction = false;
  
  while (x < width * 1.5 && x > 0 - width / 2) {

    float surroundingRadius;
    
    float surrRadMin = sphereRadius + sphereRadius * 1/2 * surrCount;
    float surrRadMax = surrRadMin + surrRadMin * 1/8;

    float surrYOffset;
    
    float addon = frameCount * 1.5;
    
    if (direction) {
      addon = addon * 1.5;
    }

    for (float angle = 0; angle <= 240; angle += 1.5) {
      
      surroundingRadius = map(sin(radians(angle * 7 + addon)), -1, 1, surrRadMin, surrRadMax); // Faster rotation through angles, radius oscillates
      
      surrYOffset = sin(radians(150)) * surroundingRadius;

      x = round(cos(radians(angle + 150)) * surroundingRadius + center.x);
      y = round(sin(radians(angle + 150)) * surroundingRadius + getGroundY(x) - surrYOffset);

      noStroke();
      fill(map(surroundingRadius, surrRadMin, surrRadMax, 100, 255));
      circle(x, y, 3 * unit / 10.24);
      noFill();
    }

    direction = !direction;
    
    surrCount += 1;
  }

  // Lines extending from sphere
  float extendingLinesMin = sphereRadius * 1.3;
  float extendingLinesMax = sphereRadius * 3.5; 
  
  float xDestination;
  float yDestination;
  
  for (int angle = 0; angle <= 240; angle++) {

    float extendingSphereLinesRadius = map(noise(angle * 0.3), 0, 1, extendingLinesMin, extendingLinesMax);
        
    // Radius are mapped differently for highs, mids, and lows - alter higher mapping number for different result (eg. 0.8 to 0.2 in the highs)
    if (sum[0] != 0) {
      if (angle >= 0 && angle <= 30) {
        extendingSphereLinesRadius = map(sum[240 - round(map((angle), 0, 30, 0, 80))], 0, 0.8, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 1.5); // Highs
      }
      
      else if (angle > 30 && angle <= 90) {
        extendingSphereLinesRadius = map(sum[160 - round(map((angle - 30), 0, 60, 0, 80))], 0, 3, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 1.5); // Mids
      }
      
      else if (angle > 90 && angle <= 120) {
        extendingSphereLinesRadius = map(sum[80 - round(map((angle - 90), 0, 30, 65, 80))], 0, 40, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 1.5); // Bass
      }
      
      else if (angle > 120 && angle <= 150) {
        extendingSphereLinesRadius = map(sum[0 + round(map((angle - 120), 0, 30, 0, 15))], 0, 40, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 1.5); // Bass
      }
      
      else if (angle > 150 && angle <= 210) {
        extendingSphereLinesRadius = map(sum[80 + round(map((angle - 150), 0, 60, 0, 80))], 0, 3, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 1.5); // Mids
      }
      
      else if (angle > 210) {
        extendingSphereLinesRadius = map(sum[160 + round(map((angle - 210), 0, 30, 0, 80))], 0, 0.8, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 1.5); // Highs
      }
    }
    
    x = round(cos(radians(angle + 150)) * sphereRadius + center.x);
    y = round(sin(radians(angle + 150)) * sphereRadius + groundLineY - yOffset);

    xDestination = x;
    yDestination = y;

    for (int i = sphereRadius; i <= extendingSphereLinesRadius; i++) {
      int x2 = round(cos(radians(angle + 150)) * i + center.x);
      int y2 = round(sin(radians(angle + 150)) * i + groundLineY - yOffset);
      
      if (y2 <= getGroundY(x2)) { // Make sure it doesnt go into ground
        xDestination = x2;
        yDestination = y2;
      }
    }
    
    stroke(map(extendingSphereLinesRadius, extendingLinesMin, extendingLinesMax, 200, 255));
    
    if (y <= getGroundY(x))  {
      line(x, y, xDestination, yDestination);
    }
  }

  // Ground line
  for (int groundX = 0; groundX <= width; groundX++) {

    float groundY = getGroundY(groundX);

    noStroke();
    fill(255);
    circle(groundX, groundY, 1.8 * unit / 10.24);
    noFill();
  }
}
