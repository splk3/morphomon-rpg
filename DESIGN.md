# Morphomon RPG — Design & Architecture

A traditional top-down, turn-based RPG built in **Godot 4.5**, in the spirit of
the Game Boy / Game Boy Color / Game Boy Advance Pokémon games.

You play a boy or girl who receives a **Morphomon** robot as a gift from mom on
the first day of school. Using a scanner, you capture the *essences* of wild
creatures and store them in the Morphomon, which can then **transform** into any
stored creature to battle. Out of battle the robot collapses into a pocket cube.

## Running the game

1. Install [Godot 4.5.x](https://godotengine.org/download) (standard, non‑.NET build).
2. Open the project: `godot --editor` from this folder, or import `project.godot`.
3. Press **Play** (F5). The main scene is `scenes/ui/TitleScreen.tscn`.

### Controls

| Action   | Keyboard            | Gamepad (Xbox / PlayStation) |
|----------|---------------------|------------------------------|
| Move     | WASD / Arrows       | D‑Pad / Left Stick           |
| Interact / Confirm | E / Enter / Space | A / Cross            |
| Cancel   | Esc / Backspace     | B / Circle                   |
| Run      | Shift               | X / Square                   |
| Menu     | Tab                 | Start / Y / Triangle         |
| Scan     | Q                   | Right Shoulder               |

Controllers are read through Godot's SDL mapping, so a single binding works for
both Xbox and PlayStation pads. Menus also use Godot's built‑in `ui_*` actions.
Bindings can be customized in‑game via **Settings → Customize Controls**
(`scenes/ui/RemapMenu.tscn`), and gamepad rumble fires on combat hits/damage when
`Settings.gamepad_vibration` is enabled.

## Project layout

```
project.godot            Engine config: autoloads, input, display, renderer
autoload/                Global singletons (always loaded)
  InputSetup.gd            Registers keyboard + gamepad actions at runtime
  GameData.gd              Elements, type chart, moves, creatures, towns
  AudioManager.gd          Procedural chiptune music + SFX (no binary assets)
  Settings.gd              Audio/graphics/controls + persistence + display revert
  SaveManager.gd           Three JSON save slots under user://saves
  GameState.gd             Active run: save data, play time, scan/starter logic
scripts/resources/       Data classes (Resource / RefCounted)
  ElementType, CreatureSpecies, MoveData, Essence, Morphomon, TownData, SaveData
  StatusEffect             Status-ailment definitions (poison/burn/paralyze/sleep/freeze)
scripts/                 Shared helpers
  UI.gd                    Colorful themed widgets built in code
  Routes.gd                Scene path constants (UI, battle, all town/route maps)
  Combatant.gd             Battle participant + damage math + status handling
  PlaceholderSprite.gd     Code-drawn animated cartoony figures
data/
  CreatureCatalog.gd       45 creature definitions (5 per element)
scenes/ui/               Title, save select, settings, control remap, character
                         creation, starter choice, dialogue bubble, overworld menu,
                         Morphopedia screen, intro cutscene
scenes/world/            Overworld + terrain renderer
  maps/                    TileMapWorld base + 9 town maps and connecting routes
scenes/battle/           Turn-based battle (status effects, PP, rumble)
tests/                   Headless validation (run_tests + smoke_test)
```

AGENTS.md and .github/agents/ define a roster of Copilot custom agents (with
areas of responsibility, file ownership, and default models) used to parallelize
feature work safely; see AGENTS.md for the dispatch rules and validation commands.

## Core mechanics

- **Elements** — 8 true elements (fire, water, electric, earth, plant, light,
  dark, astro) plus the element‑less *normal* type. A simple effectiveness chart
  lives in `GameData._build_type_chart()`.
- **Towns / schools** — 9 towns, each with a school specializing in one element
  (the hometown school teaches *normal*). Defeat each headmaster to earn a badge
  (`SaveData.defeated_headmasters`). The overworld is built from discrete
  `TileMapWorld` maps under `scenes/world/maps/` — 9 towns plus connecting routes
  forming a bidirectional warp chain
  (Sprout ⇄ Ember ⇄ Tide ⇄ Volt ⇄ Bedrock ⇄ Verdant ⇄ Lumen ⇄ Umbra ⇄ Nova).
  Each route carries an element‑themed wild encounter table.
- **Scanning** — wild creatures can be scanned mid‑battle. Success scales with how
  weakened the creature is, the level gap, and the species' `scan_resistance`
  (`GameState.attempt_scan`). It is never guaranteed.
- **Morphomon storage** — up to **6** loaded essences; extras overflow to the
  **cloud** and can be swapped at any town's Morphomon Club
  (`Morphomon.MAX_ESSENCES`, `OverworldMenu` cloud storage).
- **Battles** — transform between loaded essences, attack with element moves,
  scan (wild only) or run (wild only). Essences gain XP and level up. Moves consume
  **PP** (`Essence` per‑move PP, `MoveData.max_pp`) and can inflict **status effects**
  (poison/burn deal end‑of‑turn damage; paralyze/sleep/freeze can skip a turn) via
  `GameData.statuses` and `Combatant.apply_status/tick_status/should_skip_turn`.
- **Story flags & resume** — progression/cutscene state persists through
  `GameState` story flags (e.g. the flag‑gated intro cutscene), and the player's last
  overworld map/cell is saved (`SaveData.world_position`).
- **Settings** — changes apply on **Apply**. Display changes (window mode /
  resolution / vsync) start a **10‑second confirmation**; if not confirmed they
  auto‑revert, so an unusable mode can't soft‑lock the player
  (`Settings.REVERT_SECONDS`, `SettingsMenu`). Controls can be remapped in‑game
  (`RemapMenu`), and **autosave** (`Settings.autosave_enabled`, `GameState.autosave`)
  checkpoints after key events such as choosing a starter or a successful scan.

## Placeholder assets

To keep the repository free of binary art/audio, visuals are **code‑drawn**
(`PlaceholderSprite`, `TerrainGrid`) and music/SFX are **procedurally
synthesized** chiptune (`AudioManager`). These are intended to be replaced by
hand‑drawn sprite sheets and composed tracks (see next steps).

## Tests

```
godot --headless tests/TestRunner.tscn   # 64 logic/content/contract checks
godot --headless tests/SmokeTest.tscn    # instantiates every scene + compiles every script
```

Both exit non‑zero on failure, suitable for CI.

## Prioritized next steps

Status legend: ✅ done · 🟡 partial · ⬜ not started.

1. ⬜ **Art & audio pass** — replace procedural placeholders with cartoony sprite
   sheets (idle/walk/attack frames per creature & character) and composed
   happy town/battle themes. The `PlaceholderSprite`/`AudioManager` seams are
   designed to be swapped out. *(Deliberately deferred — binary asset work.)*
2. ✅ **World content** — all 9 element‑themed town maps plus connecting routes are
   built on the `TileMapWorld` base (`scenes/world/maps/`) with a bidirectional warp
   chain and per‑route encounter tables. *(Layouts are functional prototypes;
   richer per‑town architecture/NPCs can still be layered on.)*
3. 🟡 **Story & cutscenes** — the flag‑gated "chosen to represent your school" intro
   cutscene ships (`scenes/ui/cutscenes/IntroCutscene`). Per‑town headmaster arcs
   are the remaining narrative work (seam: the intro's data‑driven dialogue pattern
   + `GameState` story flags).
4. 🟡 **Battle depth** — status effects, PP/energy, and gamepad rumble on hits are
   implemented in `Combatant`/`Battle`. Remaining: more than two moves per species,
   catch animations, and full balancing of the stat/scan/status formulas.
5. ✅ **Control remapping UI** — `RemapMenu` captures and displays bindings into
   `Settings.custom_bindings`/`apply_bindings()`, reachable from the Settings menu;
   gamepad rumble uses `Settings.gamepad_vibration` (`Settings.rumble`).
6. ✅ **Morphopedia screen** — `scenes/ui/MorphopediaMenu` provides a discovery‑gated
   grid with detail pages (art, lore, base stats, scan difficulty, where‑found).
7. 🟡 **Quality of life** — autosave is implemented (`GameState.autosave`,
   `Settings.autosave_enabled`). Remaining: text‑speed setting, accessibility
   options, and a proper pause overlay.

### Remaining work (tracked seams)

- Per‑town headmaster arcs/cutscenes (narrative).
- Full move/status/balance data, multi‑move per species, scan rebalance — concentrated
  in `GameData`/`CreatureCatalog`, best done single‑owner to avoid merge contention.
- Extra rumble hooks (scan/capture/encounter events) via `Settings.rumble`.
- Text‑speed setting + `DialogueBubble` wiring, accessibility options, pause overlay.
- Art & audio asset pipeline (step 1).

## Open questions / clarifications

- Exact element effectiveness matrix (the current chart is a reasonable default).
- Per‑town map architecture/NPC density beyond the current functional layouts
  (overworld connectivity is now established as a linear warp chain).
- Whether scanning consumes a resource (scanner energy) or is unlimited.
- Status/PP/scan balance tuning once the full move set lands.
- Desired art resolution/style spec for the sprite pipeline.
