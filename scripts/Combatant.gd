class_name Combatant
extends RefCounted
## A single participant in a battle (the player's transformed Morphomon or an
## enemy creature). Wraps a species at a level with live HP.

var species: CreatureSpecies
var level: int
var max_hp: int
var hp: int
## Optional link back to the player's stored essence so XP/HP persist.
var essence: Essence = null


static func from_species(species_id: StringName, lvl: int) -> Combatant:
	var c := Combatant.new()
	c.species = GameData.get_creature(species_id)
	c.level = lvl
	c.max_hp = c.species.max_hp(lvl) if c.species != null else 1
	c.hp = c.max_hp
	return c


static func from_essence(e: Essence) -> Combatant:
	if e == null:
		return null
	e.ensure_full_hp()
	var c := Combatant.new()
	c.species = e.species()
	c.level = e.level
	c.max_hp = e.max_hp()
	c.hp = clampi(e.current_hp, 0, c.max_hp)
	c.essence = e
	return c


func is_fainted() -> bool:
	return hp <= 0


func hp_ratio() -> float:
	return 0.0 if max_hp <= 0 else float(hp) / float(max_hp)


func take_damage(amount: int) -> void:
	hp = clampi(hp - amount, 0, max_hp)
	if essence != null:
		essence.current_hp = hp


func display_name() -> String:
	return species.display_name if species != null else "???"


## Computes damage for [param move] used against [param target].
func damage_against(move: MoveData, target: Combatant) -> int:
	if move == null or species == null or target.species == null:
		return 1
	var atk := species.attack_at(level)
	var def := maxi(1, target.species.defense_at(target.level))
	var base := float(move.power) * float(atk) / float(def)
	var mult := GameData.effectiveness(move.element, target.species.element)
	# Small random spread keeps battles lively.
	var roll := randf_range(0.85, 1.0)
	return maxi(1, int(round(base * mult * roll * 0.5)))
