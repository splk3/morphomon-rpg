class_name SaveData
extends RefCounted
## Everything persisted for a single save slot.

var player_name: String = "Hero"
## "boy" or "girl" — chosen at the start of a new game.
var gender: String = "boy"
## Index into the preset appearance palette chosen during character creation.
var appearance: int = 0
var starter_chosen: bool = false

var morphomon: Morphomon = Morphomon.new()
## Essences kept in the cloud, retrievable at any Morphomon Club.
var cloud_essences: Array[Essence] = []

var current_town: StringName = &"hometown"
## Town ids whose headmaster has been defeated.
var defeated_headmasters: Array = []
## Discovered species ids (the Morphopedia).
var morphopedia: Array = []

var play_seconds: float = 0.0
var created_unix: int = 0


func record_discovery(species_id: StringName) -> void:
	var s := String(species_id)
	if not morphopedia.has(s):
		morphopedia.append(s)


func to_dict() -> Dictionary:
	var cloud: Array = []
	for e in cloud_essences:
		cloud.append(e.to_dict())
	return {
		"player_name": player_name,
		"gender": gender,
		"appearance": appearance,
		"starter_chosen": starter_chosen,
		"morphomon": morphomon.to_dict(),
		"cloud_essences": cloud,
		"current_town": String(current_town),
		"defeated_headmasters": defeated_headmasters,
		"morphopedia": morphopedia,
		"play_seconds": play_seconds,
		"created_unix": created_unix,
	}


static func from_dict(data: Dictionary) -> SaveData:
	var sd := SaveData.new()
	sd.player_name = data.get("player_name", "Hero")
	sd.gender = data.get("gender", "boy")
	sd.appearance = int(data.get("appearance", 0))
	sd.starter_chosen = bool(data.get("starter_chosen", false))
	sd.morphomon = Morphomon.from_dict(data.get("morphomon", {}))
	sd.cloud_essences = []
	for d in data.get("cloud_essences", []):
		sd.cloud_essences.append(Essence.from_dict(d))
	sd.current_town = StringName(data.get("current_town", "hometown"))
	sd.defeated_headmasters = data.get("defeated_headmasters", [])
	sd.morphopedia = data.get("morphopedia", [])
	sd.play_seconds = float(data.get("play_seconds", 0.0))
	sd.created_unix = int(data.get("created_unix", 0))
	return sd
