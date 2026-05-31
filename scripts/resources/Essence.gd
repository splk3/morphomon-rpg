class_name Essence
extends RefCounted
## A scanned creature stored inside the Morphomon (or the cloud).
##
## An essence remembers which species it came from and the level/experience it
## has gained through battle. The Morphomon transforms into the species of the
## currently active essence.

var species_id: StringName = &""
var level: int = 5
var experience: int = 0
var nickname: String = ""
## Current HP is tracked so damage persists between battle turns.
var current_hp: int = -1
## Remaining PP per move id (String key) — initialized lazily from the species.
var pp: Dictionary = {}
## Active battle status condition (empty = none); persists between turns.
var status: StringName = &""
var status_turns: int = 0


func _init(p_species_id: StringName = &"", p_level: int = 5) -> void:
	species_id = p_species_id
	level = p_level


func species() -> CreatureSpecies:
	return GameData.get_creature(species_id)


func max_hp() -> int:
	var s := species()
	return s.max_hp(level) if s != null else 1


func ensure_full_hp() -> void:
	if current_hp < 0:
		current_hp = max_hp()


## Initializes PP for every move the species knows (missing entries only).
func ensure_pp() -> void:
	var s := species()
	if s == null:
		return
	for move_id in s.moves:
		var key := String(move_id)
		if not pp.has(key):
			var mv: MoveData = GameData.get_move(move_id)
			pp[key] = mv.max_pp if mv != null else 15


func pp_for(move_id: StringName) -> int:
	ensure_pp()
	return int(pp.get(String(move_id), 0))


## Spends one PP for [param move_id]; returns true if there was PP to spend.
func spend_pp(move_id: StringName) -> bool:
	ensure_pp()
	var key := String(move_id)
	if int(pp.get(key, 0)) <= 0:
		return false
	pp[key] = int(pp[key]) - 1
	return true


func restore_pp() -> void:
	pp.clear()
	ensure_pp()


func clear_status() -> void:
	status = &""
	status_turns = 0


func display_label() -> String:
	if not nickname.is_empty():
		return nickname
	var s := species()
	return s.display_name if s != null else String(species_id)


func experience_to_next() -> int:
	return level * 12


func add_experience(amount: int) -> bool:
	# Returns true if the essence leveled up at least once.
	var leveled := false
	experience += amount
	while experience >= experience_to_next():
		experience -= experience_to_next()
		level += 1
		current_hp = max_hp()
		leveled = true
	return leveled


func to_dict() -> Dictionary:
	return {
		"species_id": String(species_id),
		"level": level,
		"experience": experience,
		"nickname": nickname,
		"current_hp": current_hp,
		"pp": pp.duplicate(),
		"status": String(status),
		"status_turns": status_turns,
	}


static func from_dict(data: Dictionary) -> Essence:
	var e := Essence.new(StringName(data.get("species_id", "")), int(data.get("level", 5)))
	e.experience = int(data.get("experience", 0))
	e.nickname = data.get("nickname", "")
	e.current_hp = int(data.get("current_hp", -1))
	e.pp = (data.get("pp", {}) as Dictionary).duplicate()
	e.status = StringName(data.get("status", ""))
	e.status_turns = int(data.get("status_turns", 0))
	return e
