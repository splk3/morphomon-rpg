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
scripts/                 Shared helpers
  UI.gd                    Colorful themed widgets built in code
  Routes.gd                Scene path constants
  Combatant.gd             Battle participant + damage math
  PlaceholderSprite.gd     Code-drawn animated cartoony figures
data/
  CreatureCatalog.gd       45 creature definitions (5 per element)
scenes/ui/               Title, save select, settings, character creation,
                         starter choice, dialogue bubble, overworld menu
scenes/world/            Overworld + terrain renderer
scenes/battle/           Turn-based battle
tests/                   Headless validation (run_tests + smoke_test)
```

## Core mechanics

- **Elements** — 8 true elements (fire, water, electric, earth, plant, light,
  dark, astro) plus the element‑less *normal* type. A simple effectiveness chart
  lives in `GameData._build_type_chart()`.
- **Towns / schools** — 9 towns, each with a school specializing in one element
  (the hometown school teaches *normal*). Defeat each headmaster to earn a badge
  (`SaveData.defeated_headmasters`).
- **Scanning** — wild creatures can be scanned mid‑battle. Success scales with how
  weakened the creature is, the level gap, and the species' `scan_resistance`
  (`GameState.attempt_scan`). It is never guaranteed.
- **Morphomon storage** — up to **6** loaded essences; extras overflow to the
  **cloud** and can be swapped at any town's Morphomon Club
  (`Morphomon.MAX_ESSENCES`, `OverworldMenu` cloud storage).
- **Battles** — transform between loaded essences, attack with element moves,
  scan (wild only) or run (wild only). Essences gain XP and level up.
- **Settings** — changes apply on **Apply**. Display changes (window mode /
  resolution / vsync) start a **10‑second confirmation**; if not confirmed they
  auto‑revert, so an unusable mode can't soft‑lock the player
  (`Settings.REVERT_SECONDS`, `SettingsMenu`).

## Placeholder assets

To keep the repository free of binary art/audio, visuals are **code‑drawn**
(`PlaceholderSprite`, `TerrainGrid`) and music/SFX are **procedurally
synthesized** chiptune (`AudioManager`). These are intended to be replaced by
hand‑drawn sprite sheets and composed tracks (see next steps).

## Tests

```
godot --headless tests/TestRunner.tscn   # 38 logic/content checks
godot --headless tests/SmokeTest.tscn    # instantiates every scene
```

Both exit non‑zero on failure, suitable for CI.

## Prioritized next steps

1. **Art & audio pass** — replace procedural placeholders with cartoony sprite
   sheets (idle/walk/attack frames per creature & character) and composed
   happy town/battle themes. The `PlaceholderSprite`/`AudioManager` seams are
   designed to be swapped out.
2. **World content** — build the 9 distinct town maps and connecting routes
   themed by element (architecture, palette, NPC outfits) using `TileMapLayer`,
   instead of the single procedural sandbox map.
3. **Story & cutscenes** — script the "chosen to represent your school" intro and
   per‑town headmaster arcs using the existing `DialogueBubble`.
4. **Battle depth** — status effects, more than two moves per species, PP/energy,
   catch animations, and balancing of the stat/scan formulas.
5. **Control remapping UI** — `Settings.custom_bindings`/`apply_bindings()` already
   support remaps; add a UI to capture and display them, plus gamepad rumble via
   `Settings.gamepad_vibration`.
6. **Morphopedia screen** — richer entries (art, lore, stats, where‑found) beyond
   the current discovered list.
7. **Quality of life** — autosave, settings for text speed, accessibility options,
   and a proper pause overlay.

## Open questions / clarifications

- Exact element effectiveness matrix (the current chart is a reasonable default).
- Map size/scope per town and overworld connectivity.
- Whether scanning consumes a resource (scanner energy) or is unlimited.
- Desired art resolution/style spec for the sprite pipeline.
