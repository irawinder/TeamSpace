class GamePlot {
  ArrayList<Ilities> game;
  ArrayList<String> name, unit;
  ArrayList<Float> minRange, maxRange;
  int xIndex, yIndex;
  int nearest, nearestThreshold;
  int selected;
  int col;

  boolean showPath;
  boolean showAxes;
  boolean highlight;
  boolean allowSelect;
  
  float zoom;
  float offset_x, offset_y, origin_x, origin_y;
  
  boolean isDragged;
  int x_init, y_init;
  
  PGraphics interior;
  
  GamePlot() {
    game = new ArrayList<Ilities>();
    name = new ArrayList<String>();
    unit = new ArrayList<String>();
    minRange = new ArrayList<Float>();
    maxRange = new ArrayList<Float>();
    xIndex  = 0;
    yIndex  = 0;
    nearest = 0;
    selected = 0;
    nearestThreshold = 10;
    showPath = true;
    showAxes = true;
    highlight = false;
    allowSelect = true;
    col = 255;
    
    zoom = 0.0;
    offset_x = 0;
    offset_y = 0;
    origin_x = 0;
    origin_y = 0;
    
    interior = createGraphics(10, 10);
  }
  
  void click() {
    isDragged = true;
    x_init = mouseX;
    y_init = mouseY;
  }
  
  void release() {
    isDragged = false;
    origin_x = offset_x;
    origin_y = offset_y;
    if (nearest >=0) selected = nearest;
  }
  
  void next() {
    selected++;
    if (selected >= game.size()) selected = 0;
  }
  
  void last() {
    selected--;
    if (selected <= -1) selected = game.size()-1;
  }
  
  void reset() {
    zoom = 0;
    offset_x = 0;
    offset_y = 0;
    origin_x = 0;
    origin_y = 0;
    selected = 0;
    nearest = -1;
  }
  
  void addResult(Table result, int timeStamp) {
    Ilities i = new Ilities(result, timeStamp);
    game.add(i);
    updateRange();
    selected = game.size()-1;
  }

  void addResults(Table results) {
    for (int i=1; i<results.getRowCount(); i++) {
      Ilities ilit = new Ilities();
      ArrayList<Float> val = new ArrayList<Float>();
      for (int j=0; j<results.getColumnCount(); j++) {
        val.add(results.getFloat(i, j));
      }
      ilit.value = val;
      game.add(ilit);
    }
    updateRange();
    selected = game.size()-1;
  }

  void update(int x, int y, int w, int h) {
    
    // Update offsets
    //
    if (isDragged && x_init > x && x_init < x+w && y_init > y && y_init < y+h) {
      offset_x = origin_x + float(x_init - mouseX)/w;
      offset_y = origin_y + float(mouseY - y_init)/h;
    }
  }

  void drawPlot(int x, int y, int w, int h, int minTime, int maxTime) {
    
    zoom = min(0.45, zoom);
    
    float min_x = minRange.get(xIndex);
    float min_y = minRange.get(yIndex);
    float max_x = maxRange.get(xIndex);
    float max_y = maxRange.get(yIndex);
    float range_x = max_x - min_x;
    float range_y = max_y - min_y;
    min_y += + zoom*range_y + offset_y*range_y;
    max_y += - zoom*range_y + offset_y*range_y;
    min_x += + zoom*range_x + offset_x*range_x;
    max_x += - zoom*range_x + offset_x*range_x;
    
    int MARGIN = 20;
    interior = createGraphics(w-MARGIN, h);
    pushMatrix(); translate(x+MARGIN, y);
    
    if (showAxes) {
      stroke(255); strokeWeight(1); noFill();
      rect(0, 0, w-MARGIN, h);
      fill(255);
  
      // Draw Y Axis Lable
      //
      String nY = name.get(yIndex) + " " + unit.get(yIndex); 
      //if (nY.length() > 18) nY = nY.substring(0, 18);
      pushMatrix(); translate(0, h/2); rotate(-PI/2);
      textAlign(CENTER, BOTTOM); 
      text(nY, 0, -3);
      popMatrix();
  
      if (game.size() > 0) {
  
        // Draw Y Axis Min Range
        //
        nY = trimValue("" + min_y, 2); 
        pushMatrix(); translate(0, h); rotate(-PI/2);
        textAlign(LEFT, BOTTOM); 
        text(nY, 0, -3);
        popMatrix();
  
        // Draw Y Axis Max Range
        //
        nY = trimValue("" + max_y, 2); 
        pushMatrix(); translate(0, 0); rotate(-PI/2);
        textAlign(RIGHT, BOTTOM); 
        text(nY, 0, -3);
        popMatrix();
      }
  
      // Draw X Axis Lable
      //
      String nX = name.get(xIndex) + " " + unit.get(xIndex); 
      //if (nX.length() > 18) nX = nX.substring(0, 18);
      pushMatrix(); translate(w/2-MARGIN/2, h+3);
      textAlign(CENTER, TOP); 
      text(nX, 0, 0);
      popMatrix();
  
      if (game.size() > 0) {
  
        // Draw X Axis Min Range
        //
        nX = trimValue("" + min_x, 2); 
        pushMatrix(); translate(0, h+3);
        textAlign(LEFT, TOP); 
        text(nX, 0, 0);
        popMatrix();
  
        // Draw X Axis Max Range
        //
        nX = trimValue("" + max_x, 2); 
        pushMatrix(); translate(w-MARGIN, h+3);
        textAlign(RIGHT, TOP); 
        text(nX, 0, 0);
        popMatrix();
      }
    }
    
    // Derive Nearest Architecture / Game State
    //
    nearest = -1;
    if (allowSelect) {
      float minDist = Float.POSITIVE_INFINITY;
      for (int i=0; i<game.size(); i++) {
        float val_x = game.get(i).value.get(xIndex);
        float val_y = game.get(i).value.get(yIndex);
        float x_plot = map(val_x, min_x, max_x, 0, w-MARGIN);
        float y_plot = map(val_y, min_y, max_y, 0, h);
        
        // Update Nearest Game State Index
        //
        float dist = sqrt( sq(mouseX - x - MARGIN - x_plot) + sq(mouseY - y - h + y_plot) );
        if (dist < nearestThreshold && dist < minDist) {
          minDist = dist;
          nearest = i;
        }
      }
    }
  
    // Plot links
    //
    float alpha, alphaScale;
    if (showPath) {
      interior.beginDraw();
      interior.clear();
      Ilities last = new Ilities();
      for (int i=0; i<game.size(); i++) {
        float val_x = game.get(i).value.get(xIndex);
        float val_y = game.get(i).value.get(yIndex);
        float x_plot = map(val_x, min_x, max_x, 0, w-MARGIN);
        float y_plot = map(val_y, min_y, max_y, 0, h);
        
        alpha = 150;
        alphaScale = 1.0;
        if (!inBounds(i, minTime, maxTime)) alphaScale = 0.0;
        
        if (i >= 1) {
          val_x = last.value.get(xIndex);
          val_y = last.value.get(yIndex);
          float x_plot_last = map(val_x, min_x, max_x, 0, w-MARGIN);
          float y_plot_last = map(val_y, min_y, max_y, 0, h);
          //if ( (x_plot > 0 && x_plot < w-MARGIN && y_plot > 0 && y_plot < h) || 
          //     (x_plot_last > 0 && x_plot_last < w-MARGIN && y_plot_last > 0 && y_plot_last < h) ) {
            interior.stroke(col, alphaScale*alpha); interior.strokeWeight(3); 
            interior.line(x_plot_last, h - y_plot_last, x_plot, h - y_plot);
          //}
        }
        last = game.get(i);
      }
      image(interior, 0, 0, w-MARGIN, h);
    }
    
    // Plot Points
    //
    float diameter = 8;
    for (int i=0; i<game.size(); i++) {
      float val_x = game.get(i).value.get(xIndex);
      float val_y = game.get(i).value.get(yIndex);
      float x_plot = map(val_x, min_x, max_x, 0, w-MARGIN);
      float y_plot = map(val_y, min_y, max_y, 0, h);
      
      alphaScale = 1.0;
      if (!inBounds(i, minTime, maxTime)) alphaScale = 0.0;
      
      if (x_plot > 0 && x_plot < w-MARGIN && y_plot > 0 && y_plot < h) {
        
        noStroke(); fill(col, alphaScale*255);
        if (highlight) {
          stroke(#FFFF00, alphaScale*255); 
          strokeWeight(1); 
        }
        if (i != selected) ellipse(x_plot, h - y_plot, diameter, diameter);
        
      }
    }
    
    hint(ENABLE_DEPTH_TEST); hint(DISABLE_DEPTH_TEST);
    
    //// Draw point Labels
    ////
    //for (int i=0; i<game.size(); i++) {
    //  if (showPath) {
    //    float val_x = game.get(i).value.get(xIndex);
    //    float val_y = game.get(i).value.get(yIndex);
    //    float x_plot = map(val_x, min_x, max_x, 0, w-MARGIN);
    //    float y_plot = map(val_y, min_y, max_y, 0, h);
    //    if (x_plot > 0 && x_plot < w-MARGIN && y_plot > 0 && y_plot < h) {
    //      alphaScale = 1.0;
    //      if (!inBounds(i, minTime, maxTime)) alphaScale = 0.1;
    //      fill(255, alphaScale*255); stroke(255, alphaScale*255); 
    //      if (i == selected) fill(#DB8F00);
    //      text(i+1, x_plot + 12, h - y_plot - 12);
    //    }
    //  }
    //}
    
    // Draw Nearest Point Marker
    //
    if (nearest >=0 && nearest != selected && game.size() > 0) {
      
      float val_x = game.get(nearest).value.get(xIndex);
      float val_y = game.get(nearest).value.get(yIndex);
      float x_plot = map(val_x, min_x, max_x, 0, w-MARGIN);
      float y_plot = map(val_y, min_y, max_y, 0, h);
      if (x_plot > 0 && x_plot < w-MARGIN && y_plot > 0 && y_plot < h) {
        strokeWeight(2); stroke(#DB8F00); noFill();
        ellipse(x_plot, h - y_plot, diameter+4, diameter+4);
        fill(#FFAA00); noStroke();
        textAlign(LEFT, BOTTOM);
      }
      for (int i=0; i<3; i++) text((nearest+1), x_plot + 8, h - y_plot - 8);
    }
    
    // Draw Selected Point Marker
    //
    if (selected >=0 && game.size() > 0 && allowSelect) {
      float val_x = game.get(selected).value.get(xIndex);
      float val_y = game.get(selected).value.get(yIndex);
      float x_plot = map(val_x, min_x, max_x, 0, w-MARGIN);
      float y_plot = map(val_y, min_y, max_y, 0, h);
      if (x_plot > 0 && x_plot < w-MARGIN && y_plot > 0 && y_plot < h) {
        fill(col); noStroke();
        ellipse(x_plot, h - y_plot, diameter+10, diameter+10);
        textAlign(CENTER, CENTER); fill(255);
        for (int i=0; i<3; i++) text(selected+1, x_plot, h - y_plot - 1);
      }
      
      String values = "";
      values += name.get(xIndex) + ": " + trimValue("" + val_x, 2) + " " + unit.get(xIndex);
      values += "\n";
      values += name.get(yIndex) + ": " + trimValue("" + val_y, 2) + " " + unit.get(yIndex);
      textAlign(LEFT, BOTTOM); fill(#FFAA00);
      text(values, 8, h - 8);
    }
    
    popMatrix();
  }
  
  boolean inBounds(int index, int minTime, int maxTime) {
    Ilities i = game.get(index);
    if (i.timeStamp >= minTime && i.timeStamp <= maxTime) {
      return true;
    } else {
      return false;
    }
  }

  void updateRange() {
    minRange.clear();
    maxRange.clear();
    if (game.size() == 0) {
      for (int i=0; i<name.size(); i++) {
        minRange.add(-1000.0);
        maxRange.add(+1000.0);
      }
    } else if (game.size() == 1) {
      for (int i=0; i<name.size(); i++) {
        Ilities r = game.get(0);
        if (r.value.get(i) == 0) {
          minRange.add(r.value.get(i) - 1.0);
          maxRange.add(r.value.get(i) + 1.0);
        } else {
          minRange.add(r.value.get(i) - 0.25*r.value.get(i));
          maxRange.add(r.value.get(i) + 0.25*r.value.get(i));
        }
      }
    } else {
      for (int i=0; i<name.size(); i++) {
        float min = Float.POSITIVE_INFINITY;
        float max = Float.NEGATIVE_INFINITY;
        for (Ilities r : game) {
          if (min > r.value.get(i)) min = r.value.get(i);
          if (max < r.value.get(i)) max = r.value.get(i);
        }
        if (min != max) {
          minRange.add(min - 0.25*(max-min));
          maxRange.add(max + 0.25*(max-min));
        } else {
          if (min == 0) {
            minRange.add(-1.0);
            maxRange.add(+1.0);
          } else {
            minRange.add(min - 0.25*min);
            maxRange.add(max + 0.25*max);
          }
        }
      }
    }
  }
}

class Ilities {
  ArrayList<Float> value;
  int timeStamp;

  Ilities() {
    timeStamp = 0;
    value = new ArrayList<Float>();
  }

  Ilities(Table result, int timeStamp) {
    this.timeStamp = timeStamp;
    value = new ArrayList<Float>();
    for (int i=0; i<result.getColumnCount(); i++) {
      float scaler = 1.0;
      value.add(scaler*result.getFloat (0, i));
    }
  }
}

// Truncates the decimals off of a very large or small float
//
String trimValue(String val, int figures) {
  String trimmed = "";
  int counter = 0;
  boolean decimal = false;
  for (int i=0; i<val.length(); i++) {
    String letter = val.substring(i, i+1);
    if (letter.equals(".")) decimal = true;
    if (letter.equals("E")) decimal = false;
    if (counter <= figures || !decimal) trimmed += letter;
    if (decimal) counter ++;
  }
  
  return trimmed;
}

class FingerPlot {
  ArrayList<String> name;
  
  ArrayList<ArrayList<Boolean>> finger;
  ArrayList<Integer> timeStamp;
  ArrayList<String> action;
  
  boolean showAxes;
  boolean instantaneous;
  int col;
  
  FingerPlot() {
    
    name      = new ArrayList<String>();
    
    action    = new ArrayList<String>();
    timeStamp = new ArrayList<Integer>();
    finger    = new ArrayList<ArrayList<Boolean>>();
    
    showAxes = true;
    instantaneous = false;
    col = 255;
  }
  
  FingerPlot(ArrayList<String> name) {
    super();
    this.name = name;
  }
  
  void addMatch(int t, String a, String x, String y) {
    ArrayList<Boolean> b = new ArrayList<Boolean>();
    for (String n: name) {
      if ( n.equals(x) || n.equals(y) ) {
        b.add(true);
      } else {
        b.add(false);
      }
    }
    finger.add(b);
    timeStamp.add(t);
    action.add(a);
  }
  
  void addChange(int t, String a, ArrayList<String> before, ArrayList<String> after) {
    ArrayList<Boolean> b = new ArrayList<Boolean>();
    boolean changed = false;
    
    for (int i=0; i<before.size(); i++) {
      
      if ( finger.size() < 2 ) {
        b.add(false);
      } else {
        
        switch(i) {
          case 0:
            changed = false;
            break;
          case 4:
            changed = false;
            break;
          case 7:
            changed = false;
            break;
          case 10:
            changed = false;
            break;
          case 13:
            changed = false;
            break;
          case 16:
            changed = false;
            break;
          case 19:
            changed = false;
            break;
        }
        
        if(!before.get(i).equals(after.get(i))) changed = true;
        
        switch(i) {
          case 3:
            b.add(changed);
            break;
          case 6:
            b.add(changed);
            break;
          case 9:
            b.add(changed);
            break;
          case 12:
            b.add(changed);
            break;
          case 15:
            b.add(changed);
            break;
          case 18:
            b.add(changed);
            break;
          case 21:
            b.add(changed);
            break;
        }
      }
    }
    finger.add(b);
    timeStamp.add(t);
    action.add(a);
  }
  
  void drawPlot(int x, int y, int w, int h, int minTime, int maxTime, int time, boolean showSimAct, boolean showRecAct, boolean showFocus, int rank, int tot_rank) {
    
    // Ranks are used to stagger bars when multiple items share a field
    
    // Vertical spacing between elements
    //
    int spacer = h/name.size();
    
    pushMatrix(); translate(x, y);
    
    //// Draw Graph Grid
    ////
    //noFill(); stroke(25); strokeWeight(1);
    //for (int i=0; i<name.size(); i++) {
    //  int y_pos = spacer/2 + i*spacer;
    //  line(0, y_pos, w, y_pos); 
    //}
    
    //// Show Mouse click and release actions
    ////
    //strokeWeight(1);
    //for (int i=0; i<action.size(); i++) {
    //  String a             = action.get(i);
    //  int t                = timeStamp.get(i);
    //  if (t >= minTime && t <= maxTime) {
    //    int x_i = int( w * float(t - minTime) / (maxTime - minTime) );
    //    fill(50);
    //    if (!a.equals("Simulate") && showOtherAct) {
    //      stroke(50, 150);
    //      line(x_i, 0, x_i, h);
    //    } 
    //  }
    //}
    
    // Show Mouse Simulate actions
    //
    strokeWeight(1); textAlign(CENTER, BOTTOM); 
    int simCounter = 0;
    boolean recalled = false;
    for (int i=0; i<action.size(); i++) {
      String a             = action.get(i);
      int t                = timeStamp.get(i);
      int x_i = int( w * float(t - minTime) / (maxTime - minTime) );
      fill(50);
      if (recalled) {
        recalled = false;
      } else if (a.substring(0,3).equals("Sim") && showSimAct) {
        simCounter++;
        if (t >= minTime && t <= maxTime) {
          stroke(#FFFF00, 150);
          line(x_i, 0, x_i, h);
          fill(255); text(simCounter, x_i, - 4);
        }
      } else if (a.substring(0,3).equals("Rec") && showRecAct) {
        simCounter++;
        if (t >= minTime && t <= maxTime) {
          stroke(#00FF00, 150);
          line(x_i, 0, x_i, h);
          fill(255); text(simCounter, x_i, - 4);
        }
      }
      
      // Doesn't log simulations immediatedly initiated from a Recall event
      //
      if (a.substring(0,3).equals("Rec")) recalled = true;
      
      if (a.equals("Start") && showSimAct) {
        if (t >= minTime && t <= maxTime) {
          stroke(#FF0000, 150); strokeWeight(2);
          line(x_i, 0, x_i, h);
          strokeWeight(1);
        }
      }
    }
    
    // Plot Attention Data
    //
    if (showFocus) {
      if (instantaneous) {
        
        // Show Instantaneous "Blips"
        //
        int weight = int( h/10/tot_rank );
        hint(ENABLE_DEPTH_TEST); hint(DISABLE_DEPTH_TEST);
        fill(col); noStroke();
        for (int i=0; i<action.size(); i++) {
          int t_i              = timeStamp.get(i);
          ArrayList<Boolean> b = finger.get(i);  
          if (t_i >= minTime && t_i <= maxTime) {
            int x_i = int( w * float(t_i - minTime) / (maxTime - minTime) );
            for (int j=0; j<b.size(); j++) {
              boolean changed = b.get(j);
              //int vert = spacer/2 + j*spacer - 1 * tot_rank / 2 + 2 * rank;
              //int vert = spacer/2 + j*spacer;
              int vert = spacer/2 + j*spacer - h/10/2 + rank*weight;
              if (changed) rect(x_i, vert, weight, weight);
            }
          }
        }
        
      } else {
        
        // Connect Gaps Between True/False States
        //
        int weight = int( h/10/tot_rank );
        hint(ENABLE_DEPTH_TEST); hint(DISABLE_DEPTH_TEST);
        strokeWeight(weight); stroke(col); noFill();
        for (int i=1; i<action.size(); i++) {
          String a             = action.get(i);
          int t_i              = timeStamp.get(i-1);
          int t_f              = timeStamp.get(i);
          ArrayList<Boolean> b = finger.get(i);  
          
          if ( (t_i >= minTime && t_i <= maxTime) || (t_f >= minTime && t_f <= maxTime) ) {
            
            int x_i = 0;
            if (t_i >= minTime) x_i = int( w * float(t_i - minTime) / (maxTime - minTime) );
            
            int x_f = w;
            if (t_f <= maxTime) x_f = int( w * float(t_f - minTime) / (maxTime - minTime) );
            
            for (int j=0; j<b.size(); j++) {
              boolean viewing = b.get(j);
              int vert = spacer/2 + j*spacer - h/10/2 + rank*weight;
              if (viewing) line(x_i, vert, x_f, vert);
            }
          }
        }
        
      }
    }
      
    // Show Primary Time Notch
    //
    int x_t = int( w * float(time - minTime) / (maxTime - minTime) );
    stroke(255); strokeWeight(2);
    line(x_t, -10, x_t, 0);
    line(x_t, h, x_t, h + 4);
    stroke(255); strokeWeight(1);
    line(x_t, 0, x_t, h);
    int hour     = time/(60*60);
    int minute   = (time - hour*60*60)/60;
    int second = (time - hour*60*60 - minute*60);
    fill(255); textAlign(CENTER, TOP);
    text(hour + ":" + minute + ":" + second, x_t, h + 8);
    
    // Show min/max time notches
    //
    stroke(255); strokeWeight(1);
    x_t = int( w * float(minTime - minTime) / (maxTime - minTime) );
    line(x_t, -5, x_t, h + 5);
    x_t = int( w * float(maxTime - minTime) / (maxTime - minTime) );
    line(x_t, -5, x_t, h + 5);
    
    if (showAxes) {
      
      // Draw Border
      //
      stroke(255); strokeWeight(1); noFill();
      rect(0, 0, w, h);
      fill(255);
      
      // Draw Y Axis Lables
      //
      textAlign(RIGHT, CENTER);
      for (int i=0; i<name.size(); i++) {
        String n = name.get(i);
        text(n, - 8, spacer/2 + i*spacer);
      }
    }
    
    popMatrix();
    
  }
}
