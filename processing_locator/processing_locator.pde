import processing.serial.*; // serial library
 
PFont font;
 
boolean init_com = false;
Serial g_serial = null;
 
static int minAngle = -50;
static int maxAngle = +50;
static int angleStep = 1;
static int MAX_IN_BEAM = 3;
static int START_INTENSITY = 2000;
 
static class Point {
  int distance;
  int intensity;
 
  Point() {
    distance = 0;
    intensity = 0;
  }
 
  void fade() {
    if (intensity > 0) {
      intensity--;
      if (intensity == 0)
         distance = 0;
    }
  } 
 
  void setDistance(int aDistance) {
    distance = aDistance;
    intensity = START_INTENSITY;
  } 
}  
 
static class Scan {
  Point points[];  
 
  Scan (int num) {
    points = new Point[num];
    for (int i=0; i<num; i++)
      points[i] = new Point();
  }
}
 
static int NUM_SCANS = (maxAngle-minAngle)/angleStep+1;
static Scan scans[] = new Scan[NUM_SCANS];
static {
  for (int i=0; i<NUM_SCANS; i++)
    scans[i] = new Scan(MAX_IN_BEAM);
}
 
int lastAngle = 0;
 
void setup() {
  size(1024, 768, P3D);
  font = createFont("Arial",18);
  textFont(font); 
  g_serial = new Serial(this, "/dev/ttyACM1", 115200);
  init_com = true;
}
 
void fadeAll() {
  for (int a=minAngle; a<=maxAngle; a+=angleStep) {
     int scanNum = (a-minAngle)/angleStep;
     Scan scan = scans[scanNum];
     for (int l=0; l<scan.points.length; l++) {
       scan.points[l].fade();
     }
  }
}
 
int R = 500;
int rArr = 50;
int locAng = 15;
 
void draw() {
  if (init_com) {
//    if  (g_serial.available() >100) g_serial.clear();
    while (g_serial.available() >= 1)
      processSerialData();
  }
 
  background(25,10,10);
  noLights();
 // perspective();
  noStroke();
  colorMode(HSB, 100);
  pushMatrix();
  translate(width/2, height-rArr, 0);
  noFill();
  ellipseMode(CENTER);
 
  float ab1 = radians(minAngle-90);
  float ab2 = radians(maxAngle-90);
  for (int d = 20; d<=R; d+=20) {
    noFill();
    stroke(float(d)/R*100, 50, 45);
    arc(0,0,d*2,d*2,ab1,ab2);
    fill(float(d)/R*100, 100, 100);
    textAlign(RIGHT, CENTER);
    text(d, round(d*cos(ab1))-5, round(d*sin(ab1)));     
    textAlign(LEFT, CENTER);
    text(d, round(d*cos(ab2))+5, round(d*sin(ab1)));     
  }
 
  noFill();
  lights();
  int prevX = 0;
  int prevY = 0;
  boolean first = true;
  strokeWeight(4);
 
  for (int a = minAngle; a <= maxAngle; a+= angleStep) {
    int scanNum = (a-minAngle)/angleStep;
    Scan scan = scans[scanNum];
 
    for (int l=0; l<scan.points.length; l++) {
      Point point = scan.points[l];
      if (point.intensity == 0)
        continue;
 
      int d = min(R, point.distance);
      float a1 = radians(a-90);
      float a2 = radians(a-90+angleStep);
      int x1 = round(d*cos(a1));
      int y1 = round(d*sin(a1));
      int x2 = round(d*cos(a2));
      int y2 = round(d*sin(a2));
      d = round(float(d)/R*100.0);
      stroke(d, 100, point.intensity/(START_INTENSITY/100));
      line(x1, y1, x2, y2);
//      stroke(d, 50, point.intensity/(START_INTENSITY/100));
//      arc(0,0,d*2,d*2, a1, a2);
//      println("a="+a+", d"+l+"="+d);
    }
  }
 
  strokeWeight(1);
  popMatrix();
  stroke(0, 50, 50);
  translate(width/2, height-rArr, 0);
  rotateX(-PI/6);
  rotateY(-radians(lastAngle));
  fill(0,50,50);
 
  pushMatrix();
  pushMatrix();
  box(50,15,5);
  popMatrix();
  translate(0, 0, 0);
  rotateZ(PI/2);
  rotateX(-PI/2);
  rotateY(PI/2);
 
  int dx = round(sin(radians(locAng/2))*rArr/2);
  triangle(-dx, rArr, +dx, rArr, 0, 7);
  popMatrix();
 
  fadeAll();
}
 
void processSerialData() {
  boolean found = false;
  while (g_serial.available() > 0) {
    if (g_serial.read() == 'L') {
      found = true;
      break;
    }
  }
  if (!found)
    return;
 
  String sIn = g_serial.readString();
  if (sIn == null)
    return;
  String s[] = sIn.split(",");   
  if (s.length == 0)
    return;
 
  int angle = int(s[0]);
  int scanNum = (angle-minAngle)/angleStep;
  Scan scan = scans[scanNum];
  print("angle="+angle);
  for (int i=1; i<s.length && (i-1)<scan.points.length; i++) {
    String s1 = s[i].trim();
    if (s1.length() == 0)
      continue;
    int distance = int(s1)*2;
    scan.points[i-1].setDistance(distance);
    print(", d"+i+"="+distance);
  }
  lastAngle = angle; 
  if (angle < minAngle || angle > maxAngle) {
    println (" ---");
  } else {
    println ("");
  }
}
