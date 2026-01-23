PImage img;
BufferedReader reader;
String name;
ArrayList<Icon> TotalIcons = new ArrayList<Icon>();
ArrayList<Page> AllPages = new ArrayList<Page>();

int cols = 8;
int rows = 8;
int screenWidth = 1200;
int screenHeight = 800;

int gridsize = 8;
int pageIconsNum = 64;
int iconNum = 1025;


//// Target Icon Info
Icon targetIcon;
String targetName = "";
float targetX;
float targetY;
float targetIndex;
float previousTargetIndexs[] = new float[iconNum];


//// Page Info
int currentPage = 0;
int totalPages; 


//// key info
boolean rightPressed = false;
boolean leftPressed = false;
int delayTime = 500; 
int lastPageTime = 0;


//// End Screen Info
int elapsedTime = 0;
int numErrors = 0;
int numPageChanges = 0;
boolean targetFound = false;



class Icon {
  PImage pokemon;
  String name;
  float x, y;
  
  Icon(PImage pokemon, String name, float x, float y) {
    this.pokemon = pokemon;
    this.name = name;
    this.x = x;
    this.y = y;
  }

  boolean isHovering() {
    return mouseX >= x && mouseX <= x + pokemon.width &&
           mouseY >= y && mouseY <= y + pokemon.height;
  }

  void display () {
    image(pokemon, x, y);

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



void settings() {
  size(screenWidth, screenHeight);
}

void setup() {
  reader = createReader("filenames.txt"); 

  float iconW = (screenWidth - 400) / cols; 
  float iconH = screenHeight / rows;


  targetIndex = random(iconNum);

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
      if (i == (int)targetIndex) {
        println("Target Icon: " + name);
        targetName = name;
      }
      PImage tempImg = loadImage("icons/" + name);
      tempImg.resize((int)iconW, (int)iconH);
      TotalIcons.add(new Icon(tempImg, name, 0, 0)); // give temporary position for now
    }
  }

  totalPages = (int)ceil(TotalIcons.size() / (float)pageIconsNum); 
  println("Verified Total Pages: " + totalPages);

  PImage targetImg = loadImage("icons/" + targetName);
  targetImg.resize((int)iconW, (int)iconH);
  targetIcon = new Icon(targetImg, targetName, screenWidth - 300, screenHeight / 2 - iconH / 2);

  java.util.Collections.shuffle(TotalIcons);

  for (int i = 0; i < totalPages; i++) {
      Page newPage = new Page(new Icon[pageIconsNum], i);
      for (int j = 0; j < pageIconsNum; j++) {
        int index = i * pageIconsNum + j;
        if (index < TotalIcons.size()) {
          Icon icon = TotalIcons.get(index);
          float x = (j % cols) * iconW;
          float y = (j / cols) * iconH;
          icon.x = x;
          icon.y = y;
          newPage.icons[j] = icon;
        }
      }
      AllPages.add(newPage);
  }

  println("Total icons loaded: " + TotalIcons.size());
  println("Total pages created: " + AllPages.size());
}

void draw() {
  background(255);

  if (!targetFound) {
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
  } else {
    // End Screen
    background(200);
    fill(0);
    textSize(32);
    textAlign(CENTER, CENTER);
    text("Target " + targetName + " Found,", screenWidth / 2, screenHeight / 2 - 60);
    textSize(24);
    text("Elapsed Time: " + (elapsedTime / 1000) + " seconds,", screenWidth / 2, screenHeight / 2);
    text("Number of Errors: " + numErrors + ",", screenWidth / 2, screenHeight / 2 + 40);
    text("Number of Page Changes: " + numPageChanges + ",", screenWidth / 2, screenHeight / 2 + 80);
    textSize(18);
    text("Click anywhere to start again.", screenWidth / 2, screenHeight / 2 + 140);
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
  if (!targetFound) {
    Page activePage = AllPages.get(currentPage);
    
    for (int i = 0; i < activePage.icons.length; i++) {
      Icon icon = activePage.icons[i];
      
      if (icon != null && icon.isHovering() && icon.name.equals(targetName)) {
        println("target found");
        elapsedTime = millis();
        targetFound = true;
      } else if (icon != null && icon.isHovering()) {
        println("incorrect selection");
        numErrors++;
      }
    }
  } else {
    // Reset the game
    currentPage = 0;
    numErrors = 0;
    numPageChanges = 0;
    elapsedTime = 0;
    lastPageTime = millis();

    // store previous target indexes
    previousTargetIndexs[(int)targetIndex] = targetIndex;

    targetIndex = random(iconNum);
    while (previousTargetIndexs[(int)targetIndex] == targetIndex) {
      targetIndex = random(iconNum);
    }

    java.util.Collections.shuffle(TotalIcons);
    AllPages.clear();

    // Select a new target icon
    Icon newTargetIcon = TotalIcons.get((int)targetIndex);

    targetIcon = new Icon(newTargetIcon.pokemon, newTargetIcon.name, 0, 0);
    targetIcon.x = screenWidth - 300;;
    targetIcon.y = screenHeight / 2 - targetIcon.pokemon.height / 2;
    targetName = targetIcon.name;
    println("New Target Icon: " + targetName);


    for (int i = 0; i < totalPages; i++) {
        Page newPage = new Page(new Icon[pageIconsNum], i);
        for (int j = 0; j < pageIconsNum; j++) {
          int index = i * pageIconsNum + j;
          if (index < TotalIcons.size()) {
            Icon icon = TotalIcons.get(index);
            float iconW = (screenWidth - 400) / cols; 
            float iconH = screenHeight / rows;
            float x = (j % cols) * iconW;
            float y = (j / cols) * iconH;
            icon.x = x;
            icon.y = y;
            newPage.icons[j] = icon;
          }
        }
        AllPages.add(newPage);
    }

    targetFound = false;
  }
}