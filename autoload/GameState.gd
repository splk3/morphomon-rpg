extends Node
## Runtime game state hub. Holds the active save data, tracks play time, and
## centralizes gameplay actions (starter choice, scanning, healing). Registered
## as the `GameState` autoload.

signal morphopedia_updated

var current_slot: int = -1
var data: SaveData = null

## Configuration for the battle the Overworld is about to start. Consumed by the
## Battle scene. Shape: { wild: bool, species_id, level, trainer_name?,
## trainer_team?: Array[{species_id, level}] }.
var pending_battle: Dictionary = {}


## Queue a wild encounter (scannable, can be fled).
func start_wild_battle(species_id: StringName, level: int) -> void:
	pending_battle = {"wild": true, "species_id": species_id, "level": level}


## Queue a trainer battle (not scannable, cannot be fled). When [param
## headmaster_town] is set, defeating the team records that town's badge.
func start_trainer_battle(trainer_name: String, team: Array, headmaster_town: StringName = &"") -> void:
	pending_battle = {
		"wild": false,
		"trainer_name": trainer_name,
		"trainer_team": team,
		"headmaster_town": String(headmaster_town),
	}


func _process(delta: float) -> void:
	if data != null:
		data.play_seconds += delta


func has_active_game() -> bool:
	return data != null


## Begin a brand new game in [param slot] with the chosen identity.
func start_new_game(slot: int, player_name: String, gender: String, appearance: int) -> void:
	current_slot = slot
	data = SaveData.new()
	data.player_name = player_name
	data.gender = gender
	data.appearance = appearance
	data.created_unix = int(Time.get_unix_time_from_system())
	data.current_town = &"hometown"
	# The Morphomon is a gift from mom on the first day of school — it starts
	# empty until the player chooses a starter essence at the headmaster's office.


func load_game(slot: int) -> bool:
	var loaded := SaveManager.load_from_slot(slot)
	if loaded == null:
		return false
	current_slot = slot
	data = loaded
	return true


func save() -> bool:
	if data == null or current_slot < 0:
		return false
	return SaveManager.save_to_slot(current_slot, data)


## Grant the chosen starter essence (plant_cactus / fire_mole / water_crane).
func choose_starter(species_id: StringName) -> bool:
	if data == null or not GameData.STARTER_IDS.has(species_id):
		return false
	var essence := Essence.new(species_id, 5)
	essence.ensure_full_hp()
	if not data.morphomon.add_essence(essence):
		return false
	data.morphomon.active_index = data.morphomon.essences.size() - 1
	data.starter_chosen = true
	data.record_discovery(species_id)
	morphopedia_updated.emit()
	return true


## Attempt to scan a wild creature. Success chance scales with how weakened the
## creature is, the level gap, and the species' scan resistance. Returns true on
## a successful capture (essence stored in the Morphomon or the cloud).
func attempt_scan(species_id: StringName, creature_level: int, hp_ratio: float) -> bool:
	var species := GameData.get_creature(species_id)
	if species == null or data == null:
		return false
	var active := data.morphomon.active_essence()
	var our_level := active.level if active != null else 5
	var weakened := 1.0 - clampf(hp_ratio, 0.0, 1.0)          # 0..1, higher when hurt
	var level_factor := clampf(float(our_level) / float(maxi(1, creature_level)), 0.4, 1.6)
	var chance := clampf((0.25 + 0.55 * weakened) * level_factor * (1.0 - species.scan_resistance) + 0.1, 0.05, 0.95)
	var success := randf() < chance
	if success:
		_store_scanned_essence(species_id, creature_level)
		data.record_discovery(species_id)
		morphopedia_updated.emit()
	return success


func _store_scanned_essence(species_id: StringName, level: int) -> void:
	var essence := Essence.new(species_id, level)
	essence.ensure_full_hp()
	if not data.morphomon.add_essence(essence):
		# Morphomon is full — route the new essence to cloud storage.
		data.cloud_essences.append(essence)


func heal_team() -> void:
	if data != null:
		data.morphomon.heal_all()
