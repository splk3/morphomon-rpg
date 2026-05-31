class_name MoveData
extends Resource
## A battle attack that a transformed Morphomon (or wild creature) can use.

@export var id: StringName = &""
@export var display_name: String = ""
@export var element: StringName = &"normal"
@export var power: int = 20
@export_range(0.0, 1.0, 0.05) var accuracy: float = 1.0
@export_multiline var description: String = ""

## Maximum uses before the move runs out of energy (PP). Tracked per essence.
@export var max_pp: int = 15
## Status condition this move may inflict (empty = none). See GameData.statuses.
@export var status: StringName = &""
## Probability (0..1) of inflicting [member status] on a successful hit.
@export_range(0.0, 1.0, 0.05) var status_chance: float = 0.0
