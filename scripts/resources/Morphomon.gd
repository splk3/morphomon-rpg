class_name Morphomon
extends RefCounted
## The player's transforming robot.
##
## Holds up to MAX_ESSENCES loaded essences. Extra essences live in the cloud
## and can be swapped in at a town's Morphomon Club. Outside of battle the robot
## collapses into a pocket-sized cube.

const MAX_ESSENCES := 6

var essences: Array[Essence] = []
var active_index: int = 0


func active_essence() -> Essence:
	if active_index >= 0 and active_index < essences.size():
		return essences[active_index]
	return null


func is_full() -> bool:
	return essences.size() >= MAX_ESSENCES


func add_essence(essence: Essence) -> bool:
	# Returns false when the Morphomon is already holding the maximum.
	if is_full():
		return false
	essence.ensure_full_hp()
	essences.append(essence)
	return true


func remove_essence(index: int) -> Essence:
	if index < 0 or index >= essences.size():
		return null
	var removed: Essence = essences[index]
	essences.remove_at(index)
	active_index = clampi(active_index, 0, maxi(0, essences.size() - 1))
	return removed


func has_usable_essence() -> bool:
	for e in essences:
		e.ensure_full_hp()
		if e.current_hp > 0:
			return true
	return false


func first_usable_index() -> int:
	for i in essences.size():
		essences[i].ensure_full_hp()
		if essences[i].current_hp > 0:
			return i
	return -1


func heal_all() -> void:
	for e in essences:
		e.current_hp = e.max_hp()


func to_dict() -> Dictionary:
	var arr: Array = []
	for e in essences:
		arr.append(e.to_dict())
	return {"essences": arr, "active_index": active_index}


static func from_dict(data: Dictionary) -> Morphomon:
	var m := Morphomon.new()
	for d in data.get("essences", []):
		m.essences.append(Essence.from_dict(d))
	m.active_index = int(data.get("active_index", 0))
	return m
