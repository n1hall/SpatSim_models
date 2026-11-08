/**
* Name: on_the_move
* On the move: 5 brown cows do a correlated random walk, 3 black sheep walk
* south and 2 yellow goats walk towards the origin; each agent's action
* neighbourhood is drawn around it. This file holds the structure only.
* Specification: spec_on_the_move.md
* Author: Nihal Aliyeva
* Tags: ABM, movement
*/

model on_the_move

/* Global: sets up the world and the starting population */
global {
    /* Creates the agents at the start: 5 cows (each with GAMA's random starting heading), 3 sheep and 2 goats, all at random locations */
    init {
        create cow number: 5;
        create sheep number: 3;
        create goat number: 2;
    }
}

/* Cow: does a correlated random walk, 2 m per step, turning at most 90 degrees left or right */
species cow skills: [moving] {
    /* Moves 2 m each step; amplitude 180 lets the new heading be at most 90 degrees either side of the current one */
    reflex move {
        do wander speed: 2.0 amplitude: 180.0;
    }

    /* Draws the cow as a brown circle of radius 1 */
    aspect base {
        draw circle(1) color: #brown;
    }
}

/* Sheep: walks due south, 1 m per step */
species sheep skills: [moving] {
    /* Moves 1 m each step with the fixed heading 90, which is south in GAMA */
    reflex move {
        do move heading: 90.0 speed: 1.0;
    }

    /* Draws the sheep as a black circle of radius 1 */
    aspect base {
        draw circle(1) color: #black;
    }
}

/* Goat: walks straight towards the origin {0, 0}, 0.5 m per step, and stops there */
species goat skills: [moving] {
    /* Moves 0.5 m each step towards {0, 0}; once there, goto leaves the goat where it is */
    reflex move {
        do goto target: {0.0, 0.0} speed: 0.5;
    }

    /* Draws the goat as a yellow circle of radius 1 */
    aspect base {
        draw circle(1) color: #yellow;
    }
}

/* Main experiment: will show the animals and their action neighbourhoods */
experiment on_the_move type: gui {
    output {
        /* Map of the world: the cows, sheep and goats */
        display map {
            species cow aspect: base;
            species sheep aspect: base;
            species goat aspect: base;
        }
    }
}
