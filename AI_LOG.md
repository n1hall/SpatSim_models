AI log – Savannah with my agent (Claude Code, manual permission mode, rules in AGENTS.md)
1. SPEC.md written first and committed; the agent drafted the file from my dictated content.
2. Features 1–4 (lions, zebras, hunt rule, grass grid): one prompt each, referring to SPEC.md. All ran in GAMA on the first try; nothing rejected or corrected. Tagged v0.1.
3. Comparison with my hand-written model: no semantic error in the agent's code; its colour scale and comments were better, mine deviated from the spec's colour direction.
4. Extension 1 (zebras eat 1 kg/step from their cell): rule looked broken; a temporary console check I asked for showed grass growing by 4600 kg per 20 cycles instead of 5000, so it worked but was invisible above the 10 kg colour scale. Tried a 0–30 kg colour scale and rejected it; chose a 10 kg biomass cap instead.
5. Extension 2 (lion energy 10, −0.5/step, +5/kill): all lions starved by cycle 30–40 before hunting. Corrected the cost to 0.1/step (lions now last ~200–250 cycles); accepted the agent's rounding fix so energy hits exactly 0. Monitors added, later removed. Tagged v0.2.
6. AI_LOG.md itself: the agent's first entry logged git commands; I had it rewritten to this format.
