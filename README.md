# residUUm

## Prerequisites

To run this software you will need Processing with the punktiert, oscP5 and netP5 libraries and PureData with a few externals (pd-extended includes all the  externals used in the project).

oscP5 and netP5 should be easily automatically installed from Processing, while automatic installation often fails for punktiert.
To install punktiert, get the zip file from http://www.lab-eds.org/punktiert and follow instructions at https://github.com/djrkohler/punktiert/blob/master/resources/install_instructions.txt

To run the software:
* open the main.pd file in pd-extended and it the button you find at the bottom of the window, wait a few seconds and you are ready to go.
* adjust the levels for particles, collisions and master in the main window
* keep the pd window open and open residUUm.pde in Processing and hit run. You are all set to go!

## Usage

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
