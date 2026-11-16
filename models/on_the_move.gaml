/**
* Name: on_the_move
* On the move: 5 brown cows do a correlated random walk, 3 black sheep walk
* south and 2 yellow goats walk towards the origin. Every agent keeps its
* action neighbourhood (where it can be after one step) in a geometry
* attribute that is redrawn each step as a see-through layer.
* Specification: spec_on_the_move.md
* Author: Nihal Aliyeva
* Tags: ABM, movement
*/

model on_the_move

/* Global: sets up the world and the starting population */
global {
    /* Heading change of every cow at every step, in degrees from -180 to 180 */
    list<float> turns <- [];
    /* Number of sheep within 1 m of the south edge */
    int sheep_at_edge <- 0;
    /* Number of goats within 0.5 m of the origin {0,0} */
    int goats_at_origin <- 0;

    /* Creates 5 cows, 3 sheep and 2 goats at random locations; each cow starts with its action area for cycle 0 */
    init {
        create cow number: 5 {
            action_area <- cone(heading - 45, heading + 45) inter circle(2.0);
        }
        create sheep number: 3;
        create goat number: 2;
    }

    /* Every cycle, counts the sheep within 1 m of the south edge and the goats within 0.5 m of the origin */
    reflex update_counters {
        sheep_at_edge <- sheep count (each.location.y >= world.shape.height - 1.0);
        goats_at_origin <- goat count ((each.location distance_to {0, 0}) < 0.5);
    }
}

/* Cow: correlated random walk, 2 m per step, heading change within a 90-degree range (-45 to +45) */
species cow skills: [moving] {
    /* Body colour */
    rgb color <- #brown;
    /* Action neighbourhood: the 90-degree sector in front of the heading, cut to the reach of one step (radius 2 = speed) */
    geometry action_area <- cone(heading - 45, heading + 45) inter circle(2.0);
    /* Total distance moved so far (m) */
    float distance_travelled <- 0.0;
    /* Heading before the current move, used to measure the turn */
    float previous_heading;

    /* Moves 2 m with a random heading change inside a 90-degree range, adds the distance moved and the turn (-180 to 180 degrees) to the records, then updates the action area to the new heading */
    reflex move {
        point before <- location;
        previous_heading <- heading;
        do wander amplitude: 90.0 speed: 2.0;
        distance_travelled <- distance_travelled + (before distance_to location);
        float turn <- heading - previous_heading;
        loop while: turn > 180.0 { turn <- turn - 360.0; }
        loop while: turn < -180.0 { turn <- turn + 360.0; }
        add turn to: turns;
        action_area <- cone(heading - 45, heading + 45) inter circle(2.0);
    }

    /* Body: brown circle of radius 1.5 */
    aspect default {
        draw circle(1.5) color: color;
    }

    /* Action neighbourhood: see-through reach circle of radius 2 with a brown border, and the 90-degree sector inside it */
    aspect action_neighbourhood {
        draw circle(2.0) color: rgb(color.red, color.green, color.blue, 0.2) border: color;
        if (action_area != nil) {
            draw action_area color: color;
        }
    }
}

/* Sheep: walks due south, 1 m per step */
species sheep skills: [moving] {
    /* Body colour */
    rgb color <- #black;
    /* Action neighbourhood: circle of radius 1 = speed, set after the first move */
    geometry action_area;
    /* Total distance moved so far (m) */
    float distance_travelled <- 0.0;

    /* Sets the heading to 90 (south in GAMA, y grows downwards), moves 1 m, adds the distance moved and updates the action area */
    reflex move {
        point before <- location;
        heading <- 90.0;
        do move speed: 1.0;
        distance_travelled <- distance_travelled + (before distance_to location);
        action_area <- circle(1.0);
    }

    /* Body: black circle of radius 0.6 (smaller than the reach circle so the neighbourhood stays visible) */
    aspect default {
        draw circle(0.6) color: color;
    }

    /* Action neighbourhood: grey circle of radius 1 */
    aspect action_neighbourhood {
        if (action_area != nil) {
            draw action_area color: #gray;
        }
    }
}

/* Goat: walks straight towards the origin {0,0}, 0.5 m per step, and stops there */
species goat skills: [moving] {
    /* Body colour */
    rgb color <- #yellow;
    /* Action neighbourhood: circle of radius 0.5 = speed, set after the first move */
    geometry action_area;
    /* Total distance moved so far (m) */
    float distance_travelled <- 0.0;

    /* Moves 0.5 m towards {0,0} (goto does nothing once there), adds the distance moved and updates the action area */
    reflex move {
        point before <- location;
        do goto target: {0, 0} speed: 0.5;
        distance_travelled <- distance_travelled + (before distance_to location);
        action_area <- circle(0.5);
    }

    /* Body: yellow circle of radius 0.4 with a black border (smaller than the reach circle) */
    aspect default {
        draw circle(0.4) color: color border: #black;
    }

    /* Action neighbourhood: goldenrod circle of radius 0.5 */
    aspect action_neighbourhood {
        if (action_area != nil) {
            draw action_area color: #goldenrod;
        }
    }
}

/* Main experiment: bodies and action neighbourhoods as separate layers */
experiment on_the_move type: gui {
    output {
        /* Bodies first, then the see-through neighbourhoods on top */
        display "Action Neighbourhoods" {
            species cow aspect: default;
            species cow aspect: action_neighbourhood transparency: 0.5;
            species sheep aspect: default;
            species sheep aspect: action_neighbourhood transparency: 0.5;
            species goat aspect: default;
            species goat aspect: action_neighbourhood transparency: 0.5;
        }
    }
}
