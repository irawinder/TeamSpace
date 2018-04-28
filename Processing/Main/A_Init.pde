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

// Overrides the number of KPI fields to detect. 
// To fix this, make sure n_overall.csv files have no erroneous columns
//
int NUM_FIELDS = 7;

// Tables Containing current simulation configuration and results
//
Table simConfig, simResultOverall;
Table[] keyLog;
ArrayList<String> keyLogNames;
String[] logFile;
ArrayList<Integer> fileIndex;

// Objects for Viewing and Saving Results
//
GamePlot tradeSpace;
GamePlot[] teamSpace;
AttentionPlot[] teamAttention;
ChangePlot[] teamChange;
boolean showTeams, showTrade, showAttention, showSimAct, showRecAct, showFocus, showEntry;
boolean[] showTeam;
int MIN_TIME, MAX_TIME, minTime, maxTime;

// Pixel margin allowed around edge of screen
//
int MARGIN; 

// Semi-transparent Toolbar for information and sliders
//
Toolbar bar_main, bar_A, bar_B; 
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
      initKeyLogs();
      
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
  //
  BAR_X = MARGIN;
  BAR_Y = MARGIN;
  BAR_W = (width - 3*MARGIN)/2;
  BAR_H = max( 200, (height - BAR_W - 3*MARGIN)/2 );
  
  // Main Toolbar
  //
  bar_main = new Toolbar(BAR_X, BAR_Y, 1*BAR_W/3 - MARGIN/2 + 0, BAR_H, MARGIN);
  bar_main.title = "TeamSpace IO\n";
  bar_main.credit = "Press ' r ' to reset\n";
  bar_main.explanation = "";
  bar_main.controlY = BAR_Y + MARGIN + 2*bar_main.CONTROL_H;
  
  for (int i=0; i<teamSpace.length; i++) {
    String index = "" + (i+1);
    bar_main.addRadio("" + logFile[fileIndex.get(i)], 200, true, index.charAt(0), true);
    bar_main.radios.get(i).col = teamSpace[i].col;
  }
  
  // A Toolbar
  //
  bar_A = new Toolbar(BAR_X + bar_main.barW + MARGIN, BAR_Y, 2*BAR_W/3 - MARGIN/2 + 75, BAR_H, MARGIN);
  bar_A.title = "";
  bar_A.credit = "";
  bar_A.explanation = "";
  bar_A.controlY = BAR_Y + MARGIN + int(0.25*bar_A.CONTROL_H);
  bar_A.addSlider("Time - MIN Threshold (sec)", "", minTime, maxTime, minTime, 1, 'q', 'w', false);
  bar_A.addSlider("Time - MAX Threshold (sec)", "", minTime, maxTime, maxTime, 1, 'a', 's', false);
  bar_A.addSlider("Time (sec)", "", minTime, maxTime, minTime, 1, 'z', 'x', false);
  bar_A.addRadio("Team Attention", 200, true, '1', false);
  bar_A.addRadio("Action: 'Simulate'", 200, false, '1', false);
  bar_A.radios.get(1).col = #FFFF00;
  bar_A.addRadio("Action: 'Recall'", 200, false, '1', false);
  bar_A.radios.get(2).col = #00FF00;
  
  for (int i=1; i<=2; i++) {
    bar_A.radios.get(i).xpos += i*(bar_A.barW-2*MARGIN)/3;
    bar_A.radios.get(i).ypos = bar_A.radios.get(0).ypos;
  }
  
  // B Toolbar
  //
  bar_B = new Toolbar(BAR_X + BAR_W + MARGIN + 75, BAR_Y, BAR_W - 75, BAR_H, MARGIN);
  bar_B.title = "";
  bar_B.credit = "";
  bar_B.explanation = "";
  bar_B.controlY = BAR_Y + MARGIN + int(0.25*bar_B.CONTROL_H);
  
  bar_B.addRadio("Simulated Trade Space", 200, true,  '1', false);
  bar_B.addRadio("Team Space",            200, true,  '1', false);
  bar_B.addRadio("Log Entry",             200, false, '1', false);
  int beg = 3;
  
  int num = teamSpace[0].name.size();
  for (int j=0; j<2; j++) {
    for (int i=0; i<num; i++) {
      String name = teamSpace[0].name.get(i); 
      if (name.length() > 14) name = name.substring(0,14);
      bar_B.addRadio(name, 200, false,  '1', false);
    }
  }
  
  for (int i=num+beg; i<2*num+beg; i++) {
    bar_B.radios.get(i).xpos = bar_B.barX + bar_B.barW/3;
    bar_B.radios.get(i).ypos = bar_B.radios.get(i-num).ypos;
  }
  for (int i=0+beg; i<2*num+beg; i++) {
    bar_B.radios.get(i).xpos += 20  + bar_B.barW/3;
    bar_B.radios.get(i).ypos -= ((i-beg)%num)*10 + beg*bar_B.CONTROL_H;
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
  tradeSpace.allowSelect = false;
  tradeSpace.col = 50;
  int numKPI = tradeSpaceCSV.getColumnCount();
  for (int i=0; i<numKPI; i++) {
    String name = tradeSpaceCSV.getString(0, i);
    tradeSpace.name.add(name);
    tradeSpace.unit.add("");
  }
  tradeSpace.addResults(tradeSpaceCSV);
  
}

void initKeyLogs() {
  String filefolder = "logs/";
  File folder = new File(dataPath(filefolder));
  logFile = folder.list();
  fileIndex = new ArrayList<Integer>();
  for (int i=0; i<logFile.length; i++) {
    String f = logFile[i];
    String type = f.substring(f.length() - 4, f.length());
    if (type.equals(".csv")) fileIndex.add(i);
  }
  
  keyLog = new Table[fileIndex.size()];
  teamSpace = new GamePlot[fileIndex.size()];
  teamChange = new ChangePlot[fileIndex.size()];
  teamAttention = new AttentionPlot[fileIndex.size()];
  
  showTeams     = true;
  showAttention = true;
  showSimAct    = true;
  showRecAct  = true;
  showFocus     = true;
  showEntry     = false;
  
  showTeam = new boolean[fileIndex.size()];
  for (int i=0; i<showTeam.length; i++) showTeam[i] = true;
  
  MIN_TIME = 0;
  MAX_TIME = 24*60*60;
  
  minTime = MAX_TIME;
  maxTime = MIN_TIME;
  
  colorMode(HSB);
  for (int i=0; i<fileIndex.size(); i++) {
    int col = color(255*float(i)/fileIndex.size(), 255, 255);
    initKeyLog(i, fileIndex.get(i), col);
  }
  colorMode(RGB);
}

void initKeyLog(int logIndex, int fileIndex, int col) {
  
  GamePlot tS = new GamePlot();
  tS.name = tradeSpace.name;
  tS.unit = tradeSpace.unit;
  tS.col = col;
  //tS.highlight = true;
  
  AttentionPlot tA = new AttentionPlot();
  tA.name = tradeSpace.name;
  tA.col = col;
  
  // Name of Team's keylog file located in "/data/logs/..."
  //
  ChangePlot tC = new ChangePlot();
  keyLog[logIndex] = loadTable("data/logs/" + logFile[fileIndex]);
  int begin = 0;
  int end = keyLog[logIndex].getColumnCount()-1;
  keyLogNames = new ArrayList<String>();
  for (int i=0; i<keyLog[logIndex].getColumnCount(); i++) {
    String name = keyLog[logIndex].getString(0, i);
    keyLogNames.add(name);
    if (name.equals("Action") || name.equals("Screen Height")) begin = i+1;
    if (name.equals("X_AXIS")) end   = i-1;
  }
  for (int i=begin; i<=end; i++) {
    tC.name.add(keyLog[logIndex].getString(0, i));
  }
  tC.col = col;
  
  keyLog[logIndex] = loadTable("data/logs/" + logFile[fileIndex], "header");
  int numKPI    = tS.name.size();
  int numFields = keyLog[logIndex].getColumnCount();
  int numLogs   = keyLog[logIndex].getRowCount();
  Table overall;
  String[] timeString;
  boolean recalled = false;
  
  for (int i=0; i<numLogs; i++) {
    
    // Read Time Value (seconds)
    //
    timeString = split(keyLog[logIndex].getString(i, 0), ":");
    int seconds, minutes, hours, time;
    seconds = int(timeString[2]);
    minutes = int(timeString[1]);
    hours   = int(timeString[0]);
    time = seconds + minutes*60 + hours*60*60;
    
    // Update min/max time values
    //
    if (time < minTime) minTime = time;
    if (time > maxTime) maxTime = time;
    
    // Read KPI Values and Add them to gamePlot
    //
    String action = keyLog[logIndex].getString(i, "Action");
    if (recalled) {
      recalled = false;
    } else if (action.substring(0,3).equals("Sim")) {
      overall = new Table();
      overall.addRow();
      for (int j=0; j<numKPI; j++) {
        overall.addColumn();
        float value = keyLog[logIndex].getFloat(i, numFields - numKPI + j);
        if (j == 1 && logFile[fileIndex].substring(0,2).equals("E1")) value /= 0.000001; //  Unique to Maritime DSS Data from March 2018 Experiment #1
        overall.setFloat(0, j, value);
      }
      tS.addResult(overall, time);
    }
    
    // Doesn't log simulations immediatedly initiated from a Recall event
    //
    if (action.substring(0,3).equals("Rec")) recalled = true;
    
    // Read Attention Values and Add them to AttentionPlot
    //
    String x_attention = keyLog[logIndex].getString(i, "X_AXIS");
    String y_attention = keyLog[logIndex].getString(i, "Y_AXIS");
    tA.addResult(time, action, x_attention, y_attention);
    
    // Read Change Values and Add them to ChangePlot
    //
    ArrayList<String> before = new ArrayList<String>();
    ArrayList<String> after  = new ArrayList<String>();
    for (int j=begin; j<=end; j++) {
      if (i == 0) {
        before.add(keyLog[logIndex].getString(i, j));
      } else {
        before.add(keyLog[logIndex].getString(i-1, j));
      }
      after.add(keyLog[logIndex].getString(i, j));
    }
    tC.addResult(time, action, before, after);
    
  }
  
  tS.minRange = tradeSpace.minRange;
  tS.maxRange = tradeSpace.maxRange;
  
  teamSpace[logIndex]     = tS;
  teamAttention[logIndex] = tA;
  teamChange[logIndex]    = tC;
}
