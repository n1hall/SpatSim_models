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

    /* Every cycle, writes the counters and each species' mean distance travelled to ../results/on_the_move.csv; the file starts fresh with a header row at cycle 0 */
    reflex save_cycle {
        if cycle = 0 {
            save ["cycle", "sheep_at_edge", "goats_at_origin", "mean_cow_distance", "mean_sheep_distance", "mean_goat_distance"] to: "../results/on_the_move.csv" format: "csv" rewrite: true header: false;
        }
        save [cycle, sheep_at_edge, goats_at_origin, mean(cow collect each.distance_travelled), mean(sheep collect each.distance_travelled), mean(goat collect each.distance_travelled)] to: "../results/on_the_move.csv" format: "csv" rewrite: false header: false;
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

/* Main experiment: bodies and action neighbourhoods as separate layers, plus verification monitors and charts */
experiment on_the_move type: gui {
    /* Becomes true once the end-of-run files are saved, so save_and_pause fires only once */
    bool finished <- false;

    /* Fires once, when all 3 sheep are at the south edge and both goats at the origin: appends a summary row, writes fresh agents_end.csv and cow_turns.csv, then pauses */
    reflex save_and_pause when: !finished and simulation.sheep_at_edge = 3 and simulation.goats_at_origin = 2 {
        finished <- true;
        ask simulation {
            if !file_exists("../results/summary.csv") {
                save ["cycle", "mean_cow_distance", "mean_sheep_distance", "mean_goat_distance"] to: "../results/summary.csv" format: "csv" rewrite: false header: false;
            }
            save [cycle, mean(cow collect each.distance_travelled), mean(sheep collect each.distance_travelled), mean(goat collect each.distance_travelled)] to: "../results/summary.csv" format: "csv" rewrite: false header: false;

            save ["name", "species", "x", "y", "distance_travelled"] to: "../results/agents_end.csv" format: "csv" rewrite: true header: false;
            ask cow { save [name, "cow", location.x, location.y, distance_travelled] to: "../results/agents_end.csv" format: "csv" rewrite: false header: false; }
            ask sheep { save [name, "sheep", location.x, location.y, distance_travelled] to: "../results/agents_end.csv" format: "csv" rewrite: false header: false; }
            ask goat { save [name, "goat", location.x, location.y, distance_travelled] to: "../results/agents_end.csv" format: "csv" rewrite: false header: false; }

            save ["turn"] to: "../results/cow_turns.csv" format: "csv" rewrite: true header: false;
            loop t over: turns {
                save [t] to: "../results/cow_turns.csv" format: "csv" rewrite: false header: false;
            }

            /* A plain "do pause;" in an experiment reflex does not compile in GAMA 2025.6.4; asking the simulation to pause does */
            do pause;
        }
    }

    output {
        /* Shows all displays side by side */
        layout #split;

        /* Number of sheep within 1 m of the south edge */
        monitor "Sheep at south edge" value: sheep_at_edge;
        /* Number of goats within 0.5 m of the origin */
        monitor "Goats at origin" value: goats_at_origin;

        /* Bodies first, then the see-through neighbourhoods on top */
        display "Action Neighbourhoods" {
            species cow aspect: default;
            species cow aspect: action_neighbourhood transparency: 0.5;
            species sheep aspect: default;
            species sheep aspect: action_neighbourhood transparency: 0.5;
            species goat aspect: default;
            species goat aspect: action_neighbourhood transparency: 0.5;
        }

        /* Mean distance travelled by the goats over time: should rise by 0.5 per step until they reach the origin */
        display "Goats mean distance" {
            chart "Goats: mean distance travelled" type: series {
                data "goats" value: mean(goat collect each.distance_travelled);
            }
        }

        /* One point per step: mean sheep distance (x) against mean cow distance (y); y = 2x while no animal is at an edge */
        display "Sheep vs cows" {
            chart "Sheep vs cows" type: scatter {
                data "sheep vs cows" value: [mean(sheep collect each.distance_travelled), mean(cow collect each.distance_travelled)];
            }
        }

        /* Cow heading changes in 5-degree bins from -180 to 180: should fill only -45 to 45, apart from edge steps; all bars stay at 0 while turns is still empty */
        display "Cow turns" {
            chart "Cow turns" type: histogram {
                datalist (distribution_of([0.0], 72, -180, 180) at "legend") value: (empty(turns) ? list_with(72, 0) : (distribution_of(turns, 72, -180, 180) at "values"));
            }
        }
    }
}
