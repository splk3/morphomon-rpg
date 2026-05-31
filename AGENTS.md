# Morphomon RPG — Agents Index

This repo uses a fleet of role-specialized Copilot custom agents (defined in
[`.github/agents/`](.github/agents/)) to build the game. This file is the index:
it maps disciplines to agents, declares **file ownership** to prevent collisions,
and states how work is assigned.

## Roster

| Agent                                                                    | Model               | Responsibility                                                                                                                 | When to use                                       |
| ------------------------------------------------------------------------ | ------------------- | ------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------- |
| [`godot-systems-engineer`](.github/agents/godot-systems-engineer.md)     | `claude-opus-4.8`   | Architecture/integration owner: battle logic, autoloads, save schema, story-flag model, rumble API, autosave, merge sequencing | Any shared-schema/API change or battle-depth work |
| [`godot-world-builder`](.github/agents/godot-world-builder.md)           | `claude-sonnet-4.6` | TileMapLayer towns, routes, warps, encounters, movement                                                                        | Building the 9 towns + routes (#2)                |
| [`godot-narrative-designer`](.github/agents/godot-narrative-designer.md) | `claude-sonnet-4.6` | Story, cutscenes, dialogue, headmaster arcs, text speed                                                                        | Intro + per-town story (#3)                       |
| [`godot-ui-engineer`](.github/agents/godot-ui-engineer.md)               | `claude-sonnet-4.6` | Remap UI, Morphopedia, pause overlay, settings/accessibility UI                                                                | UI for #5, #6, #7                                 |
| [`godot-content-designer`](.github/agents/godot-content-designer.md)     | `claude-haiku-4.5`  | Data tables: creatures, moves, status, balance, NPC text                                                                       | Populating content against stable schemas         |
| [`godot-qa-engineer`](.github/agents/godot-qa-engineer.md)               | `claude-sonnet-4.6` | Headless tests, contract tests, integration                                                                                    | Foundation contract tests + final integration     |

Model choice balances capability vs. cost: **Opus** for complex/shared logic,
**Sonnet** for standard implementation, **Haiku** for data/content authoring.

## File ownership (avoid parallel collisions)

| Path                                                                                           | Owner              | Notes                            |
| ---------------------------------------------------------------------------------------------- | ------------------ | -------------------------------- |
| `autoload/GameData.gd`, `autoload/GameState.gd`                                                | systems-engineer   | Others request changes           |
| `scripts/resources/SaveData.gd`, `Essence.gd`, `Morphomon.gd`                                  | systems-engineer   | Save schema + migration          |
| `scripts/Combatant.gd`, `scripts/resources/MoveData.gd`, `scenes/battle/Battle.gd`             | systems-engineer   | Battle logic/schema              |
| `autoload/SaveManager.gd`                                                                      | systems-engineer   | Autosave/persistence             |
| `scenes/world/*`, `Overworld.gd`, `TerrainGrid.gd`, world entries in `scripts/Routes.gd`       | world-builder      | After world schema is locked     |
| `scenes/ui/DialogueBubble.gd`, story/cutscene scripts                                          | narrative-designer | UI coordinates on text speed     |
| `autoload/Settings.gd`, `scenes/ui/SettingsMenu.gd`, Morphopedia/pause scenes, `scripts/UI.gd` | ui-engineer        | systems reviews persistence      |
| `data/CreatureCatalog.gd`, data tables                                                         | content-designer   | Data only; no runtime logic      |
| `tests/*`                                                                                      | qa-engineer        | Feature agents add focused tests |

If an agent needs a change outside its owned files, it **requests** the owner to
make it rather than editing directly.

## How work is assigned (contract-first, vertical-slice)

1. **Phase 1 — Contracts (systems-engineer):** lock save/world/story/battle
   schemas, settings keys, and the rumble API. QA writes contract tests.
2. **Phase 2 — Vertical slice (parallel):** one town+route, the intro cutscene,
   a status-effect battle slice, and a remap-UI scaffold — each against the
   locked contracts.
3. **Phase 3 — Breadth (parallel):** all towns/routes, headmaster arcs, full
   battle content/balance, Morphopedia.
4. **Phase 4 — QoL + integration:** autosave, pause/accessibility/text-speed UI,
   rumble hooks, final QA pass.

## Validation

```bash
godot --headless tests/TestRunner.tscn   # logic/content checks
godot --headless tests/SmokeTest.tscn    # instantiates every scene
```

Both exit non-zero on failure. Run autoload-dependent scripts as **scenes**
(a Node with the script), not via `--script`, so autoloads register first.

> Local Copilot CLI sessions: apply edits but do not auto-stage or commit changes.
