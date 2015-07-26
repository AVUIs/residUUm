// Punktiert is a particle engine based and thought as an extension of Karsten Schmidt's toxiclibs.physics code. 
// This library is developed through and for an architectural context. Based on my teaching experiences over the past couple years. (c) 2012 Daniel Köhler, daniel@lab-eds.org

//here: spherical collission detection

import punktiert.math.Vec;
import punktiert.physics.*;

//world object
VPhysics physics;

// attractor
BAttraction attr;

Vec pos;

//number of particles in the scene
int amount = 10;
float rad;

FloatList particleLifespan;
IntList particleTrack;

float outerAngle;
float innerAngle;

float noiseVal;
float noiseScale = 0.02;

public void setup() {
  size(displayWidth, displayHeight, P3D);
  
  colorMode(HSB, 360, 100, 100, 100);

  rectMode(CENTER);

  particleLifespan = new FloatList();
//  particleTrack = new IntList();

  physics = new VPhysics(width, height);
  physics.setfriction(.1f);

  // new AttractionForce: (Vec pos, radius, strength)
  attr = new BAttraction(new Vec(width * .5f, height * .5f), 100, .1f);
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

public void draw() {
  background(map(mouseX, 0, width, 0, 360), 100, map(mouseY, 0, width, 0, 100), 360);

  physics.update();

  outerAngle = TWO_PI / 12; //map(mouseX, 0, width, 3, 20);
  //innerAngle = TWO_PI / 6;

  //lifespan -= 0.5;

  // for(int i = physics.particles.size() - 1; i >= 0; i --) {
  // 		physics.particles.get(i);
  // 		if(particleLifespan.get(i) < 0.0) {
  // 			physics.particles.remove(i);
  // 		} 
  // }

  // set pos to mousePosition
  noFill();
  attr.setAttractor(new Vec(mouseX, mouseY));
  ellipse(attr.getAttractor().x, attr.getAttractor().y, attr.getRadius(), attr.getRadius());

  // for (VParticle p : physics.particles) {
  //   ellipse(p.x, p.y, p.getRadius()*2, p.getRadius()*2);
  // }

  float a = radians(frameCount);

  for(int i = 0; i < physics.particles.size(); i ++) {

  	//particleTrack.append()
  	particleLifespan.append(360);
  	particleLifespan.sub(i, 0.25);

  	// if(particleLifespan.get(i) < 0.0) {
  	// 	  physics.particles.remove(i);
  	// }

  	stroke(map(i, 1, physics.particles.size(), 360, 0), 100, 100, particleLifespan.get(i));
    fill(map(i, 1, physics.particles.size(), 0, 360), 100, 100, particleLifespan.get(i));

    beginShape();
      for (int j = 0; j < map(mouseX, 0, width, 3, 20); j ++) {
          float x = physics.particles.get(i).x + cos(j * outerAngle - a) * physics.particles.get(i).getRadius();
          float y = physics.particles.get(i).y + sin(j * outerAngle - a) * physics.particles.get(i).getRadius();
          float z = physics.particles.get(i).z; //map(particleLifespan.get(i), 360, 0, 0, 10);
          vertex(x, y, z);
      }
      
      // beginContour();
      // for (int j = 0; j < 6; j ++) {
      //     float x = physics.particles.get(i).x + cos(j * innerAngle + a) * (physics.particles.get(i).getRadius() - random(0, (physics.particles.get(i).getRadius() - 2)));
      //     float y = physics.particles.get(i).y + sin(j * innerAngle + a) * (physics.particles.get(i).getRadius() - random(0, (physics.particles.get(i).getRadius() - 2)));
      //     float z = map(particleLifespan.get(i), 360, 0, 0, 10);
      //     vertex(x, y, z);
      // }
      // endContour();
    
    endShape( CLOSE );
    //ellipse(physics.particles.get(i).x, physics.particles.get(i).y, physics.particles.get(i).getRadius(), physics.particles.get(i).getRadius());
  }
  
  // for(int i = 0; i < physics.particles.size() - 1; i ++) {
  //   if(dist(physics.particles.get(i).x, physics.particles.get(i).y, physics.particles.get(i + 1).x, physics.particles.get(i + 1).y) < (physics.particles.get(i).getRadius() + physics.particles.get(i + 1).getRadius())) {
  //     println(physics.particles.get(i) + ", " + physics.particles.get(i + 1));
  //   }
  // }

  if(mousePressed){
    	physics.addParticle(new VParticle(new Vec(mouseX, mouseY), 1, random(5, 50)).addBehavior(new BCollision()).addBehavior(new BAttractionLocal(rad * 5, 2)));
  }
}

