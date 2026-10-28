/**
* Name: savannah
* African savannah model, first step: 20 lions walk around randomly.
* Specification: spec.md
* Author: Nihal Aliyeva
* Tags: ABM
*/

model savannah

/* Global: sets up the world and the starting population */
global {
    /* Creates 20 lions at random locations */
    init {
        create lion number: 20;
    }
}

/* Lion: an agent that walks around randomly */
species lion skills: [moving] {
    /* Moves the lion in a random direction each step */
    reflex walk {
        do wander;
    }

    /* Draws the lion as an orange circle of radius 3 */
    aspect base {
        draw circle(3) color: #orange;
    }
}

/* Main experiment: shows the lions moving around */
experiment savannah type: gui {
    output {
        /* Map of the savannah showing the lions */
        display map {
            species lion aspect: base;
        }
    }
}
