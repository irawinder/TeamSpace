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
  cam.vs.xpos = width - 3*MARGIN - BAR_W;
  //cam.hs.enable = false; //disable rotation
  cam.drag.addBlocker(MARGIN, MARGIN, BAR_W, BAR_H);
  cam.drag.addBlocker(width - MARGIN - BAR_W, MARGIN, BAR_W, BAR_H);
  
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
  bar_left.title = "TeamSpace IO\n";
  bar_left.credit = "(Left-hand Toolbar)\n\n";
  bar_left.explanation = "";
  bar_left.controlY = BAR_Y + bar_left.margin + 2*bar_left.CONTROL_H;
  
  // Right Toolbar
  bar_right = new Toolbar(width - (BAR_X + BAR_W), BAR_Y, BAR_W, BAR_H, MARGIN);
  bar_right.title = "";
  bar_right.credit = "(Right-hand Toolbar)\n\n";
  bar_right.explanation = "GUI3D Framework for explorable 3D model parameterized with sliders, radio buttons, and 3D Cursor. ";
  bar_right.explanation += "\n\nPress ' r ' to reset all inputs\nPress ' p ' to print camera settings\nPress ' h ' to hide GUI";
  bar_right.controlY = BAR_Y + bar_left.margin + 6*bar_left.CONTROL_H;
}
