/*  TEAMSPACE
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  Init Functions (Superficially Isolated from Main.pde)
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

// Name of Team's keylog file located in "/data/logs/..."
//
String FILE_NAME = "14_50_33_log.csv";

// Tables Containing current simulation configuration and results
//
Table simConfig, simResultOverall, keyLog;

// Objects for Viewing and Saving Results
//
GamePlot result;

// Camera Object with built-in GUI for navigation and selection
//
Camera cam;
PVector B; // Bounding Box for 3D Environment
int MARGIN; // Pixel margin allowed around edge of screen

// Semi-transparent Toolbar for information and sliders
//
Toolbar bar_left, bar_right; 
int BAR_X, BAR_Y, BAR_W, BAR_H;
boolean showGUI;

// Processing Font Containers
PFont f12, f18, f24;

// Counter to track which phase of initialization
//
boolean initialized;
int initPhase = 0;
int phaseDelay = 0;
String status[] = {
  "Initializing Canvas ...",
  "Loading Data ...",
  "Initializing Toolbars and 3D Environment ...",
  "Ready to go!"
};
int NUM_PHASES = status.length;

void init() {
  
  initialized = false;
    
  if (initPhase == 0) {
    
    // Load default background image
    //
    loadingBG = loadImage("data/loadingScreen.jpg");
    
    // Set Fonts
    //
    f12 = createFont("Helvetica", 12);
    f18 = createFont("Helvetica", 18);
    f24 = createFont("Helvetica", 24);
    textFont(f12);
    
    // Create canvas for drawing everything to earth surface
    //
    B = new PVector(3000, 3000, 0);
    MARGIN = 25;
    
  } else if (initPhase == 1) {
    
    // Init Data
    // 
    initSimConfig();
    initSimResult();
    initKeyLog();
    
  } else if (initPhase == 2) {
    
    // Initialize GUI3D
    //
    showGUI = true;
    initToolbars();
    initCamera();
    
  } else if (initPhase == 3) {
    
    initialized = true;
  }
  
  loadingScreen(loadingBG, initPhase, NUM_PHASES, status[initPhase]);
  if (!initialized) initPhase++; 
  delay(phaseDelay);

}

void initCamera() {
  
  // Initialize 3D World Camera Defaults
  //
  cam = new Camera (B, MARGIN);
  cam.ZOOM_DEFAULT = 0.25;
  cam.ZOOM_POW     = 1.75;
  cam.ZOOM_MAX     = 0.10;
  cam.ZOOM_MIN     = 0.75;
  cam.ROTATION_DEFAULT = PI; // (0 - 2*PI)
  cam.init(); // Must End with init() if any BASIC variables within Camera() are changed from default
  
  // Add non-camera UI blockers and edit camera UI characteristics AFTER cam.init()
  //
  cam.vs.xpos = width - 3*MARGIN - bar_right.barW;
  cam.hs.enable = false; //disable rotation
  cam.vs.enable = false; //disable zoom
  cam.drag.addBlocker(MARGIN, MARGIN, BAR_W, BAR_H);
  cam.drag.addBlocker(width - MARGIN - bar_right.barW, MARGIN, BAR_W, BAR_H);
  
  // Turn cam off while still initializing
  //
  cam.off();
}

void initToolbars() {
  
  // Initialize Toolbar
  BAR_X = MARGIN;
  BAR_Y = MARGIN;
  BAR_W = 250;
  BAR_H = 800 - 2*MARGIN;
  
  // Left Toolbar
  bar_left = new Toolbar(BAR_X, BAR_Y, BAR_W, BAR_H, MARGIN);
  bar_left.title = "TeamSpace IO\n\n";
  bar_left.credit = "Press ' r ' to reset all inputs\n\n";
  bar_left.explanation = "Filename:\n/data/logs/" + FILE_NAME;
  bar_left.controlY = BAR_Y + bar_left.margin + 2*bar_left.CONTROL_H;
  
  // Right Toolbar
  bar_right = new Toolbar(width - (BAR_X + int(1.5*BAR_W)), BAR_Y, int(1.5*BAR_W), BAR_H, MARGIN);
  bar_right.title = "";
  bar_right.credit = "";
  bar_right.explanation = "";
  bar_right.controlY = BAR_Y + bar_left.margin + 2*bar_left.CONTROL_H;
  
  int num = result.name.size();
  println(num);
  for (int j=0; j<2; j++) {
    for (int i=0; i<num; i++) {
      String name = result.name.get(i); 
      if (name.length() > 18) 
        name = name.substring(0,18);
      bar_right.addRadio(name, 200, true,  '1', false);
    }
  }
  
  for (int i=num; i<2*num; i++) {
    bar_right.radios.get(i).xpos = bar_right.barX + bar_right.barW/2;
    bar_right.radios.get(i).ypos = bar_right.radios.get(i-num).ypos;
  }
  for (int i=0; i<2*num; i++) {
    bar_right.radios.get(i).xpos += 20;
    bar_right.radios.get(i).ypos -= (i%num)*10;
  }
}

void initSimConfig() {
  simConfig = loadTable("data/simulation/config/case_table4Workshop.csv", "header");
}

void initSimResult() {
  simResultOverall = loadTable("data/simulation/result/1_overall.csv");
  
  result = new GamePlot();
  for (int i=0; i<simResultOverall.getColumnCount(); i++) {
    String name = simResultOverall.getString(0, i);
    result.name.add(name);
  }
}

void initKeyLog() {
  keyLog = loadTable("data/logs/" + FILE_NAME, "header");
  int numKPI    = result.name.size();
  int numFields = keyLog.getColumnCount();
  int numLogs   = keyLog.getRowCount();
  Table overall;
  for (int i=0; i<numLogs; i++) {
    String action = keyLog.getString(i, "Action");
    if (action.equals("Simulate")) {
      overall = new Table();
      overall.addRow();
      for (int j=0; j<numKPI; j++) {
        overall.addColumn();
        float value = keyLog.getFloat(i, numFields - numKPI + j);
        overall.setFloat(0, j, value);
      }
      result.addResult(overall);
    }
  }
}
