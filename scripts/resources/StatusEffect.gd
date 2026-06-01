class_name StatusEffect
extends Resource
## A battle status condition (poison, burn, paralysis, ...) that can be inflicted
## on a combatant. Definitions live in GameData; runtime state (which status is
## active and for how long) lives on the Combatant/Essence.

@export var id: StringName = &""
@export var display_name: String = ""
@export var color: Color = Color.WHITE
## Damage dealt at the end of each turn as a fraction of the victim's max HP.
@export_range(0.0, 1.0, 0.01) var dot_fraction: float = 0.0
## Chance (0..1) that the victim loses its action for the turn.
@export_range(0.0, 1.0, 0.05) var skip_chance: float = 0.0
## How many turns the status lasts before clearing.
@export var duration: int = 3
@export_multiline var description: String = ""
