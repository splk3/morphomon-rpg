class_name TownData
extends Resource
## A town and its elemental school.
##
## There are 9 towns. Eight specialize in one of the 8 elements; the player's
## hometown school has no element (it teaches "normal"). Each town's headmaster
## must be defeated to progress.

@export var id: StringName = &""
@export var display_name: String = ""
## Element this town's school specializes in (&"normal" for the hometown).
@export var element: StringName = &"normal"
@export var is_hometown: bool = false
@export_multiline var description: String = ""
@export var headmaster_name: String = ""
## Story order in which the town is intended to be visited (hometown = 0).
@export var order: int = 0
