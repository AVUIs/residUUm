import punktiert.math.Vec;
import punktiert.physics.*;
// import OSC utils
import oscP5.*;
import netP5.*;

import java.util.regex.*;

// declare OSC objects
OscP5 oscP5;
NetAddress myRemoteLocation;

//world object
VPhysics physics;

// attractor
BAttraction attr;

Vec pos;

//number of particles in the scene
int amount = 0;
int sides;
float rad;

int satVal;
int brightVal;

float radiusNoise = random(10);

boolean oneLine = true;
boolean twoLines = false;

float lineChange = 0.0;

int frameGague = 24;

float [] multScaler = {0.5, 0.5, 0.5, 0.5, 0.5, 1, 1, 1, 1, 1, 2, 2, 2, 3, 4, 5};

IntList particleIdMapping;
float particleSize;
FloatList particleShape;
float particleLocationX;
float particleLocationY;
float particleLocationZ;
float particleRotation;
FloatList particleColorH;
float particleColorS;
float particleColorB;
float particleColorA;
FloatList particleLifespan;
FloatList particleGroup;
FloatList fadeOut;

int groupCounter = 0;
int maxGroups = 6;
IntList shapeId;
int particleBehavior;
// IntList sideId;
// int circSide;

float angle;
float halfAngle; 
float radius1, radius2;
float newFadeOut=10;
float globalFadeOut=0;
float outerAngle;
float innerAngle;

int maxNumParticles=45;
int numMessages=0;
boolean collisions=true;
public void setup() {
  size(displayWidth, displayHeight, OPENGL);
  //size(800, 600, OPENGL);
  colorMode(HSB, 360, 100, 100, 100);
  smooth(8);

  rectMode(CENTER);

  oscP5 = new OscP5(this, 11998);

  // set remote location 
  myRemoteLocation = new NetAddress("127.0.0.1", 12004);
  // myRemoteLocation = new NetAddress("192.168.2.1", 12004);

  OscMessage newMessage = new OscMessage("/global");
  newMessage.add("/muteAll");
  oscP5.send(newMessage, myRemoteLocation);

  OscMessage backMessage = new OscMessage("/global");
  backMessage.add("/back");
  backMessage.add(0);
  oscP5.send(backMessage, myRemoteLocation);

  particleGroup = new FloatList();
  particleLifespan = new FloatList();
  fadeOut = new FloatList();
  particleIdMapping = new IntList();
  shapeId = new IntList();
  // sideId = new IntList();
  for(int n = 0; n < maxNumParticles; n++) {
    particleLifespan.append(-1);
    particleIdMapping.append(-1);
    shapeId.append(-1);
    fadeOut.append(-1);
  }

  physics = new VPhysics(width, height);
  physics.setfriction(.1f);//map(mouseY, 0, width, 0.0f, 1.0f));

  // new AttractionForce: (Vec pos, radius, strength)
  attr = new BAttraction(new Vec(width * .5f, height * .5f), 100, 20f);
  physics.addBehavior(attr);

  for (int i = 0; i < amount; i ++) {
    //val for arbitrary radius
    rad = random(5, 200);
    //vector for position
    pos = new Vec (random(rad, width - rad), random(rad, height - rad), 0);
    //create particle (Vec pos, mass, radius)
    VParticle particle = new VParticle(pos, 1, rad);
    //add Collision Behavior
    particle.addBehavior(new BCollision());
    // add Local Attractor on each Particle (radius, strength)
    particle.addBehavior(new BAttractionLocal(rad * 5, 2));
    //add Cohesion Behavior to each Particle (radius, maxSpeed, maxForce)
    particle.addBehavior(new BCohesion(100, 1.5f, .5f));
    //add particle to world
    physics.addParticle(particle);
  }
}

//enable full screen presentation mode
boolean sketchFullScreen()
{
   return true;
}


int callsToDraw=0;
int HERE=0;
public void draw() {
  frameRate(frameGague);

  /*if(satVal < 60) background(360, 100, 0);
  else if(brightVal < 50) background(360, 0, 100);
  else */background(map(mouseX, 0, width, 0, 360), map(mouseX, 0, width, 0, 100), map(mouseY, 0, height, 0, 100));
  
  cursor(CROSS);

  physics.update();

  physics.setfriction(map(mouseY, 0, width, 0.0f, 1.0f));
  //println(physics.getfriction());

  drawShape();

  // set pos to mousePosition
  noFill();
  attr.setAttractor(new Vec(mouseX, mouseY));
  ellipse(attr.getAttractor().x, attr.getAttractor().y, attr.getRadius(), attr.getRadius());

  if((callsToDraw&1)==0){
    OscMessage newMessage = new OscMessage("/route");
    newMessage.add("/counter");
    newMessage.add(numMessages++);
    boolean done=false;
    for(int n = 0; n < particleIdMapping.size(); n ++) {
      int particleIndex=getParticleFromId(n);
      if(particleIndex<0)  //true only if not all of the voices are allocated
        continue;
      done=true;
      float lifespan=getLifespan(n);
      if(lifespan<0){
        if(HERE == 0){
          // println("You shouldn't be here");
          // println("id: "+n+"; particle: "+particleIndex);
        }
        HERE=1;
        continue;// println("sending message for id: "+n+"; particle: "+particleIndex+"; lifespan: "+lifespan);
      }
      newMessage.add("/id");
      newMessage.add(n);
      if(lifespan >= 0) {
        particleLifespan.sub(n, (globalFadeOut + fadeOut.get(n)));
        if(particleLifespan.get(n) < 0.0) {
          unassignId(n);
        }
      }
      newMessage.add("/lifespan");
      newMessage.add(getLifespan(n));
      newMessage.add("/locationx");
      newMessage.add(physics.particles.get(particleIndex).x);
      newMessage.add("/locationy");
      newMessage.add(physics.particles.get(particleIndex).y);
      // newMessage.add("/locationz");
      // newMessage.add(map(particleLifespan.get(i), 360, 0, 5, 100));    
    }
    // println("collisions:"+collisions);
    for(int i = 0; i < physics.particles.size(); i++){
      if(getIdFromParticle(i)<0)
        continue;
      for(int n = i + 1; n < physics.particles.size(); n++) {
        if(getIdFromParticle(n)<0)
          continue;
        if(
            collisions == true 
              &&
            dist(physics.particles.get(i).x, physics.particles.get(i).y, physics.particles.get(n).x, physics.particles.get(n).y) < 
            (physics.particles.get(i).getRadius() + physics.particles.get(n).getRadius()) 
              &&
            dist(mouseX, mouseY, physics.particles.get(n).x, physics.particles.get(n).y) < 200 
          ) 
        {
          done=true;
          //println(physics.particles.get(i) + ", " + physics.particles.get(i + 1));
          newMessage.add("/id");
          newMessage.add(i);
          newMessage.add("/collision");
          newMessage.add(1);
          newMessage.add("/id");
          newMessage.add(n);
          newMessage.add("/collision");
          newMessage.add(1);
          //point(physics.particles.get(i).x, physics.particles.get(i).y);
          //ellipse(physics.particles.get(i).x, physics.particles.get(i).y, rippleSize, rippleSize);
          float rippleX1;
          float rippleY1;
          float rippleX2;
          float rippleY2;

          float radAng;
          
          float thisRadius;

          float lastX1 = random(width);
          float lastY1 = random(height);
          float lastX2 = random(width);
          float lastY2 = random(height);

          float multScalerVal = 1.0;

          beginShape();

          for(int j = 0; j <= 360; j ++) {
            radAng = radians(j);
            radiusNoise += 0.005;
            thisRadius = physics.particles.get(i).getRadius() * multScalerVal + (noise(radiusNoise) * random(physics.particles.get(i).getRadius()));

            if(oneLine) multScalerVal = multScaler[5];
              else if(twoLines) multScalerVal = multScaler[(int)random(0, 15)];

            rippleX1 = physics.particles.get(i).x + (thisRadius * cos(radAng));
            rippleY1 = physics.particles.get(i).y + (thisRadius * sin(radAng));

            rippleX2 = physics.particles.get(n).x + (thisRadius * cos(radAng));
            rippleY2 = physics.particles.get(n).y + (thisRadius * sin(radAng));

            if(oneLine) {
              strokeWeight(map(mouseX, 0, width, j, 50));
              if(satVal < 60) stroke(360, 0, 100, random(100));
              else if(brightVal < 50) stroke(360, 100, 0, random(100));
              else stroke(map(getIdFromParticle(i), 1, maxNumParticles, 0, 360), 100, 100, random(1, 15));

              line(rippleX1, rippleY1, lastX1, lastY1);
            }
            else if(twoLines) {
              strokeWeight(random(lineChange));
              if(satVal < 60) stroke(360, 0, 100, random(100));
              else if(brightVal < 50) stroke(360, 100, 0, random(100));
              else stroke(map(getIdFromParticle(i), 1, maxNumParticles, 0, 360), 100, 100, random(100));
              line(rippleX1, rippleY1, lastX1, lastY1);

              if(satVal < 60) stroke(360, 0, 100, random(100));
              else if(brightVal < 50) stroke(360, 100, 0, random(100));
              else stroke(map(getIdFromParticle(n), 1, maxNumParticles, 360, 0), 100, 100, random(100));
              line(rippleX2, rippleY2, lastX2, lastY2);
            } 

            lastX1 = rippleX1;
            lastY1 = rippleY1;

            lastX2 = rippleX2;
            lastY2 = rippleY2;
          }
          endShape(); 
        }
      }
    }
    if(done)
      oscP5.send(newMessage, myRemoteLocation);
  }
  callsToDraw ++;
   
  if(mousePressed) {
    satVal = (int(random(55, 100)));
    brightVal = (int(random(45, 100)));
    if(satVal < 60) {
      OscMessage backMessage = new OscMessage("/global");
      backMessage.add("/back");
      backMessage.add(2);
      oscP5.send(backMessage, myRemoteLocation);
    }
    else if(brightVal < 50) {
      OscMessage backMessage = new OscMessage("/global");
      backMessage.add("/back");
      backMessage.add(1);
      oscP5.send(backMessage, myRemoteLocation);
    }
    else {
      OscMessage backMessage = new OscMessage("/global");
      backMessage.add("/back");
      backMessage.add(0);
      oscP5.send(backMessage, myRemoteLocation);
    }
    particleBehavior = (int)random(0, 4);
    int sizeBefore=physics.particles.size();
    if(particleBehavior == 0) physics.addParticle(new VParticle(new Vec(mouseX, mouseY, 0), 1, random(5, 120)).addBehavior(new BCollision()));
    else if(particleBehavior == 1) physics.addParticle(new VParticle(new Vec(mouseX, mouseY, 0), 1, random(5, 20)).addBehavior(new BAttractionLocal(rad * 5, 2)));
    else if(particleBehavior == 2) physics.addParticle(new VParticle(new Vec(mouseX, mouseY, 0), 1, random(50, 100)).addBehavior(new BCohesion(100, 1.5f, .5f)));
    else if(particleBehavior == 3) physics.addParticle(new VParticle(new Vec(mouseX, mouseY, 0), 1, random(50, 150)).addBehavior(attr));
    int sizeAfter=physics.particles.size();
    if(sizeBefore==sizeAfter){
      // println("Size before: "+sizeBefore);
      // println("Size after: "+sizeAfter);
      // println("behavior: "+particleBehavior);
      // printArray();
    } else {
      int particle=physics.particles.size()-1;
      int id=assignIdToParticle(particle);
      // println("Just assigned this id: "+id+" to particle "+particle);
      if(id<0) {//there are no more ids available, fuckit
        println("there are no more ids available, fuckit");
        // printArray();
      } else {
        shapeId.set(id, (int)random(0, 5));
        // sideId.set(id, (int)random(20, 360));
        particleLifespan.set(id, random(200, 360)); //and initialize lifespan
        fadeOut.set(id, newFadeOut);
      }
    }
  }
}

int previousParticlesCount = 0;
void mouseReleased() {
  // if (true)
  //   return;
  //particleGroup.append(groupCounter);
  OscMessage newMessage = new OscMessage("/route");
  newMessage.add("/counter");
  newMessage.add(numMessages++);
  for(int i = previousParticlesCount; i < physics.particles.size(); i ++) {
    int id=getIdFromParticle(i);
    if(id < 0)
      continue;
    // println("id: "+id);
    newMessage.add("/id");
    newMessage.add(id);
    newMessage.add("/size");
    newMessage.add(physics.particles.get(i).getRadius());
    newMessage.add("/color");
    newMessage.add(map(i, 1, physics.particles.size(), 0, 360));
    // newMessage.add(map(id, 1, physics.particles.getHue(i), 0, 360));
    newMessage.add("/shape");
    newMessage.add(shapeId.get(id));
    // newMessage.add("/locationy");
    // newMessage.add(physics.particles.get(i).y);
    newMessage.add("/locationz");
    newMessage.add(physics.particles.get(i).z);
    newMessage.add("/group");
    newMessage.add(groupCounter);
  }
  oscP5.send(newMessage, myRemoteLocation);
  previousParticlesCount = physics.particles.size();
  // println(physics.particles.size() + " " + previousParticlesCount);
  groupCounter ++;
  if(groupCounter>=maxGroups)
    groupCounter=0;
}

void drawShape() {
  particleRotation = radians((int)random(0, 360)); //radians(frameCount);

  for(int i = 0; i < physics.particles.size(); i ++) {
    int id=getIdFromParticle(i);
    if(id < 0)
      continue;
    int shape=shapeId.get(id);
    // if(shape == 4) circSide = sideId.get(id);
    //if(shape != 4) particleRotation = radians((int)random(0, 360)); //radians(frameCount);
    switch((shape)) {
      case 0: //rectangle
        shape = 0;
        sides = 4;
        break;
      case 1: //triangle
        shape = 1;
        sides = 3;
        break;
      case 2: //star
        shape = 2;
        break;
      case 3: //line
        shape = 3;
        break;
      case 4: //ellipse
        shape = 4;
        sides = 360; //circSide;
        break;
    } 
    outerAngle = TWO_PI / sides;
    innerAngle = TWO_PI / sides;

    // println("I drew this id"+id);
    strokeWeight(1);

    stroke(map(id, 1, maxNumParticles, 360, 0), 100, 100, map(particleLifespan.get(id), 360, 0, 100, 0));
    fill(map(id, 1, maxNumParticles, 0, 360), map(particleLifespan.get(id), 360, 0, 100, 60), map(particleLifespan.get(id), 360, 0, 100, 50), map(particleLifespan.get(id), 360, 0, 100, 0));
    //fill(map(id, 1, maxNumParticles, 0, 360), satVal, brightVal, map(particleLifespan.get(id), 360, 0, 100, 0));

    if((shape < 2) || ((shape != 3) && (shape > 2))) {
      pushMatrix();
      radiusNoise += 0.005;
        beginShape();
          for (int j = 0; j < sides; j ++) {
              float x = physics.particles.get(i).x + cos(j * outerAngle - particleRotation) * physics.particles.get(i).getRadius();
              float y = physics.particles.get(i).y + sin(j * outerAngle - particleRotation) * physics.particles.get(i).getRadius();
              float z = map(particleLifespan.get(id), 360, 0, 100, 0); //physics.particles.get(i).z; //map(particleLifespan.get(id), 360, 0, 0, 10);
              vertex(x, y, z);
          }
          
          // beginContour();
          // for (int j = 0; j < sides; j ++) {
          //   radiusNoise += 0.005;
          //     float x = physics.particles.get(i).x + noise(radiusNoise) * cos(j * innerAngle + particleRotation) * physics.particles.get(i).getRadius()/2; // - random(0, (physics.particles.get(i).getRadius() - 2)));
          //     float y = physics.particles.get(i).y + noise(radiusNoise) * sin(j * innerAngle + particleRotation) * physics.particles.get(i).getRadius()/2; // - random(0, (physics.particles.get(i).getRadius() - 2)));
          //     float z = map(particleLifespan.get(id), 360, 0, 100, 0); //physics.particles.get(i).z; //map(particleLifespan.get(id), 360, 0, 0, 10);
          //     vertex(x, y, z);
          // }
          // endContour();
        
        endShape(CLOSE);
      popMatrix();
    }
    else if(shape == 2) {

      angle = TWO_PI / (map(mouseX, 0, width, 1, 10));
      halfAngle = angle/2.0;

      pushMatrix();
        beginShape();
        for (float a = 0; a < TWO_PI; a += angle) {
          float x = physics.particles.get(i).x + cos(a - particleRotation) * physics.particles.get(i).getRadius();
          float y = physics.particles.get(i).y + sin(a - particleRotation) * physics.particles.get(i).getRadius();
          float z = map(particleLifespan.get(id), 360, 0, 100, 0); //physics.particles.get(i).z;
          vertex(x, y, z);
          x = physics.particles.get(i).x + cos(a + halfAngle - particleRotation) * physics.particles.get(i).getRadius() / 2.0;
          y = physics.particles.get(i).y + sin(a + halfAngle - particleRotation) * physics.particles.get(i).getRadius() / 2.0;
          z = map(particleLifespan.get(id), 360, 0, 100, 0); //physics.particles.get(i).z;
          vertex(x, y, z);
        }
        endShape(CLOSE);
      popMatrix();
    }
    else if(shape == 3) {
      pushMatrix();
      strokeWeight((int)random(1, physics.particles.get(i).getRadius()));
      line(physics.particles.get(i).x, 0, physics.particles.get(i).x, height);
      line(0, physics.particles.get(i).y, width, physics.particles.get(i).y);
      for(int j = 0; j < physics.particles.size() - 1; j ++) {
        //strokeWeight(1);
        int idj=getIdFromParticle(j);
        if(idj < 0)
          continue;
        strokeWeight(2);
        rotate(particleRotation);
        stroke(map(j, 1, physics.particles.size(), 360, 0), 100, 100, map(particleLifespan.get(idj), 360, 0, 100, 0));
        line(physics.particles.get(j).x, physics.particles.get(j).y, physics.particles.get(j).z, 
             physics.particles.get(j + 1).x, physics.particles.get(j + 1).y, physics.particles.get(j + 1).z);
      }
      popMatrix();
    }   
  }
}

int assignIdToParticle(int particle){
  int id=getAvailableId();
  if(id>=0){
    particleIdMapping.set(id,particle);
  }
  return id;
}

void unassignId(int id){
  particleIdMapping.set(id, -1);
}

int getIdFromParticle(int particle){
  for(int n = 0; n < particleIdMapping.size(); n++){
    if(particle==particleIdMapping.get(n))
      return n;
  }
  return -1;
}

int getParticleFromId(int id){
for(int  i = 0; i < physics.particles.size(); i++){
    if(id==getIdFromParticle(i))
      return i;
  }
  return -1;
}

int getAvailableId(){
  for(int n = 0; n < particleIdMapping.size(); n++){
    if(particleIdMapping.get(n)==-1)
      return n;
  }
  return -1;
}
float getLifespan(int id){
  return particleLifespan.get(id);
}
void setLifespan(int id, float value){
  particleLifespan.set(id, value);
}

void printArray(){
  for(int n=0; n<maxNumParticles; n++){
    println("id: "+n+"   "+particleLifespan.get(n)+"   "+particleIdMapping.get(n));
  }
}
int getNumActiveParticles(){
  int count=0;
  for(int n = 0; n < particleIdMapping.size(); n++){
    if(particleIdMapping.get(n)!=-1)
      count++;
  }
  return count;
}
void keyPressed(){
  fill(360, 0, 100, 20);
  noStroke();
  if(key == RETURN || key == ENTER)
    printArray();
  if(key == 'q'){
    newFadeOut=50;  
    globalFadeOut=0;
    collisions=false;
    println("fade "+newFadeOut);
    //ellipse(1350, height - 100, 10, 10);
    return;
  }
  if(key == 'w'){
    //ellipse(1350, height - 120, 10, 10);
    for(int n=0; n<particleIdMapping.size(); n++){
      fadeOut.set(n, newFadeOut);
      // println("fadeout"+fadeOut.get(n));
    }
    return;
  }
  collisions=true;
  if(key == 'a'){
    newFadeOut=2.5;   
    globalFadeOut=0;
    println("fade "+newFadeOut);
    //ellipse(1350, height - 60, 10, 10);
    return;
  }
  if(key == 's'){
    newFadeOut=0;  
    globalFadeOut=0;
    println("fade "+newFadeOut);
    //ellipse(1350, height - 20, 10, 10);
    return;
  }
  if(key == 'x'){
    globalFadeOut+=2;
    //ellipse(1350, height - 40, 10, 10);
    return;
  }
  if(key == 'z'){
    //ellipse(1350, height - 20, 10, 10);
    globalFadeOut-=2;
    if(globalFadeOut<0) 
      globalFadeOut=0;
    return;
  }

  if(key == 'l') {
    oneLine = !oneLine;
    twoLines = !twoLines;
  }

  char [] s = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};

  for(float i = 0; i < s.length; i ++) {
    if(key == s[(int)i]) lineChange = i;
  
    switch((int)lineChange) {
      case 0:
        lineChange = 0.5;
        break;
      case 1:
        lineChange = 1;
        break;
      case 2:
        lineChange = 2;
        break;
      case 3:
        lineChange = 3;
        break;
      case 4:
        lineChange = 4;
        break;
      case 5:
        lineChange = 5;
        break;
      case 6:
        lineChange = 6;
        break;
      case 7:
        lineChange = 7;
        break;
      case 8:
        lineChange = 8;
        break;
      case 9:
        lineChange = 9;
        break;
    }
  }

  if ((key == 'g') || (key == 'h')) {

    if (key == 'g') {
      frameGague --;
      if(frameGague <= 0) frameGague = 24;
    } else if (key == 'h') {
            frameGague ++;
            if(frameGague >= 25) frameGague = 1;
           }

    println("frameGague: " + frameGague);
  }
}

  
  

