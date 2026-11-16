# On the move: specification

A GAMA model in which three kinds of animals move in three different ways: cows do a correlated random walk, sheep all walk south, and goats walk towards the origin. Each agent keeps its action neighbourhood (where it can get to in one step) in a geometry attribute, and the display draws it as a see-through layer.

- **Platform:** GAMA 2025-06 (GAML). The behaviours below were checked headless with GAMA 2025.6.4.
- **Model file:** `models/on_the_move.gaml`

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
| Colour | Brown, kept in the attribute `rgb color <- #brown;` |
| Start | Random location and random heading |
| Movement | Correlated random walk: every step, `do wander amplitude: 90.0 speed: 2.0;` |
| Speed | 2 m per step |
| Turning angle | The new heading lies within a 90° range centred on the current heading: at most 45° to the left or to the right per step (except at the world edge, see section 4) |

**How `amplitude` maps to "max 90° turning angle":** the GAMA docs for the `moving` skill say that for `wander` "the new heading is chosen in the range (heading - amplitude/2, heading+amplitude/2)". The model reads "max 90° turning angle" as a 90° range of possible new headings, so it uses `amplitude: 90.0`, which allows turns of up to 45° either way (90 / 2 = 45). This was confirmed by test: over 2,000 steps, `amplitude: 90.0` gave a largest turn of 44.98°; in a 500-step test of this model, every turn away from the edges was at most 44.98°. Every `wander` step away from the edges was exactly 2 m long. (Allowing up to 90° either way would need `amplitude: 180.0`, which gave a largest turn of 89.95°.)

### 2.2 Sheep

| Item | Specification |
|---|---|
| Number at start | 3 |
| Colour | Black, kept in the attribute `rgb color <- #black;` |
| Start | Random location |
| Movement | All sheep move due south every step: `heading <- 90.0;` then `do move speed: 1.0;` |
| Speed | 1 m per step |
| Tested | In a 120-step headless test of an earlier version of the model (which moved with `do move heading: 90.0 speed: 1.0;`, the same movement), each sheep's x stayed the same and its y grew by exactly 1 per step until the next step would have left the world; it then stayed put (at y = 99.69, 99.82 and 99.92). In the display snapshots the sheep moved down, which is south: their average pixel row went from 225 (step 0) to 335 (step 30), 431 (step 60) and 497 (step 90, the bottom of the 500-pixel-high image). |

### 2.3 Goats

| Item | Specification |
|---|---|
| Number at start | 2 |
| Colour | Yellow, kept in the attribute `rgb color <- #yellow;` |
| Start | Random location |
| Movement | Every step, walk straight towards the origin: `do goto target: {0, 0} speed: 0.5;` |
| Speed | 0.5 m per step |
| Arrival | A goat stops at {0, 0} and stays there. In a test, a goat starting at {1, 1} reached exactly {0, 0} after 3 steps and did not move after that. |

### 2.4 Aspect

Each species has two aspects. The `default` aspect draws the agent's body as a filled circle in its colour:

| Species | Body |
|---|---|
| Cow | Brown circle of radius 1.5 |
| Sheep | Black circle of radius 0.6 |
| Goat | Yellow circle of radius 0.4 with a black border |

The `action_neighbourhood` aspect draws the action neighbourhood (section 3).

## 3. Action neighbourhood

Each agent stores its action neighbourhood in the attribute `geometry action_area`. The `move` reflex recomputes it right after the agent has moved, so it shows where the agent can get to in its next step:

| Species | `action_area` | Drawn by the `action_neighbourhood` aspect as |
|---|---|---|
| Cow | `cone(heading - 45, heading + 45) inter circle(2.0)`: the 90° sector in front of the cow (45° either side of its heading), cut to radius 2 = speed. Also set when each cow is created, so it exists from cycle 0. | A see-through circle of radius 2 (brown at alpha 0.2, with a brown border), and the sector inside it filled in brown |
| Sheep | `circle(1.0)`: a circle of radius 1 = speed around the sheep | A grey (`#gray`) filled circle |
| Goat | `circle(0.5)`: a circle of radius 0.5 = speed around the goat | A goldenrod (`#goldenrod`) filled circle |

Sheep and goats only get an `action_area` after their first move, so nothing is drawn for them before that; the aspect skips agents whose `action_area` is still `nil`. The neighbourhood layers are drawn at 50 % transparency on top of the bodies (section 5).

The cow sector covers exactly the headings `wander` can choose next. The sheep and goat circles show the distance covered in one step, not the exact reach: a sheep can only reach the point 1 m south of it, and a goat only the point 0.5 m towards {0, 0} (or {0, 0} itself once it is closer than that). None of the shapes take the world edge into account, so near the edge part of them may lie where the agent cannot go (see section 4).

## 4. World edge

**Decision: agents stay inside the world (GAMA's default behaviour; no wrap-around).**

A move that would take an agent outside the world does not happen. Tested behaviour:

| Species | What happens at the edge |
|---|---|
| Sheep | They stop where their next 1 m step would end outside the world, and stay there. A sheep starting at y = 97.5 moved to 98.5, then 99.5, and then stayed at 99.5. Sheep end up lined up along the south edge, up to 1 m short of it. |
| Cows | `wander` keeps them inside. Over 2,000 steps, a cow starting at the east edge stayed within x 0.02–99.97 and y 0.04–98.2; 65 of its steps were shorter than 2 m because of the edge. On those edge steps `wander` can also turn a cow by more than its amplitude allows: in a 500-step test of this model (amplitude 90) with 5 cows, all 70 turns larger than 45° (up to 179°) happened within 2 m of an edge, each on a shortened step, while every turn away from the edges was at most 44.98°. This is accepted. |
| Goats | Their target {0, 0} is the top-left corner, which is inside the world, so they never cross an edge. They stop at the corner. |

## 5. Experiment

- One GUI experiment, `on_the_move`, with the map display "Action Neighbourhoods", plus the verification monitors and chart displays of section 9.
- The display has two layers per species, in this order: cow bodies (`default`), cow neighbourhoods (`action_neighbourhood`, `transparency: 0.5`), then the same two layers for sheep and then for goats. So each species' see-through neighbourhoods are drawn on top of its bodies.

## 6. File layout

The `.gaml` file is laid out in this order:

1. `global` block: creates 5 cows (each with its first `action_area`), 3 sheep and 2 goats
2. `species cow`
3. `species sheep`
4. `species goat`
5. `experiment`

Every species, attribute and reflex gets a comment (see `AGENTS.md`).

## 7. Decisions taken where the assignment was silent

| Question | Decision |
|---|---|
| What "max 90° turning angle" means | A 90° range of new headings: up to 45° left or right per step (`amplitude: 90.0`) |
| How to draw the action neighbourhood | Stored in `action_area`: a ±45° sector of radius 2 for cows, circles of radius = speed for sheep and goats; drawn as separate see-through layers above the bodies (section 3) |
| World edge | Agents stay inside the world; no wrap-around (section 4) |
| World size and time step | GAMA defaults: 100 x 100 m, 1 s per step |
| Start positions | Random; cows also start with a random heading |
| Agent shape | Filled circles: radius 1.5 for cows, 0.6 for sheep, 0.4 for goats (with a black border) |

## 8. Not specified by the assignment (out of scope unless requested)

- Any interaction between agents (collisions, avoiding each other, eating).
- A stop condition. The simulation runs until it is stopped by hand.
- Charts, monitors or output files: added as a verification dashboard, see section 9.

## 9. Verification dashboard

Added to check the movement rules while the model runs. Nothing here changes how the agents move.

### 9.1 Recorded values

| Name | Where | Meaning |
|---|---|---|
| `distance_travelled` | `float` attribute of every cow, sheep and goat, starting at 0 | In its `move` reflex, each agent adds the distance between its location before and after the move. Shortened or cancelled moves at the world edge therefore count as they actually happened. |
| `turns` | Global `list<float>`, starting empty | In its `move` reflex, every cow adds its heading change for that step: heading after `wander` minus heading before, brought into the range −180° to 180° (adding or subtracting 360° when needed). The list grows by 5 values per cycle. |
| `sheep_at_edge` | Global `int` | The number of sheep within 1 m of the south edge: `location.y >= world.shape.height - 1.0` |
| `goats_at_origin` | Global `int` | The number of goats within 0.5 m of the origin: `location distance_to {0, 0} < 0.5`. A goat therefore counts from the step before it reaches {0, 0}. |

The two counters are recomputed by a global reflex every cycle. Global reflexes run before the agents move, so the counters describe the positions after the previous step.

### 9.2 Monitors and charts

| Output | Shows | What it should look like if the rules work |
|---|---|---|
| Monitor "Sheep at south edge" | `sheep_at_edge` | Rises to 3 within about 100 cycles and stays there |
| Monitor "Goats at origin" | `goats_at_origin` | Rises to 2 and stays there |
| Series chart "Goats: mean distance travelled" | One line: the mean of `distance_travelled` over all goats, per cycle | Rises by 0.5 per cycle while both goats walk, more slowly once one has arrived, and stays flat once both are at {0, 0} |
| Scatter chart "Sheep vs cows" | One point per cycle: x = mean `distance_travelled` of the sheep, y = mean `distance_travelled` of the cows | Points on the line y = 2x while no animal is held back by an edge; the points bend upwards once sheep stop at the south edge |
| Histogram "Cow turns" | `turns` in 5° bins from −180° to 180° (72 bins), e.g. with `distribution_of(turns, 72, -180.0, 180.0)` | About equally full bins between −45° and 45°, and only a few values outside that range, from steps at the world edge (section 4) |

The monitors appear in GAMA's monitor view. Each chart gets its own display: "Goats mean distance" (no colon, which Windows can't use in snapshot file names), "Sheep vs cows" and "Cow turns". `layout #split;` shows the "Action Neighbourhoods" map and the three chart displays side by side. The histogram uses `datalist` with the "legend" and "values" of `distribution_of(turns, 72, -180, 180)`. Because `distribution_of` returns an empty map for an empty list, the legend is taken from `distribution_of([0.0], 72, -180, 180)` (the bin labels never change), and the values are 72 zeros while `turns` is still empty.

### 9.3 CSV output

All files go to the `results/` folder in the project root, which git already ignores. From the model file they are `../results/...`.

| File | When | Contents |
|---|---|---|
| `results/on_the_move.csv` | One row every cycle | cycle, `sheep_at_edge`, `goats_at_origin`, and the mean `distance_travelled` of the cows, the sheep and the goats |
| `results/agents_end.csv` | Once, when the run pauses | One row per agent: species, name, `distance_travelled` |
| `results/cow_turns.csv` | Once, when the run pauses | The `turns` list, one heading change per row |

### 9.4 Pause

A global reflex pauses the simulation (`do pause;`) when `sheep_at_edge = 3` and `goats_at_origin = 2`, right after writing `agents_end.csv` and `cow_turns.csv`. Sheep reach the south edge within about 100 cycles. A goat needs at most about 283 cycles to reach {0, 0} from the farthest corner (141 m at 0.5 m per step), so every run pauses within about 285 cycles.

## Source

GAMA docs, built-in skills page, `moving` skill (`heading`, `wander` and its `amplitude` facet, `move`, `goto`): https://gama-platform.org/wiki/BuiltInSkills
