//// Icon Variables
PImage img;
BufferedReader reader;
String name;
ArrayList<Icon> TotalIcons = new ArrayList<Icon>();
ArrayList<Page> AllPages = new ArrayList<Page>();

//// Screen Info
int cols = 8;
int rows = 8;
int screenWidth = 1200;
int screenHeight = 800;

int gridsize = 8;
int pageIconsNum = 64;
int iconNum = 1025;
int setSizes[] = {256, 512, 768, 1024};


//// Target Icon Info
Icon targetIcon;
String targetName = "";
float targetX;
float targetY;
float targetIndex;
boolean[] previousTargetIndexs = new boolean[iconNum];


//// Page Info
int currentPage = 0;
int totalPages; 
int pageSizes[] = {1, 2, 4, 8, 16};
int delaySizes[] = {50, 300, 500, 4000, 6000};


//// key info
boolean rightPressed = false;
boolean leftPressed = false;
int delayTime = 500; 
int lastPageTime = 0;


//// End Screen Info
int elapsedTime = 0;
int numErrors = 0;
int numPageChanges = 0;


//// Experiment Phase Info
enum ExperimentPhase {
  INSTRUCTIONS,
  BEFORE_CONDITION,
  BEFORE_TRIAL,
  TRIAL,
  FINISHED
}
ExperimentPhase phase = ExperimentPhase.INSTRUCTIONS;

int trialStartTime = 0;
ArrayList<Condition> Conditions = new ArrayList<Condition>();
int trialCounter = 0;
int conditionCounter = 0;
Condition currentCondition;


Table baseRecords;




class Icon {
  PImage pokemon;
  String name;
  float x, y;
  float w, h;
  
  Icon(PImage pokemon, String name, float x, float y) {
    this.pokemon = pokemon;
    this.name = name;
    this.x = x;
    this.y = y;
  }

  boolean isHovering() {
    return mouseX >= x && mouseX <= x + w &&
           mouseY >= y && mouseY <= y + h;
  }

  void display () {
    image(pokemon, x, y, w, h);

  }
}

class Page {
  Icon[] icons;
  int pageID;
  
  Page(Icon[] icons, int pageID) {
    this.icons = icons;
    this.pageID = pageID;
  }
  
  void displayPage() {
    // Logic to display icons for the current page
    for (int i = 0; i < icons.length; i++) {
      if (icons[i] != null) { 
        icons[i].display();
      }
    }
  }
}


class Condition {
  String conditionName;
  int numIcons;
  int gridsize;
  int numTrials;
  int navDelay;

  Condition(String conditionName, int numIcons, int gridsize, int numTrials, int navDelay) {
    this.conditionName = conditionName;
    this.numIcons = numIcons;
    this.gridsize = gridsize;
    this.numTrials = numTrials;
    this.navDelay = navDelay;
  }
}


void createPages() {
      float cellW = (screenWidth - 400) / (float)currentCondition.gridsize; 
      float cellH = screenHeight / (float)currentCondition.gridsize;

      float maxCellW = (screenWidth - 400) / 4.0;
      float maxCellH = screenHeight / 4.0;
      float maxSize = min(maxCellW, maxCellH) * 0.8;
      float baseIconSize = min(cellW, cellH) * 0.8;
      float iconSize = min(baseIconSize, maxSize);

      totalPages = ceil((float)currentCondition.numIcons / (currentCondition.gridsize * currentCondition.gridsize));
      pageIconsNum = currentCondition.gridsize * currentCondition.gridsize;

      previousTargetIndexs = new boolean[currentCondition.numIcons];
      targetIndex = random(currentCondition.numIcons);
      previousTargetIndexs[(int)targetIndex] = true;

      Icon newTargetIcon = TotalIcons.get((int)targetIndex);

      targetIcon = new Icon(newTargetIcon.pokemon, newTargetIcon.name, 0, 0);
      targetIcon.x = screenWidth - 300;;
      targetIcon.y = screenHeight / 2 - targetIcon.pokemon.height / 2;
      targetIcon.w = 150; 
      targetIcon.h = 150;
      targetName = targetIcon.name;
      println("New Target Icon: " + targetName);
      
      for (int i = 0; i < totalPages; i++) {
          Page newPage = new Page(new Icon[pageIconsNum], i);
          for (int j = 0; j < pageIconsNum; j++) {
            int index = i * pageIconsNum + j;
            if (index < TotalIcons.size()) {
              Icon icon = TotalIcons.get(index);

              int col = j % currentCondition.gridsize;
              int row = j / currentCondition.gridsize;
              float x = (col * cellW) + (cellW - iconSize) / 2;
              float y = (row * cellH) + (cellH - iconSize) / 2;
              icon.x = x;
              icon.y = y;
              icon.w = iconSize; 
              icon.h = iconSize;
              newPage.icons[j] = icon;
            }
          }
          AllPages.add(newPage);
      }
}



void settings() {
  size(screenWidth, screenHeight);
}

void setup() {
  for (int setSize : setSizes) {
    for (int i = 0; i < pageSizes.length; i++) {
      int pageSize = pageSizes[i];
      int delaySize = delaySizes[i];
      String condName = "Size_" + setSize + "_page_" + pageSize + "_delay_" + delaySize;
      Conditions.add(new Condition(condName, setSize, pageSize, 4, delaySize));
    }
  }

  baseRecords = new Table();
  baseRecords.addColumn("Condition");
  baseRecords.addColumn("SetSize");
  baseRecords.addColumn("PageSize");
  baseRecords.addColumn("NavDelay");
  baseRecords.addColumn("Trial Number");
  baseRecords.addColumn("Time");
  baseRecords.addColumn("Errors");

  reader = createReader("filenames.txt"); 
  

  for (int i = 0; i < iconNum; i++) {
    try {
    name = reader.readLine();
    } catch (IOException e) {
      e.printStackTrace();
      name = null;
    }
    if (name == null) {
      // Stop reading because of an error or file is empty
      break;
    }else {

      PImage tempImg = loadImage("icons/" + name);
      TotalIcons.add(new Icon(tempImg, name, 0, 0)); // give temporary position for now
    }
  }



  java.util.Collections.shuffle(TotalIcons);

  

  println("Total icons loaded: " + TotalIcons.size());
  println("Total pages created: " + AllPages.size());
}

void draw() {
  background(255);

  switch (phase) {
    case INSTRUCTIONS:

      fill(0);
      textSize(24);
      textAlign(CENTER, CENTER);
      text("INSTRUCTIONS\n\nUse the LEFT and RIGHT arrow keys to navigate through pages of icons.\n\nClick on the target icon displayed on the right side of the screen as quickly and accurately as possible.\n\nClick anywhere to begin.", screenWidth / 2, screenHeight / 2);

      return;
    case BEFORE_CONDITION:
      fill(0);
      textSize(24);
      textAlign(CENTER, CENTER);
      text("Condition: " + currentCondition.conditionName, screenWidth / 2, screenHeight / 2);
      break;
    case BEFORE_TRIAL:
      text("Trial " + (trialCounter + 1) + " of " + currentCondition.numTrials, screenWidth / 2, screenHeight / 2 - 40);
      text("Find the target icon: " + targetName, screenWidth / 2, screenHeight / 2);
      break;
    case TRIAL:
      int currentTime = millis();
      
      if (rightPressed && currentPage < totalPages - 1) {
          if (currentTime - lastPageTime > delayTime) { 
            currentPage++;
            lastPageTime = currentTime;
            numPageChanges++;
          }
      } 
      
      if (leftPressed && currentPage > 0) {
          if (currentTime - lastPageTime > delayTime) {
            currentPage--;
            lastPageTime = currentTime;
            numPageChanges++;
          }
        }
      

      AllPages.get(currentPage).displayPage();

      targetIcon.display();

      fill(0);
      text("Page: " + (currentPage + 1) + " / " + totalPages, 50, height - 50);
      
      break;
    case FINISHED:
      // End Screen
      background(200);
      text("COMPLETED", screenWidth / 2, screenHeight / 2);
      break;
  }


}

void keyReleased() {
  if (keyCode == RIGHT) {
    rightPressed = false;
  } else if (keyCode == LEFT) {
    leftPressed = false;
  }
}

void keyPressed() {
  if (phase == ExperimentPhase.INSTRUCTIONS && (key == 'e' || key == 'E')) {
     println("Exploration Mode Activated (Not yet implemented)");
     // You will implement the exploration logic here later
  }

  if (keyCode == RIGHT) {
    if (!rightPressed) { 
      if (currentPage < totalPages - 1) {
        currentPage++;
        numPageChanges++;
        lastPageTime = millis(); 
      }
      rightPressed = true;
    }
  } else if (keyCode == LEFT) {
    if (!leftPressed) { 
      if (currentPage > 0) {
        currentPage--;
        numPageChanges++;
        lastPageTime = millis(); 
      }
      leftPressed = true;
    }
  }
}



void mousePressed() {
  switch (phase) {
    case INSTRUCTIONS:
      currentCondition = Conditions.get(conditionCounter);
      // float iconW = (screenWidth - 400) / currentCondition.gridsize; 
      // float iconH = screenHeight / currentCondition.gridsize;
      float cellW = (screenWidth - 400) / (float)currentCondition.gridsize; 
      float cellH = screenHeight / (float)currentCondition.gridsize;
      float maxCellW = (screenWidth - 400) / 4.0;
      float maxCellH = screenHeight / 4.0;
      float maxSize = min(maxCellW, maxCellH) * 0.8;
      float baseIconSize = min(cellW, cellH) * 0.8;
      float iconSize = min(baseIconSize, maxSize);

      totalPages = ceil((float)currentCondition.numIcons / (currentCondition.gridsize * currentCondition.gridsize));
      pageIconsNum = currentCondition.gridsize * currentCondition.gridsize;

      targetIndex = random(currentCondition.numIcons);

      Icon newTargetIcon = TotalIcons.get((int)targetIndex);

      targetIcon = new Icon(newTargetIcon.pokemon, newTargetIcon.name, 0, 0);
      targetIcon.x = screenWidth - 300;;
      targetIcon.y = screenHeight / 2 - targetIcon.pokemon.height / 2;
      targetIcon.w = 150; 
      targetIcon.h = 150;
      targetName = targetIcon.name;
      println("New Target Icon: " + targetName);
      
      for (int i = 0; i < totalPages; i++) {
          Page newPage = new Page(new Icon[pageIconsNum], i);
          for (int j = 0; j < pageIconsNum; j++) {
            int index = i * pageIconsNum + j;
            if (index < TotalIcons.size()) {
              Icon icon = TotalIcons.get(index);
              int col = j % currentCondition.gridsize;
              int row = j / currentCondition.gridsize;
              float x = (col * cellW) + (cellW - iconSize) / 2;
              float y = (row * cellH) + (cellH - iconSize) / 2;
              icon.x = x;
              icon.y = y;
              icon.w = iconSize; 
              icon.h = iconSize;
              newPage.icons[j] = icon;
            }
          }
          AllPages.add(newPage);
      }
      phase = ExperimentPhase.BEFORE_CONDITION;
      return;
    case BEFORE_CONDITION:
      phase = ExperimentPhase.BEFORE_TRIAL;
      return;
    case BEFORE_TRIAL:
      trialStartTime = millis();
      phase = ExperimentPhase.TRIAL;
      return;

    case TRIAL:
      Page activePage = AllPages.get(currentPage);
    
      for (int i = 0; i < activePage.icons.length; i++) {
        Icon icon = activePage.icons[i];
        
        if (icon != null && icon.isHovering() && icon.name.equals(targetName)) {
          println("target found");
          elapsedTime = millis() - trialStartTime;

          TableRow newRow = baseRecords.addRow();
          newRow.setString("Condition", currentCondition.conditionName);
          newRow.setInt("SetSize", currentCondition.numIcons);
          newRow.setInt("PageSize", currentCondition.gridsize);
          newRow.setInt("NavDelay", currentCondition.navDelay);
          newRow.setInt("Trial Number", trialCounter + 1);
          newRow.setInt("Time", elapsedTime);
          newRow.setInt("Errors", numErrors);

          println("Stats: " + currentCondition.conditionName + ", Time: " + elapsedTime/1000 + " s, Errors: " + numErrors + ", Page Changes: " + numPageChanges);
          println("-----------------------");
          if (trialCounter < currentCondition.numTrials - 1) {

            targetIndex = random(currentCondition.numIcons);
            while (previousTargetIndexs[(int)targetIndex] == true) {
              targetIndex = random(currentCondition.numIcons);
            }
            previousTargetIndexs[(int)targetIndex] = true;

            Icon tempIcon = TotalIcons.get((int)targetIndex);
            targetIcon = new Icon(tempIcon.pokemon, tempIcon.name, 0, 0);
            targetIcon.w = 150;  
            targetIcon.h = 150;
            targetIcon.x = screenWidth - 300;;
            targetIcon.y = screenHeight / 2 - targetIcon.h / 2;
            
            targetName = targetIcon.name;
            println("New Target Icon: " + targetName);

            currentPage = 0;
            numErrors = 0;
            numPageChanges = 0;
            elapsedTime = 0;
            lastPageTime = millis();

            trialCounter++;
            phase = ExperimentPhase.BEFORE_TRIAL;
          } else {
            trialCounter = 0;
            currentPage = 0;
            numErrors = 0;
            numPageChanges = 0;
            elapsedTime = 0;
            lastPageTime = millis();
            conditionCounter++;
            java.util.Collections.shuffle(TotalIcons);
            AllPages.clear();
            if (conditionCounter < Conditions.size()) {
              currentCondition = Conditions.get(conditionCounter);

              createPages();
              phase = ExperimentPhase.BEFORE_CONDITION;
            } else {
              phase = ExperimentPhase.FINISHED;
            }
          }
        } else if (icon != null && icon.isHovering()) {
          println("incorrect selection");
          numErrors++;
        }
      }
      return;
    case FINISHED:


      println("COMPLETED");
      saveTable(baseRecords, "experiment_results.csv");
      println("Data saved to experiment_results.csv");
      noLoop();
      return;
  }


}