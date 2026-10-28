# Savannah model: specification

A coupled agent-based (ABM) and cellular automaton (CA) model of the African savannah.
Lions and zebras wander over a grassland grid. A lion kills any zebra it runs into, and the grass grows linearly.

- **Platform:** GAMA 2025-06 (GAML)
- **Model file:** name to be decided when the model is written

## 1. Environment

| Item | Value |
|---|---|
| World size | GAMA default (100 x 100 m) |
| Grid | 50 x 50 cells, each 2 x 2 m |

## 2. Agents (`species`)

### 2.1 Lion

| Item | Specification |
|---|---|
| Number at start | 20 |
| Start position | Random (GAMA default for `create`) |
| Movement | Walks around randomly each step (`moving` skill, `do wander`) |
| Predation | Each step, every zebra within **3 m** of the lion (the lion's size) is killed with the built-in `die` action, e.g. `ask zebra at_distance 3 { do die; }` |
| Aspect | Orange circle of size 3: `draw circle(3) color: #orange` (the argument of `circle` is the radius) |

### 2.2 Zebra

| Item | Specification |
|---|---|
| Number at start | 20 |
| Start position | Random (GAMA default for `create`) |
| Movement | Walks around randomly each step (`moving` skill, `do wander`) |
| Death | Only when a lion runs into it (see 2.1) |
| Aspect | Grey triangle of size 2: `draw triangle(2) color: #grey` (the argument of `triangle` is the side length) |

## 3. Cells (`grid`)

| Item | Specification |
|---|---|
| Placement in the file | The `grid {}` section comes **after** the `species {}` sections and **before** the `experiment {}` section |
| Attribute | `biomass` (kg) |
| Initial value | Random value between 0 and 10 kg per cell, e.g. `rnd(10.0)` |
| Growth | Linear: add 0.1 kg to `biomass` every time step, up to the 10 kg cap |
| Upper limit | 10 kg per cell. Growth stops at the cap. |
| Visualisation | A green shade that follows biomass: lighter green for less, darker green for more. The scale runs from 0 to 10 kg, and cells above 10 kg show the darkest green. |

## 4. Experiment

- One GUI experiment with one display.
- The display draws the grassland grid first, then the zebras and lions on top of it.

## 5. File layout

The `.gaml` file is laid out in this order:

1. `global` block: creates 20 lions and 20 zebras
2. `species lion`
3. `species zebra`
4. `grid` for the grass cells
5. `experiment`

Every species, attribute and reflex gets a comment (see `AGENTS.md`).

## 6. Decisions taken where the task was silent

| Question | Decision |
|---|---|
| Grid size | 50 x 50 cells |
| What "runs into" means | Zebra within 3 m (the lion's size) of the lion |
| Maximum biomass | 10 kg per cell; the colour scale runs from 0 to 10 kg |

## 7. Not specified by the task (out of scope unless requested)

- Zebras eating grass: added as Extension 1, see section 8.
- Reproduction. Lion energy and lions dying were added as Extension 2, see section 9.
- Movement speed. The `moving` skill's default is used. Its value is not stated on the GAMA wiki page checked.
- A stop condition. The simulation runs until it is stopped by hand.
- Charts or output files. Monitors for the number of lions and zebras were added as Extension 2, see section 9.
- The order in which lions, zebras and cells act within a step.

## 8. Extension 1: zebras eat grass

Added after v0.1. Everything else in this spec stays the same.

| Item | Specification |
|---|---|
| Who eats | Every living zebra |
| When | Every step, after the zebra has moved |
| Which cell | The grass cell the zebra stands on (the cell under its location) |
| Amount | Reduces that cell's `biomass` by 1 kg |
| Lower limit | Biomass never goes below 0 kg; a cell with less than 1 kg drops to 0 |
| Several zebras on one cell | Each zebra removes 1 kg in turn, still never below 0 |
| Grass growth and colour | Unchanged: the cell still gains 0.1 kg per step, up to the 10 kg cap, and its colour still follows biomass |

## 9. Extension 2: lion energy

Added after Extension 1. Everything else in this spec stays the same.

| Item | Specification |
|---|---|
| Attribute | Each lion has a `float` attribute `energy` |
| Starting value | 10 |
| Moving cost | Each step, moving costs 0.1 energy |
| Rounding | Energy is rounded to 1 decimal after each move, so 100 moves use exactly 10 energy |
| Eating gain | Each zebra the lion kills adds 5 energy (two zebras killed in one step add 10) |
| Upper limit | None (the extension gives no maximum) |
| Death | A lion whose energy is 0 or below dies |
| Order within a lion's step | Move (-0.1), then hunt (+5 per zebra killed), then die if energy is 0 or below. A lion that reaches 0 by moving but kills a zebra in the same step survives. |
| Monitors | Two monitors in the experiment: "Lions" shows the number of lions and "Zebras" the number of zebras |
