# residUUm

To run this software you will need Processing with the punktiert library installed and PureData (pd-extended includes all the (few) externals used in the project).

Make sure you follow the instructions in main.pd as you open it.

## Controls

Click and drag your mouse on the screen to generate particles.

Particles will move, attracted by the mouse cursor.

Upon collision they will generate weird fancy sounds.

Particles might eventually die, according to the lifespan assigned to them when they were generated, the global fading rate and the modifiers listed below. Lifespan is initialized for each particle to some value between 200 and 360 and decreased according to the fading rate.

The global fading rate is summed with the fading rate of each particle at each lifespan update. It defaults to 0 and is constrained between 0 and +Inf).

### Keyboard controls:
* '**m**' *mute* new particles will have short lifespan (fading rate initialized to 200)
* '**n**' *normal* new particles will have normal lifespan (fading rate initialized to 10) 
* '**s**' *sustain* new particles will have infinte lifespan (fading rate initialized to 0)
* '**f**' *forever* applies the currently selected fading rate (m,n,s) to all existing particles
* '**x**' increases the global fading rate (+8)
* '**z**' decreases the global fading rate (-8)
