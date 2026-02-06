import java.awt.Robot;

int IDs[] = {1, 2, 3, 4, 5, 6};

//// Movement variables
float cursorX, cursorY;
Robot robot;
PShape cursorIcon;
int cursorSize = 15;


//// Target info
Target currentTarget;

enum ExperimentPhase {
  INSTRUCTIONS,
  BEFORE_CONDITION,
  PRACTICE,
  TRIAL,
  FINISHED,
  EXPLORATION
}
ExperimentPhase phase = ExperimentPhase.INSTRUCTIONS;


class Target {
  float x;
  float y;
  float w;
  float distance;  // Distance from cursor at start
  int id;
  String type;

  Target(float x, float y, float w, float distance, int id, String type) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.distance = distance;
    this.id = id;
    this.type = type;
  }

  void display() {
    fill(0, 255, 0); // Green target [cite: 12]
    ellipse(x, y, w, w); // Draw using Width (Diameter)
  }
}

//// Condition class to hold specific conditions for targets
class Condition {
  String conditionName;
  String cursorType;
  int numPracticeTrials;
  int numTestTrials;

  Condition(String conditionName, String cursorType, int numPracticeTrials, int numTestTrials) {
    this.conditionName = conditionName;
    this.cursorType = cursorType;
    this.numPracticeTrials = numPracticeTrials;
    this.numTestTrials = numTestTrials;
  }
}

Target calculateTarget(float cursorX, float cursorY, int targetID, String type) {
    int ratio = (int)pow(2, targetID) - 1; 
    float targetX = random(50, width - 50);
    float targetY = random(50, height - 50);

    /// Use pythagorean theorem to calculate distance from cursor to target
    float distance = dist(cursorX, cursorY, targetX, targetY);
    float targetWidth = distance/ratio; 
    return new Target(targetX, targetY, targetWidth, distance, targetID, type);
}

void nextTrial() {
   // Example: Pick random ID between 1 and 6 [cite: 14]
   int randomID = IDs[int(random(IDs.length))];
   
   // Create and assign the new target
   currentTarget = calculateTarget(cursorX, cursorY, randomID, "REGULAR");
}

void setup() {
  fullScreen();

  cursorX = width / 2;
  cursorY = height / 2;
  try {
    robot = new Robot(); 
  } catch (Exception e) {
    println("Robot could not be initialized: " + e.getMessage());
  }

  currentTarget = calculateTarget(cursorX, cursorY, IDs[0], "REGULAR");

  noCursor();
}

void draw() {
  background(0);
  
  switch (phase) {
    case INSTRUCTIONS:
        cursorX += mouseX - (width / 2);
        cursorY += mouseY - (height / 2);
        cursorX = constrain(cursorX, 0, width);
        cursorY = constrain(cursorY, 0, height);

        
        fill(255, 0, 0);
        ellipse(cursorX, cursorY, cursorSize, cursorSize);

        robot.mouseMove(width/2, height/2);
        if (currentTarget != null) {
            currentTarget.display();
        }
      break;
    case BEFORE_CONDITION:

      break;
    case PRACTICE:

      break;
    case TRIAL:

      break;
    case FINISHED:

      break;
    case EXPLORATION:
      
      break;
  }
}


void mouseClicked() {
  if (phase == ExperimentPhase.INSTRUCTIONS) {
        float distance = dist(cursorX, cursorY, currentTarget.x, currentTarget.y);
        if (distance <= currentTarget.w / 2) {
            println("Target Clicked!");
            nextTrial();
        } else {
            println("Missed! Try Again.");
        }
    //   phase = ExperimentPhase.BEFORE_CONDITION;
  }
}