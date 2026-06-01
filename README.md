# morphomon-rpg

Traditional top-down turn-based RPG based on the Morphomon scan-transform mechanics. Homage to classic Pokemon games.

Scan wild creatures, store their **essences**, and **transform** your Morphomon
robot into them to battle across nine elemental towns. Built with **Godot 4.5**.

## Quick start

1. Install [Godot 4.5.x](https://godotengine.org/download).
2. Open this folder in Godot (or import `project.godot`) and press **Play**.

Gamepad (Xbox / PlayStation) and keyboard/mouse are both supported.

## Highlights

- 3 save slots + new game; character creation (gender, look, name).
- 8 elements + normal type, 9 towns/schools, 45 creatures.
- Scan-to-capture, transform between up to 6 loaded essences (extras in the cloud).
- Turn-based battles with type effectiveness, leveling, and headmaster badges.
- Settings with Apply + 10-second display auto-revert.
- Procedural placeholder art & chiptune audio (no binary assets yet).

See [DESIGN.md](DESIGN.md) for architecture, controls, mechanics, tests, and the
prioritized roadmap.

## Tests

```bash
godot --headless tests/TestRunner.tscn   # content & logic checks
godot --headless tests/SmokeTest.tscn    # instantiate every scene
```
