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
    /* Creates the agents at the start (empty for now) */
    init {
    }
}

/* Cow: will do a correlated random walk (no behaviour yet) */
species cow skills: [moving] {
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
        /* Map of the world (no layers yet) */
        display map {
        }
    }
}
