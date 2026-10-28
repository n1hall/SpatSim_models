/**
* Name: savannah
* African savannah model: 20 lions and 20 zebras walk around randomly,
* and lions kill any zebra within 3 m. They move over a 50 x 50 grassland
* grid whose grass grows 0.1 kg per step, and each zebra eats 1 kg of grass
* per step from the cell it stands on.
* Specification: spec.md
* Author: Nihal Aliyeva
* Tags: ABM, CA
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

/* Lion: an agent that walks around randomly and kills zebras within 3 m */
species lion skills: [moving] {
    /* Moves the lion in a random direction each step */
    reflex walk {
        do wander;
    }

    /* Kills every zebra within 3 m of the lion each step */
    reflex hunt {
        ask zebra at_distance 3 {
            do die;
        }
    }

    /* Draws the lion as an orange circle of radius 3 */
    aspect base {
        draw circle(3) color: #orange;
    }
}

/* Zebra: an agent that walks around randomly and eats grass */
species zebra skills: [moving] {
    /* Moves the zebra in a random direction each step */
    reflex walk {
        do wander;
    }

    /* Eats 1 kg of grass from the cell it stands on each step, never taking biomass below 0 */
    reflex eat {
        ask grass(location) {
            biomass <- max(0.0, biomass - 1.0);
        }
    }

    /* Draws the zebra as a grey triangle with sides of 2 */
    aspect base {
        draw triangle(2) color: #grey;
    }
}

/* Grass: the 50 x 50 grassland cells of the CA, each holding grass biomass */
grid grass width: 50 height: 50 {
    /* Grass biomass in the cell (kg): random 0-10 at the start, plus 0.1 kg every step */
    float biomass <- rnd(10.0) update: biomass + 0.1;
    /* Cell colour, recalculated every step after biomass: pale green at 0 kg, dark green at 10 kg or more */
    rgb color <- blend(rgb(0, 100, 0), rgb(200, 255, 200), min(biomass / 10.0, 1.0))
        update: blend(rgb(0, 100, 0), rgb(200, 255, 200), min(biomass / 10.0, 1.0));
}

/* Main experiment: shows the grassland with the lions and zebras moving on it */
experiment savannah type: gui {
    output {
        /* Map of the savannah: grass first, then zebras, then lions on top */
        display map {
            grid grass;
            species zebra aspect: base;
            species lion aspect: base;
        }
    }
}
