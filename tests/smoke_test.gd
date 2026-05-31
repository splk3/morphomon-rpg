extends Node
## Instantiates every scene headlessly to catch _ready() runtime errors.
## Run with:  godot --headless tests/SmokeTest.tscn

const SCENES := [
	"res://scenes/ui/TitleScreen.tscn",
	"res://scenes/ui/SaveSlotMenu.tscn",
	"res://scenes/ui/SettingsMenu.tscn",
	"res://scenes/ui/RemapMenu.tscn",
	"res://scenes/ui/CharacterCreation.tscn",
	"res://scenes/ui/StarterChoice.tscn",
	"res://scenes/ui/cutscenes/IntroCutscene.tscn",
	"res://scenes/ui/MorphopediaMenu.tscn",
	"res://scenes/battle/Battle.tscn",
	"res://scenes/world/Overworld.tscn",
	"res://scenes/world/maps/EmberTownMap.tscn",
	"res://scenes/world/maps/Route01Map.tscn",
	"res://scenes/world/maps/SproutTownMap.tscn",
	"res://scenes/world/maps/TideTownMap.tscn",
	"res://scenes/world/maps/VoltTownMap.tscn",
	"res://scenes/world/maps/BedrockTownMap.tscn",
	"res://scenes/world/maps/VerdantTownMap.tscn",
	"res://scenes/world/maps/LumenTownMap.tscn",
	"res://scenes/world/maps/UmbraTownMap.tscn",
	"res://scenes/world/maps/NovaTownMap.tscn",
	"res://scenes/world/maps/RouteSproutEmber.tscn",
	"res://scenes/world/maps/RouteToTide.tscn",
	"res://scenes/world/maps/RouteToVolt.tscn",
	"res://scenes/world/maps/RouteToBedrock.tscn",
	"res://scenes/world/maps/RouteToVerdant.tscn",
	"res://scenes/world/maps/RouteToLumen.tscn",
	"res://scenes/world/maps/RouteToUmbra.tscn",
	"res://scenes/world/maps/RouteToNova.tscn",
]


func _ready() -> void:
	# Give the scenes a valid game/battle context so they build fully.
	GameState.start_new_game(0, "Smoke", "girl", 2)
	GameState.choose_starter(&"fire_mole")
	GameState.start_wild_battle(&"normal_pup", 4)

	# Compile every gameplay script first so a parse error fails the run even
	# when the broken script is only attached to a scene's child/root.
	_check_scripts()

	for path in SCENES:
		await _instance_scene(path)

	print("SMOKE OK: instantiated %d scenes" % SCENES.size())
	get_tree().quit(0)


## Loads every .gd under the source dirs; a parse/compile error makes load()
## return null, which fails the smoke test.
func _check_scripts() -> void:
	var count := 0
	for dir in ["res://autoload", "res://scripts", "res://scenes", "res://data"]:
		count += _check_scripts_in(dir)
	print("  compiled %d scripts" % count)


func _check_scripts_in(dir_path: String) -> int:
	var count := 0
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return 0
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		var full := dir_path.path_join(entry)
		if dir.current_is_dir():
			count += _check_scripts_in(full)
		elif entry.ends_with(".gd"):
			var script: Script = load(full)
			if script == null:
				printerr("SMOKE FAIL: script failed to compile: ", full)
				get_tree().quit(1)
			else:
				count += 1
		entry = dir.get_next()
	dir.list_dir_end()
	return count


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
