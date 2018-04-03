/*  TEAMSPACE
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  Listen Functions (Superficially Isolated from Main.pde)
 *
 *  MIT LICENSE: Copyright 2018 Ira Winder
 *
 *               Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
 *               and associated documentation files (the "Software"), to deal in the Software without restriction, 
 *               including without limitation the rights to use, copy, modify, merge, publish, distribute, 
 *               sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
 *               furnished to do so, subject to the following conditions:
 *
 *               The above copyright notice and this permission notice shall be included in all copies or 
 *               substantial portions of the Software.
 *
 *               THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
 *               NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
 *               NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
 *               DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
 *               OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

// Function that update in-memory elements
//
void listen() {
  
  // Constrain Buttons to viable solutions
  //
  constrainButtons();
  
  int num = teamSpace.name.size();
  int beg = 0;
  for (int i=0; i<num; i++) {
    if (bar_right.radios.get(beg+i).value) {
      teamSpace.xIndex = i;
      tradeSpace.xIndex = i;
    }
    if (bar_right.radios.get(beg+i+num).value) {
      teamSpace.yIndex = i;
      tradeSpace.yIndex = i;
    }
  }
  
  showTrade = bar_left.radios.get(0).value;
  showTeams = bar_left.radios.get(1).value;
  
  minTime = int(bar_left.sliders.get(0).value);
  maxTime = int(bar_left.sliders.get(1).value);
  
}

void mousePressed() { if (initialized) {
  
  cam.pressed();
  bar_left.pressed();
  bar_right.pressed();
  
} }

void mouseClicked() { if (initialized) {
  
  
  
} }

void mouseReleased() { if (initialized) {
  
  bar_left.released();
  bar_right.released();
  cam.moved();
  
} }

void mouseMoved() { if (initialized) {
  
  cam.moved();
  
} }

void keyPressed() { if (initialized) {
    
  cam.moved();
  bar_left.pressed();
  bar_right.pressed();
  
  switch(key) {
    case 'f':
      cam.showFrameRate = !cam.showFrameRate;
      break;
    case 'c':
      cam.reset();
      break;
    case 'r':
      bar_left.restoreDefault();
      bar_right.restoreDefault();
      break;
    case 'h':
      showGUI = !showGUI;
      break;
    case 'p':
      println("cam.offset.x = " + cam.offset.x);
      println("cam.offset.x = " + cam.offset.x);
      println("cam.zoom = "     + cam.zoom);
      println("cam.rotation = " + cam.rotation);
      break;
  }
  
} }

void keyReleased() { if (initialized) {
    
    bar_left.released();
    bar_right.released();
  
} }

void constrainButtons() {
  
  // Results View: X-AXIS and Y-Axis - Set mutually exclusive radios to false
  //
  int num = teamSpace.name.size();
  int beg = 0;
  for (int i=0; i<num+1; i+=num) {
    for (int j=0; j<num; j++) {
      if(bar_right.radios.get(beg+i+j).hover() && bar_right.radios.get(beg+i+j).value) {
        for (int k=0; k<num; k++) bar_right.radios.get(beg+i+k).value = false;
        bar_right.radios.get(beg+i+j).value = true;
      }
    }
  }
  
  // Results View: X-AXIS and Y-Axis - Set redundant radios to false; 1 button is always true
  //
  for (int i=0; i<num+1; i+=num) {
    boolean found = false;
    for (int j=0; j<num; j++) {
      if(bar_right.radios.get(beg+i+j).value) {
        for (int k=0; k<num; k++) bar_right.radios.get(beg+i+k).value = false;
        bar_right.radios.get(beg+i+j).value = true;
        found = true;
      }
    }
    if (!found) bar_right.radios.get(beg+i).value = true;
  }
}
