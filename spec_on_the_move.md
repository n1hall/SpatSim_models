# On the move: specification

A GAMA model in which three kinds of animals move in three different ways: cows do a correlated random walk, sheep all walk south, and goats walk towards the origin. Each agent's action neighbourhood (where it can get to in one step) is drawn around it.

- **Platform:** GAMA 2025-06 (GAML). The behaviours below were checked headless with GAMA 2025.6.4.
- **Model file:** `models/on_the_move.gaml` (to be written later; this spec comes first)

## 1. Environment

| Item | Value |
|---|---|
| World size | GAMA default: 100 x 100 m |
| Time step | GAMA default: 1 s, so a speed in m/s is also the distance in metres covered per step |
| Coordinates | The origin {0, 0} is the top-left (north-west) corner. x grows to the east, y grows to the south (downwards on screen). |
| Headings | In degrees, measured clockwise: 0 = east, **90 = south**, 180 = west, 270 = north |

The GAMA docs page for the `moving` skill only says that `heading` is "the absolute heading of the agent in degrees", so the direction of 90 was checked by a test. `do move heading: 90.0 speed: 1.0;` moved an agent from {50, 50} to {50, 51}, and a point at y = 90 was drawn near the bottom of the display. So heading 90 is south.

## 2. Agents (`species`)

### 2.1 Cows

| Item | Specification |
|---|---|
| Number at start | 5 |
| Colour | Brown (`#brown`) |
| Start | Random location and random heading |
| Movement | Correlated random walk: every step, `do wander speed: 2.0 amplitude: 180.0;` |
| Speed | 2 m per step |
| Turning angle | At most 90° to the left or to the right of the current heading per step (except at the world edge, see section 4) |

**How `amplitude` maps to "max 90° turning angle":** the GAMA docs for the `moving` skill say that for `wander` "the new heading is chosen in the range (heading - amplitude/2, heading+amplitude/2)". A cow that may turn up to 90° either way therefore needs `amplitude: 180.0` (180 / 2 = 90). This was confirmed by test: over 2,000 steps, `amplitude: 180.0` gave a largest turn of 89.95°, while `amplitude: 90.0` gave only 44.98° (a 90° window, ±45°). Every `wander` step was exactly 2 m long.

### 2.2 Sheep

| Item | Specification |
|---|---|
| Number at start | 3 |
| Colour | Black (`#black`) |
| Start | Random location |
| Movement | All sheep move due south every step: `do move heading: 90.0 speed: 1.0;` |
| Speed | 1 m per step |
| Tested | In a 120-step headless test of the model, each sheep's x stayed the same and its y grew by exactly 1 per step until the next step would have left the world; it then stayed put (at y = 99.69, 99.82 and 99.92). In the display snapshots the sheep moved down, which is south: their average pixel row went from 225 (step 0) to 335 (step 30), 431 (step 60) and 497 (step 90, the bottom of the 500-pixel-high image). |

### 2.3 Goats

| Item | Specification |
|---|---|
| Number at start | 2 |
| Colour | Yellow (`#yellow`) |
| Start | Random location |
| Movement | Every step, walk straight towards the origin: `do goto target: {0.0, 0.0} speed: 0.5;` |
| Speed | 0.5 m per step |
| Arrival | A goat stops at {0, 0} and stays there. In a test, a goat starting at {1, 1} reached exactly {0, 0} after 3 steps and did not move after that. |

### 2.4 Aspect

Every agent is drawn as a filled circle of radius 0.3 in its species' colour, on top of its action neighbourhood (section 3). The small radius keeps the neighbourhood circles visible: a goat's 0.5 m circle would be hidden under a body of radius 1.

## 3. Action neighbourhood

Each agent's action neighbourhood shows how far it can get in one step. Each species' aspect draws it around the agent first, then draws the agent on top:

| Species | Drawn as |
|---|---|
| All | An unfilled (wireframe) circle in the agent's colour, centred on the agent, with radius equal to its speed: 2 m for cows, 1 m for sheep, 0.5 m for goats |
| Cow (in addition) | A see-through brown slice of the same circle (radius 2), covering every heading from 90° left to 90° right of the cow's current heading: the directions its next `wander` step can take. The cow ends up on the curved edge of this slice. |

The circle shows the distance covered in one step, not the exact reach: a sheep can only reach the point 1 m south of it, and a goat only the point 0.5 m towards {0, 0} (or {0, 0} itself once it is closer than that). The drawing also ignores the world edge, so near the edge part of it may lie where the agent cannot go (see section 4).

## 4. World edge

**Decision: agents stay inside the world (GAMA's default behaviour; no wrap-around).**

A move that would take an agent outside the world does not happen. Tested behaviour:

| Species | What happens at the edge |
|---|---|
| Sheep | They stop where their next 1 m step would end outside the world, and stay there. A sheep starting at y = 97.5 moved to 98.5, then 99.5, and then stayed at 99.5. Sheep end up lined up along the south edge, up to 1 m short of it. |
| Cows | `wander` keeps them inside. Over 2,000 steps, a cow starting at the east edge stayed within x 0.02–99.97 and y 0.04–98.2; 65 of its steps were shorter than 2 m because of the edge. On those edge steps `wander` can also turn a cow by more than 90°: in a 500-step test with 5 cows, all 88 turns larger than 90° (up to 180°) happened within 2 m of an edge, each on a shortened step, while every turn away from the edges was at most 89.95°. This is accepted. |
| Goats | Their target {0, 0} is the top-left corner, which is inside the world, so they never cross an edge. They stop at the corner. |

## 5. Experiment

- One GUI experiment with one display.
- The display has one layer per species: cows, then sheep, then goats. In each layer, the species' aspect draws every agent's action neighbourhood first and the agent on top of it.

## 6. File layout

The `.gaml` file is laid out in this order:

1. `global` block: creates 5 cows, 3 sheep and 2 goats
2. `species cow`
3. `species sheep`
4. `species goat`
5. `experiment`

Every species, attribute and reflex gets a comment (see `AGENTS.md`).

## 7. Decisions taken where the assignment was silent

| Question | Decision |
|---|---|
| What "max 90° turning angle" means | Up to 90° left or right per step (`amplitude: 180.0`) |
| How to draw the action neighbourhood | An unfilled circle of radius = speed for every agent, plus a see-through ±90° slice for cows (section 3) |
| World edge | Agents stay inside the world; no wrap-around (section 4) |
| World size and time step | GAMA defaults: 100 x 100 m, 1 s per step |
| Start positions | Random; cows also start with a random heading |
| Agent shape | Filled circles of radius 0.3, so the neighbourhood circles stay visible |

## 8. Not specified by the assignment (out of scope unless requested)

- Any interaction between agents (collisions, avoiding each other, eating).
- A stop condition. The simulation runs until it is stopped by hand.
- Charts, monitors or output files.

## Source

GAMA docs, built-in skills page, `moving` skill (`heading`, `wander` and its `amplitude` facet, `move`, `goto`): https://gama-platform.org/wiki/BuiltInSkills
