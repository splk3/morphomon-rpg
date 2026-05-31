extends Node
## Manages the three save slots. Registered as the `SaveManager` autoload.

const SLOT_COUNT := 3
const SAVE_DIR := "user://saves"

signal slot_saved(slot: int)


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func _slot_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot]


func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(_slot_path(slot))


func save_to_slot(slot: int, data: SaveData) -> bool:
	if slot < 0 or slot >= SLOT_COUNT:
		return false
	var file := FileAccess.open(_slot_path(slot), FileAccess.WRITE)
	if file == null:
		push_error("Could not open save slot %d for writing" % slot)
		return false
	file.store_string(JSON.stringify(data.to_dict(), "\t"))
	file.close()
	slot_saved.emit(slot)
	return true


func load_from_slot(slot: int) -> SaveData:
	if not slot_exists(slot):
		return null
	var file := FileAccess.open(_slot_path(slot), FileAccess.READ)
	if file == null:
		return null
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Save slot %d is corrupt" % slot)
		return null
	return SaveData.from_dict(parsed)


func delete_slot(slot: int) -> void:
	if slot_exists(slot):
		DirAccess.remove_absolute(_slot_path(slot))


## Lightweight summary used to render the save-slot select menu without fully
## reconstructing runtime objects.
func slot_summary(slot: int) -> Dictionary:
	if not slot_exists(slot):
		return {"empty": true}
	var data := load_from_slot(slot)
	if data == null:
		return {"empty": true, "corrupt": true}
	var town := GameData.get_town(data.current_town)
	return {
		"empty": false,
		"player_name": data.player_name,
		"gender": data.gender,
		"town": town.display_name if town != null else String(data.current_town),
		"badges": data.defeated_headmasters.size(),
		"discovered": data.morphopedia.size(),
		"play_seconds": data.play_seconds,
	}
