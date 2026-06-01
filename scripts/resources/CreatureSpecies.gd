class_name CreatureSpecies
extends Resource
## A creature that can be encountered, scanned, and stored as an essence.
##
## When a creature's essence is loaded into the Morphomon, the robot can
## transform into that creature for battle. Each of the 8 elements (plus normal)
## has 5 themed species.

@export var id: StringName = &""
@export var display_name: String = ""
@export var element: StringName = &"normal"
@export_multiline var description: String = ""

## Base stats used to derive battle stats by level.
@export var base_hp: int = 20
@export var base_attack: int = 10
@export var base_defense: int = 10
@export var base_speed: int = 10

## Move ids known by this species (looked up in GameData.moves).
@export var moves: Array[StringName] = []

## Difficulty of scanning this creature (higher = harder to capture).
@export_range(0.0, 1.0, 0.05) var scan_resistance: float = 0.5

## Color used for the placeholder sprite of this creature.
@export var tint: Color = Color.WHITE


func stat_at_level(base: int, level: int) -> int:
	# Simple linear growth keeps early-game numbers readable.
	return base + int(round(base * (level - 1) * 0.08)) + (level - 1)


func max_hp(level: int) -> int:
	return stat_at_level(base_hp, level) + level * 2


func attack_at(level: int) -> int:
	return stat_at_level(base_attack, level)


func defense_at(level: int) -> int:
	return stat_at_level(base_defense, level)


func speed_at(level: int) -> int:
	return stat_at_level(base_speed, level)
