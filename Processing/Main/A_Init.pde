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
int NUM_FIELDS = 7; // Overrides the number of fields to detect

// Tables Containing current simulation configuration and results
//
Table simConfig, simResultOverall, keyLog;

// Objects for Viewing and Saving Results
//
GamePlot teamSpace, tradeSpace;
AttentionPlot teamAttention;
boolean showTeams, showTrade;
int MIN_TIME, MAX_TIME, minTime, maxTime;

// Pixel margin allowed around edge of screen
//
int MARGIN; 

// Semi-transparent Toolbar for information and sliders
//
Toolbar bar_left, bar_right; 
int BAR_X, BAR_Y, BAR_W, BAR_H;

// Processing Font Containers
//
PFont f12, f18, f24;

// Counter to track which phase of initialization
//
boolean initialized;
boolean showLoad;
int initPhase = 0;
int phaseDelay = 0;
String status[] = {
  "Initializing Canvas ...",
  "Loading Data ...",
  "Initializing Toolbars and 3D Environment ...",
  "Ready to go!",
};
int NUM_PHASES = status.length;

void init() {
  
  initialized = false;
  
  if (showLoad) {
    
    loadingScreen(loadingBG, initPhase, NUM_PHASES, status[initPhase]);
    showLoad = false;
    
  } else {
    
    if (initPhase == 0) { showLoad = true;
    
      // Set Fonts
      //
      f12 = createFont("Helvetica", 12);
      f18 = createFont("Helvetica", 18);
      f24 = createFont("Helvetica", 24);
      textFont(f12);
      
      MARGIN = 25;
      
    } else if (initPhase == 1) { showLoad = true;
      
      // Init Data
      // 
      initSimConfig();
      initSimResult();
      initKeyLog();
      
    } else if (initPhase == 2) { showLoad = true;
      
      // Initialize GUI3D
      //
      initToolbars();
      
    } else if (initPhase == 3) { showLoad = true;
      
      initialized = true;
    }
    
    if (!initialized) initPhase++; 
    delay(phaseDelay);
    
  }
}

void initToolbars() {
  
  // Initialize Toolbar
  BAR_X = MARGIN;
  BAR_Y = MARGIN;
  BAR_W = 250;
  BAR_H = (800 - 3*MARGIN)/2;
  
  // Left Toolbar
  bar_left = new Toolbar(BAR_X, BAR_Y, int(1.5*BAR_W), BAR_H, MARGIN);
  bar_left.title = "TeamSpace IO\n\n";
  bar_left.credit = "Press ' r ' to reset all inputs\n\n";
  bar_left.explanation = "Filename:\n/data/logs/" + FILE_NAME;
  bar_left.controlY = BAR_Y + bar_left.margin + 4*bar_left.CONTROL_H;
  bar_left.addRadio("Simulated Trade Space", 200, true, '1', false);
  bar_left.addRadio("Team Space",            200, true, '1', false);
  bar_left.addSlider("MIN Time Threshold (sec)", "", minTime, maxTime, minTime, 1, 'q', 'w', false);
  bar_left.addSlider("MAX Time Threshold (sec)", "", minTime, maxTime, maxTime, 1, 'a', 's', false);
  bar_left.addSlider("Time (sec)", "", minTime, maxTime, minTime, 1, 'z', 'x', false);
  
  // Right Toolbar
  bar_right = new Toolbar(BAR_X, BAR_Y + BAR_H + MARGIN , int(1.5*BAR_W), BAR_H, MARGIN);
  bar_right.title = "";
  bar_right.credit = "";
  bar_right.explanation = "";
  bar_right.controlY = BAR_Y + BAR_H + MARGIN + bar_right.margin + 2*bar_right.CONTROL_H;
  
  int num = teamSpace.name.size();
  for (int j=0; j<2; j++) {
    for (int i=0; i<num; i++) {
      String name = teamSpace.name.get(i); 
      if (name.length() > 18) name = name.substring(0,18);
      bar_right.addRadio(name, 200, true,  '1', false);
    }
  }
  
  for (int i=num; i<2*num; i++) {
    bar_right.radios.get(i).xpos = bar_right.barX + bar_right.barW/2;
    bar_right.radios.get(i).ypos = bar_right.radios.get(i-num).ypos;
  }
  for (int i=0; i<2*num; i++) {
    //bar_right.radios.get(i).xpos += 20;
    bar_right.radios.get(i).ypos -= (i%num)*10;
  }
}

void initSimConfig() {
  simConfig = loadTable("data/simulation/config/case_table4Workshop.csv", "header");
}

void initSimResult() {
  
  showTrade = true;
  
  Table tradeSpaceCSV;
  String filename = "tradespace.csv";
  String filefolder = "simulation/result/";
  
  File file = new File(dataPath(filefolder + filename));
  
  if (!file.exists()) {
    
    tradeSpaceCSV = new Table();
    
    File folder = new File(dataPath(filefolder));
    String[] filenames = folder.list();
    
    println(filenames.length + " scenarios in simlated trade space");
    
    if (filenames.length > 0) {
      
      simResultOverall = loadTable("data/" + filefolder + filenames[0]);
      
      for (int i=0; i<NUM_FIELDS; i++) {
        String name = simResultOverall.getString(0, i);
        tradeSpaceCSV.addColumn(name);
      }
      
    }
    for (int i=0; i<filenames.length; i++) {
      
      simResultOverall = loadTable("data/" + filefolder + filenames[i], "header");
      
      TableRow r = tradeSpaceCSV.addRow();
      for (int j=0; j<NUM_FIELDS; j++) {
        r.setFloat(j, simResultOverall.getFloat(0, j));
      }
      
      println("Pre-Loading Scenario " + i + " of " + filenames.length);
      
    }
    
    saveTable(tradeSpaceCSV, "data/" + filefolder + filename);
  }
  
  tradeSpaceCSV = loadTable("data/" + filefolder + filename);
  tradeSpace = new GamePlot();
  tradeSpace.showPath = false;
  tradeSpace.col = 50;
  int numKPI = tradeSpaceCSV.getColumnCount();
  for (int i=0; i<numKPI; i++) {
    String name = tradeSpaceCSV.getString(0, i);
    tradeSpace.name.add(name);
  }
  tradeSpace.addResults(tradeSpaceCSV);
  
}

void initKeyLog() {
  
  showTeams = true;
  
  MIN_TIME = 0;
  MAX_TIME = 24*60*60;
  
  minTime = MAX_TIME;
  maxTime = MIN_TIME;
  
  teamSpace = new GamePlot();
  teamSpace.name = tradeSpace.name;
  teamSpace.col = #00FF00;
  
  teamAttention = new AttentionPlot();
  teamAttention.name.add("Fuel Efficiency");
  teamAttention.name.add("Cargo Moved");
  teamAttention.name.add("CO2 Emission");
  teamAttention.name.add("NOx Emission");
  teamAttention.name.add("SOx Emission");
  teamAttention.name.add("Waiting Time");
  teamAttention.name.add("Initial Cost");
  
  keyLog = loadTable("data/logs/" + FILE_NAME, "header");
  int numKPI    = teamSpace.name.size();
  int numFields = keyLog.getColumnCount();
  int numLogs   = keyLog.getRowCount();
  Table overall;
  String timeString;
  
  for (int i=0; i<numLogs; i++) {
    
    // Read Time Value (seconds)
    //
    timeString = keyLog.getString(i, 0);
    int seconds, minutes, hours, time;
    seconds = int(timeString.substring(6,8));
    minutes = int(timeString.substring(3,5));
    hours   = int(timeString.substring(0,2));
    time = seconds + minutes*60 + hours*60*60;
    
    // Update min/max time values
    //
    if (time < minTime) minTime = time;
    if (time > maxTime) maxTime = time;
    
    // Read KPI Values and Add them to gamePlot
    //
    String action = keyLog.getString(i, "Action");
    if (action.equals("Simulate")) {
      overall = new Table();
      overall.addRow();
      for (int j=0; j<numKPI; j++) {
        overall.addColumn();
        float value = keyLog.getFloat(i, numFields - numKPI + j);
        if (j == 1) value /= 0.000001; //  Unique to Maritime DSS Data from March 2018 Experiment
        overall.setFloat(0, j, value);
      }
      teamSpace.addResult(overall, time);
    }
    
    // Read Attention Values and Add them to AttentionPlot
    //
    String x_attention = keyLog.getString(i, "X_AXIS");
    String y_attention = keyLog.getString(i, "Y_AXIS");
    teamAttention.addResult(time, action, x_attention, y_attention);
    
  }
  
  teamSpace.minRange = tradeSpace.minRange;
  teamSpace.maxRange = tradeSpace.maxRange;
}
