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
    /* Creates the agents at the start: 5 cows at random locations, each with GAMA's random starting heading */
    init {
        create cow number: 5;
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

/* Sheep: will walk due south (no behaviour yet) */
species sheep skills: [moving] {
}

/* Goat: will walk towards the origin {0, 0} (no behaviour yet) */
species goat skills: [moving] {
}

/* Main experiment: will show the animals and their action neighbourhoods */
experiment on_the_move type: gui {
    output {
        /* Map of the world: the cows so far */
        display map {
            species cow aspect: base;
        }
    }
}
