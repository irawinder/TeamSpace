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
  
  for (int k=0; k<teamSpace.length; k++) {
    
    // Constrain Buttons to viable solutions
    //
    constrainButtons(k);
  
    int num = teamSpace[k].name.size();
    int beg = 3;
    for (int i=0; i<num; i++) {
      if (bar_B.radios.get(beg+i).value) {
        teamSpace[k].xIndex = i;
        tradeSpace.xIndex = i;
      }
      if (bar_B.radios.get(beg+i+num).value) {
        teamSpace[k].yIndex = i;
        tradeSpace.yIndex = i;
      }
    }
  }
  
  showTrade    = bar_B.radios.get(0).value;
  showTeams    = bar_B.radios.get(1).value;
  showEntry    = bar_B.radios.get(2).value;
  showFocus    = bar_A.radios.get(0).value;
  showSimAct   = bar_A.radios.get(1).value;
  showOtherAct = bar_A.radios.get(2).value;
  
  minTime = int(bar_A.sliders.get(0).value);
  maxTime = int(bar_A.sliders.get(1).value);
  
  bar_A.sliders.get(2).valMin = minTime;
  bar_A.sliders.get(2).valMax = maxTime;
  
  ControlSlider sm = bar_A.sliders.get(0);
  ControlSlider lg = bar_A.sliders.get(1);
  if (sm.value >= lg.value && sm.isDragged) lg.value = sm.value;
  if (lg.value <= sm.value && lg.isDragged) sm.value = lg.value;
  
  for (int i=0; i<showTeam.length; i++) if (i<bar_main.radios.size()) showTeam[i] = bar_main.radios.get(i).value;
  
}

void mousePressed() { if (initialized) { 
  loop();
  
  bar_main.pressed();
  bar_A.pressed();
  bar_B.pressed();
  
  tradeSpace.click();
  for (int i=0; i<teamSpace.length; i++) teamSpace[i].click();
  
} }

void mouseClicked() { if (initialized) { 
  loop();
  
  
} }

void mouseReleased() { if (initialized) { 
  loop();
  
  bar_main.released();
  bar_A.released();
  bar_B.released();
  
  tradeSpace.release();
  for (int i=0; i<teamSpace.length; i++) teamSpace[i].release();
  
} }

void mouseMoved() { if (initialized) { 
  loop();
  
} }

void mouseDragged() { if (initialized) { 
  loop();
  
} }

void keyPressed() { if (initialized) { 
  loop();
    
  bar_main.pressed();
  bar_A.pressed();
  bar_B.pressed();
  
  switch(key) {
    case 'r':
      bar_main.restoreDefault();
      bar_A.restoreDefault();
      bar_B.restoreDefault();
      tradeSpace.reset();
      for (int i=0; i<teamSpace.length; i++) teamSpace[i].reset();
      break;
    case '+':
      tradeSpace.zoom += 0.05;
      for (int i=0; i<teamSpace.length; i++) teamSpace[i].zoom += 0.05;
      break;
    case '-':
      tradeSpace.zoom -= 0.05;
      for (int i=0; i<teamSpace.length; i++) teamSpace[i].zoom -= 0.05;
      break;
  }
  
  if (key == CODED) {
    if (keyCode == UP) {
      
    } else if (keyCode == DOWN) {
      
    } else if (keyCode == LEFT) {
      bar_A.sliders.get(0).value -= 60;
      bar_A.sliders.get(1).value -= 60;
      bar_A.sliders.get(2).value -= 60;
    } else if (keyCode == RIGHT) {
      bar_A.sliders.get(0).value += 60;
      bar_A.sliders.get(1).value += 60;
      bar_A.sliders.get(2).value += 60;
    } 
  }
  
} }

void keyReleased() { if (initialized) { 
  //loop();
    
  bar_main.released();
  bar_A.released();
  bar_B.released();

} }

void constrainButtons(int teamIndex) {
  
  // Results View: X-AXIS and Y-Axis - Set mutually exclusive radios to false
  //
  int num = teamSpace[teamIndex].name.size();
  int beg = 3;
  for (int i=0; i<num+1; i+=num) {
    for (int j=0; j<num; j++) {
      if(bar_B.radios.get(beg+i+j).hover() && bar_B.radios.get(beg+i+j).value) {
        for (int k=0; k<num; k++) bar_B.radios.get(beg+i+k).value = false;
        bar_B.radios.get(beg+i+j).value = true;
      }
    }
  }
  
  // Results View: X-AXIS and Y-Axis - Set redundant radios to false; 1 button is always true
  //
  for (int i=0; i<num+1; i+=num) {
    boolean found = false;
    for (int j=0; j<num; j++) {
      if(bar_B.radios.get(beg+i+j).value) {
        for (int k=0; k<num; k++) bar_B.radios.get(beg+i+k).value = false;
        bar_B.radios.get(beg+i+j).value = true;
        found = true;
      }
    }
    if (!found) bar_B.radios.get(beg+i+i/num).value = true;
  }
}
