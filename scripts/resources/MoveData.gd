class_name MoveData
extends Resource
## A battle attack that a transformed Morphomon (or wild creature) can use.

@export var id: StringName = &""
@export var display_name: String = ""
@export var element: StringName = &"normal"
@export var power: int = 20
@export_range(0.0, 1.0, 0.05) var accuracy: float = 1.0
@export_multiline var description: String = ""
