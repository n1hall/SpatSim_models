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

Every agent is drawn as a circle of radius 1 in its species' colour.

## 3. Action neighbourhood

Each agent's action neighbourhood is the area it can get to in one step. It is drawn see-through in the agent's colour, underneath the agents, for the agent's next step:

| Species | Drawn as |
|---|---|
| Cow | A slice of a circle with radius 2, centred on the cow, covering every heading from 90° left to 90° right of its current heading (a half-disc in front of the cow). Because `wander` always moves exactly 2 m, the cow will end up somewhere on the curved edge of this slice. |
| Sheep | A line 1 m long from the sheep straight south, to the one point it can reach |
| Goat | A line from the goat towards {0, 0}, 0.5 m long or shorter if the goat is closer than 0.5 m to the origin. Nothing is drawn once the goat is at {0, 0}. |

The neighbourhood shows the one-step reach without taking the world edge into account. Near the edge, part of it may lie where the agent cannot actually go (see section 4).

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
- The display draws the action neighbourhoods first, then the cows, sheep and goats on top.

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
| How to draw the action neighbourhood | The exact one-step reach: a half-disc slice for cows, short lines for sheep and goats (section 3) |
| World edge | Agents stay inside the world; no wrap-around (section 4) |
| World size and time step | GAMA defaults: 100 x 100 m, 1 s per step |
| Start positions | Random; cows also start with a random heading |
| Agent shape | Circles of radius 1 |

## 8. Not specified by the assignment (out of scope unless requested)

- Any interaction between agents (collisions, avoiding each other, eating).
- A stop condition. The simulation runs until it is stopped by hand.
- Charts, monitors or output files.

## Source

GAMA docs, built-in skills page, `moving` skill (`heading`, `wander` and its `amplitude` facet, `move`, `goto`): https://gama-platform.org/wiki/BuiltInSkills
