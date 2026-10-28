/**
* Name: savannah
* African savannah model: 20 lions and 20 zebras walk around randomly.
* Specification: spec.md
* Author: Nihal Aliyeva
* Tags: ABM
*/

model savannah

/* Global: sets up the world and the starting population */
global {
    /* Creates 20 lions and 20 zebras at random locations */
    init {
        create lion number: 20;
        create zebra number: 20;
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

/* Zebra: an agent that walks around randomly */
species zebra skills: [moving] {
    /* Moves the zebra in a random direction each step */
    reflex walk {
        do wander;
    }

    /* Draws the zebra as a grey triangle with sides of 2 */
    aspect base {
        draw triangle(2) color: #grey;
    }
}

/* Main experiment: shows the lions and zebras moving around */
experiment savannah type: gui {
    output {
        /* Map of the savannah: zebras first, then lions drawn on top */
        display map {
            species zebra aspect: base;
            species lion aspect: base;
        }
    }
}
