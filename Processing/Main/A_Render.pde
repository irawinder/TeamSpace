/*  TEAMSPACE
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  Render Functions (Superficially Isolated from Main.pde)
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

// Begin Drawing 2D Elements
//
void render2D() {
  
  hint(DISABLE_DEPTH_TEST);
  
  // Draw Margin ToolBar
  //
  bar_main.draw();
  bar_A.draw();
  bar_B.draw();
  
  // Right-hand Toolbar Titles
  //
  pushMatrix(); translate(bar_B.barX + bar_B.margin + bar_B.barW/3, bar_B.barY + bar_B.margin - 8);
  fill(255); textAlign(RIGHT, TOP);
  
    pushMatrix(); rotate(-PI/2);
    text("X-AXIS", 0, 0);
    popMatrix();
    
    pushMatrix(); translate( (bar_B.barW/3-bar_B.margin), 0); rotate(-PI/2);
    text("Y-AXIS", 0, 0);
    popMatrix();
  
  popMatrix();
  
  // Plot Walk Graphs
  //
  pushMatrix(); translate(bar_B.barX, BAR_Y + BAR_H + MARGIN);
  if (showTrade)     tradeSpace.drawPlot(   0, 0, BAR_W, height - 4*MARGIN - BAR_H, MIN_TIME, MAX_TIME);
  if (showTeams)     teamSpace.drawPlot(    0, 0, BAR_W, height - 4*MARGIN - BAR_H, minTime,  maxTime);
  popMatrix();
  
  // Plot Attention Graphs
  //
  pushMatrix(); translate(bar_A.sliders.get(0).xpos, BAR_Y + BAR_H + MARGIN);
  if (showAttention) {
    int time = int(bar_A.sliders.get(2).value);
    teamAttention.drawPlot(0, 0, bar_A.sliders.get(0).len, 125, minTime,  maxTime, time, showSimAct, showOtherAct);  
  }
  popMatrix();
  
  // Plot Change Graphs
  //
  pushMatrix(); translate(bar_A.sliders.get(0).xpos, BAR_Y + BAR_H + MARGIN + 125 + 2*MARGIN);
  if (showAttention) {
    int time = int(bar_A.sliders.get(2).value); 
    teamChange.drawPlot(0, 0, bar_A.sliders.get(0).len, height - 2*MARGIN - (BAR_Y + BAR_H + MARGIN + 125 + 2*MARGIN), minTime,  maxTime, time, showSimAct, showOtherAct);  
  }
  popMatrix();
}

PImage loadingBG;
void loadingScreen(PImage bg, int phase, int numPhases, String status) {

  // Place Loading Bar Background
  //
  image(bg, 0, 0, width, height);
  pushMatrix(); 
  translate(width/2, height/2);
  int BAR_WIDTH  = 400;
  int BAR_HEIGHT =  48;
  int BAR_BORDER =  10;

  // Draw Loading Bar Outline
  //
  noStroke(); 
  fill(255, 200);
  rect(-BAR_WIDTH/2, -BAR_HEIGHT/2, BAR_WIDTH, BAR_HEIGHT, BAR_HEIGHT/2);
  noStroke(); 
  fill(0, 200);
  rect(-BAR_WIDTH/2+BAR_BORDER, -BAR_HEIGHT/2+BAR_BORDER, BAR_WIDTH-2*BAR_BORDER, BAR_HEIGHT-2*BAR_BORDER, BAR_HEIGHT/2);

  // Draw Loading Bar Fill
  //
  float percent = float(phase+1)/numPhases;
  noStroke(); 
  fill(255, 150);
  rect(-BAR_WIDTH/2 + BAR_HEIGHT/4, -BAR_HEIGHT/4, percent*(BAR_WIDTH - BAR_HEIGHT/2), BAR_HEIGHT/2, BAR_HEIGHT/4);

  // Draw Loading Bar Text
  //
  textAlign(CENTER, CENTER); 
  fill(255);
  text(status, 0, 0);

  popMatrix();
}
