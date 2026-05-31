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
	}


static func from_dict(data: Dictionary) -> Essence:
	var e := Essence.new(StringName(data.get("species_id", "")), int(data.get("level", 5)))
	e.experience = int(data.get("experience", 0))
	e.nickname = data.get("nickname", "")
	e.current_hp = int(data.get("current_hp", -1))
	return e
