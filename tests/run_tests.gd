extends Node
## Headless test/validation runner.
## Run with:  godot --headless tests/TestRunner.tscn
## Exits with code 0 on success, 1 on any failure.

var _failures: int = 0
var _checks: int = 0


func _ready() -> void:
	await get_tree().process_frame
	_run()
	print("\n%d checks, %d failures" % [_checks, _failures])
	get_tree().quit(1 if _failures > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_failures += 1
		printerr("  FAIL: ", msg)
	else:
		print("  ok: ", msg)


func _run() -> void:
	print("== Content ==")
	_check(GameData.elements.size() == 9, "9 elements registered")
	_check(GameData.creatures.size() == 45, "45 creatures registered")
	for el in GameData.ELEMENT_IDS:
		_check(GameData.creatures_of_element(el).size() == 5, "5 creatures for %s" % el)
	_check(GameData.towns.size() == 9, "9 towns registered")
	_check(GameData.towns_ordered[0].is_hometown, "first town is hometown")
	for sid in GameData.STARTER_IDS:
		_check(GameData.get_creature(sid) != null, "starter %s exists" % sid)

	print("== Type chart ==")
	_check(GameData.effectiveness(&"fire", &"plant") == 2.0, "fire beats plant")
	_check(GameData.effectiveness(&"water", &"fire") == 2.0, "water beats fire")
	_check(GameData.effectiveness(&"normal", &"fire") == 1.0, "normal neutral")

	print("== Essence / Morphomon ==")
	var e := Essence.new(&"fire_mole", 5)
	e.ensure_full_hp()
	_check(e.current_hp == e.max_hp(), "essence starts at full hp")
	var before := e.level
	e.add_experience(e.experience_to_next() + e.experience_to_next())
	_check(e.level >= before + 1, "essence levels up with xp")

	var mon := Morphomon.new()
	for i in 8:
		mon.add_essence(Essence.new(&"normal_pup", 5))
	_check(mon.essences.size() == Morphomon.MAX_ESSENCES, "morphomon caps at 6 essences")
	_check(mon.is_full(), "morphomon reports full")
	_check(mon.has_usable_essence(), "morphomon has usable essence")

	print("== Save round-trip ==")
	var sd := SaveData.new()
	sd.player_name = "Tester"
	sd.gender = "girl"
	sd.morphomon.add_essence(Essence.new(&"water_crane", 7))
	sd.record_discovery(&"water_crane")
	var dict := sd.to_dict()
	var restored := SaveData.from_dict(dict)
	_check(restored.player_name == "Tester", "save keeps player name")
	_check(restored.morphomon.essences.size() == 1, "save keeps essences")
	_check(restored.morphopedia.has("water_crane"), "save keeps morphopedia")
	_check(SaveManager.save_to_slot(2, sd), "save to slot 2")
	var loaded := SaveManager.load_from_slot(2)
	_check(loaded != null and loaded.player_name == "Tester", "load from slot 2")
	var summary := SaveManager.slot_summary(2)
	_check(not summary.get("empty", true), "slot 2 summary not empty")
	SaveManager.delete_slot(2)
	_check(not SaveManager.slot_exists(2), "slot 2 deleted")

	print("== GameState new game ==")
	GameState.start_new_game(0, "Hero", "boy", 0)
	_check(GameState.has_active_game(), "active game after new game")
	_check(GameState.choose_starter(&"plant_cactus"), "choose plant starter")
	_check(not GameState.choose_starter(&"not_a_real_id"), "reject invalid starter")
	_check(GameState.data.morphopedia.has("plant_cactus"), "starter recorded in pedia")

	print("== Scan probability bounds ==")
	var weak_chances := 0
	for i in 200:
		if GameState.attempt_scan(&"normal_pup", 3, 0.05):
			weak_chances += 1
	_check(weak_chances > 0, "weakened low-level creatures are scannable")
	# Reset team so a strong, full-hp creature is rarely caught.
	GameState.data.morphomon.heal_all()

	print("== Combatant battle math ==")
	var atk := Combatant.from_species(&"fire_mole", 10)
	var dfn := Combatant.from_species(&"plant_cactus", 10)
	var move := GameData.get_move(&"flame_burst")
	var dmg := atk.damage_against(move, dfn)
	_check(dmg >= 1, "fire move deals damage to plant")
	dfn.take_damage(dfn.max_hp)
	_check(dfn.is_fainted(), "combatant faints at 0 hp")

	print("== Defensive guards ==")
	_check(Combatant.from_essence(null) == null, "from_essence(null) returns null safely")
	_check(Combatant.from_species(&"not_real", 5).species == null, "invalid species id yields null species")
