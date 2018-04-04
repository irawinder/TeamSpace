class GamePlot {
  ArrayList<Ilities> game;
  ArrayList<String> name;
  ArrayList<Float> minRange, maxRange;
  int xIndex, yIndex;
  int col;

  boolean showPath;
  boolean showAxes;

  GamePlot() {
    game = new ArrayList<Ilities>();
    name = new ArrayList<String>();
    minRange = new ArrayList<Float>();
    maxRange = new ArrayList<Float>();
    xIndex = 0;
    yIndex = 0;
    showPath = true;
    showAxes = true;
    col = 255;
  }

  void addResult(Table result, int timeStamp) {
    Ilities i = new Ilities(result, timeStamp);
    game.add(i);
    updateRange();
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
  }

  void drawPlot(int x, int y, int w, int h, int minTime, int maxTime) {
    
    int MARGIN = 20;
    pushMatrix(); translate(x+MARGIN, y);
    
    if (showAxes) {
      stroke(255); strokeWeight(1); noFill();
      rect(0, 0, w-MARGIN, h);
      fill(255);
  
      // Draw Y Axis Lable
      //
      String nY = name.get(yIndex); 
      if (nY.length() > 18) nY = nY.substring(0, 18);
      pushMatrix(); 
      translate(0, h/2); 
      rotate(-PI/2);
      textAlign(CENTER, BOTTOM); 
      text(nY, 0, -3);
      popMatrix();
  
      if (game.size() > 0) {
  
        // Draw Y Axis Min Range
        //
        nY = "" + minRange.get(yIndex); 
        pushMatrix(); 
        translate(0, h); 
        rotate(-PI/2);
        textAlign(LEFT, BOTTOM); 
        text(nY, 0, -3);
        popMatrix();
  
        // Draw Y Axis Max Range
        //
        nY = "" + maxRange.get(yIndex); 
        pushMatrix(); 
        translate(0, 0); 
        rotate(-PI/2);
        textAlign(RIGHT, BOTTOM); 
        text(nY, 0, -3);
        popMatrix();
      }
  
      // Draw X Axis Lable
      //
      String nX = name.get(xIndex); 
      if (nX.length() > 18) nX = nX.substring(0, 18);
      pushMatrix(); 
      translate(w/2+MARGIN/2, h+3);
      textAlign(CENTER, TOP); 
      text(nX, 0, 0);
      popMatrix();
  
      if (game.size() > 0) {
  
        // Draw X Axis Min Range
        //
        nX = "" + minRange.get(xIndex); 
        pushMatrix(); 
        translate(0, h+3);
        textAlign(LEFT, TOP); 
        text(nX, 0, 0);
        popMatrix();
  
        // Draw X Axis Max Range
        //
        nX = "" + maxRange.get(xIndex);
        pushMatrix(); 
        translate(w-MARGIN, h+3);
        textAlign(RIGHT, TOP); 
        text(nX, 0, 0);
        popMatrix();
      }
    }
    
    // Plot points
    //
    Ilities last = new Ilities();
    for (int i=0; i<game.size(); i++) {
      if (inBounds(i, minTime, maxTime)) {
        
        float alpha;
        if (showPath) {
          //alpha = 255.0*float(i+1)/game.size();
          alpha = 100;
        } else {
          alpha = 255;
        }
        float x_plot = map(game.get(i).value.get(xIndex), minRange.get(xIndex), maxRange.get(xIndex), 0, w);
        float y_plot = map(game.get(i).value.get(yIndex), minRange.get(yIndex), maxRange.get(yIndex), 0, h);
        float diameter = 10;
        noStroke(); 
        if (i == game.size()-1 && showPath) {
          diameter *= 2;
          stroke(255);
        }
        fill(col, 255); ellipse(x_plot, h - y_plot, diameter, diameter);
  
        if (i >= 1 && showPath) {
          float x_plot_last = map(last.value.get(xIndex), minRange.get(xIndex), maxRange.get(xIndex), 0, w);
          float y_plot_last = map(last.value.get(yIndex), minRange.get(yIndex), maxRange.get(yIndex), 0, h);
          stroke(col, alpha); strokeWeight(3); 
          line(x_plot_last, h - y_plot_last, x_plot, h - y_plot);
        }
        
      }

      last = game.get(i);
    }
    
    // Draw point Labels
    //
    hint(ENABLE_DEPTH_TEST); hint(DISABLE_DEPTH_TEST);
    for (int i=0; i<game.size(); i++) {
      if (inBounds(i, minTime, maxTime)) {
        float x_plot = map(game.get(i).value.get(xIndex), minRange.get(xIndex), maxRange.get(xIndex), 0, w);
        float y_plot = map(game.get(i).value.get(yIndex), minRange.get(yIndex), maxRange.get(yIndex), 0, h);
        if (showPath) {
          fill(255); stroke(255); text(i+1, x_plot + 16, h - y_plot - 16);
        }
      }
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
        minRange.add(r.value.get(i) - 1000.0);
        maxRange.add(r.value.get(i) + 1000.0);
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
          minRange.add(min - 0.2*(max-min));
          maxRange.add(max + 0.2*(max-min));
        } else {
          minRange.add(min - 1000.0);
          maxRange.add(max + 1000.0);
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

class AttentionPlot {
  
  ArrayList<String> name;
  
  ArrayList<ArrayList<Boolean>> attention;
  ArrayList<Integer> timeStamp;
  ArrayList<String> action;
  
  boolean showAxes;
  
  AttentionPlot() {
    
    name      = new ArrayList<String>();
    
    action    = new ArrayList<String>();
    timeStamp = new ArrayList<Integer>();
    attention = new ArrayList<ArrayList<Boolean>>();
    
    showAxes = true;
  }
  
  AttentionPlot(ArrayList<String> name) {
    super();
    this.name = name;
  }
  
  void addResult(int t, String a, String x, String y) {
    ArrayList<Boolean> b = new ArrayList<Boolean>();
    for (String n: name) {
      if ( n.equals(x) || n.equals(y) ) {
        b.add(true);
      } else {
        b.add(false);
      }
    }
    attention.add(b);
    timeStamp.add(t);
    action.add(a);
  }
  
  void drawPlot(int x, int y, int w, int h, int minTime, int maxTime, int time, boolean showSimAct, boolean showOtherAct) {
    
    // Vertical spacing between elements
    //
    int spacer = h/name.size();
    
    pushMatrix(); translate(x, y);
    
        // Show Mouse click and release actions
        //
        strokeWeight(1);
        for (int i=0; i<action.size(); i++) {
          String a             = action.get(i);
          int t                = timeStamp.get(i);
          if (t >= minTime && t <= maxTime) {
            int x_i = int( w * float(t - minTime) / (maxTime - minTime) );
            fill(50);
            if (!a.equals("Simulate") && showOtherAct) {
              stroke(50, 150);
              line(x_i, 0, x_i, h);
            } 
          }
        }
        
        // Show Mouse Simulate actions
        //
        strokeWeight(1);
        for (int i=0; i<action.size(); i++) {
          String a             = action.get(i);
          int t                = timeStamp.get(i);
          if (t >= minTime && t <= maxTime) {
            int x_i = int( w * float(t - minTime) / (maxTime - minTime) );
            fill(50);
            if (a.equals("Simulate") && showSimAct) {
              stroke(#FFFF00, 150);
              line(x_i, 0, x_i, h);
            } 
          }
        }
        
        // Plot Attention
        //
        strokeWeight(10); stroke(#FF00FF); noFill();
        for (int i=1; i<action.size(); i++) {
          String a             = action.get(i);
          int t_i              = timeStamp.get(i-1);
          int t_f              = timeStamp.get(i);
          ArrayList<Boolean> b = attention.get(i);  
          
          if (t_i >= minTime && t_f <= maxTime) {
            
            int x_i = int( w * float(t_i - minTime) / (maxTime - minTime) );
            int x_f = int( w * float(t_f - minTime) / (maxTime - minTime) );
            
            for (int j=0; j<b.size(); j++) {
              boolean viewing = b.get(j);
              if (viewing) line(x_i, spacer/2 + j*spacer, x_f, spacer/2 + j*spacer);
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
