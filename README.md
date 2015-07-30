# residUUm

To run this software you will need Processing with the punktiert library installed and PureData (pd-extended includes all the (few) externals used in the project).

Make sure you follow the instructions in main.pd as you open it.

## Controls

Click and drag your mouse on the screen to generate particles.

Particles will move, attracted by the mouse cursor.

Upon collision they will generate weird fancy sounds.

Keyboard controls:
* '**m**' *mute* new particles will have short lifetime
* '**n**' *normal* new particles will have normal lifetime
* '**s**' *sustain* new particles will have infinte lifetime
* '**f**' *forever* applies the currently selected lifetime (m,n,s) to all existing particles
* '**x**' increases the fading rate for all particles
* '**z**' decreases the fading rate for all particles (minimum: 0)



