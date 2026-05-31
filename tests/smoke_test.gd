extends Node
## Instantiates every scene headlessly to catch _ready() runtime errors.
## Run with:  godot --headless tests/SmokeTest.tscn

const SCENES := [
	"res://scenes/ui/TitleScreen.tscn",
	"res://scenes/ui/SaveSlotMenu.tscn",
	"res://scenes/ui/SettingsMenu.tscn",
	"res://scenes/ui/CharacterCreation.tscn",
	"res://scenes/ui/StarterChoice.tscn",
	"res://scenes/battle/Battle.tscn",
	"res://scenes/world/Overworld.tscn",
]


func _ready() -> void:
	# Give the scenes a valid game/battle context so they build fully.
	GameState.start_new_game(0, "Smoke", "girl", 2)
	GameState.choose_starter(&"fire_mole")
	GameState.start_wild_battle(&"normal_pup", 4)

	for path in SCENES:
		await _instance_scene(path)

	print("SMOKE OK: instantiated %d scenes" % SCENES.size())
	get_tree().quit(0)


func _instance_scene(path: String) -> void:
	var packed: PackedScene = load(path)
	if packed == null:
		printerr("SMOKE FAIL: could not load ", path)
		get_tree().quit(1)
		return
	var inst := packed.instantiate()
	add_child(inst)
	await get_tree().process_frame
	await get_tree().process_frame
	print("  instanced: ", path)
	inst.queue_free()
	await get_tree().process_frame
