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

	print("== Status effects ==")
	_check(GameData.statuses.size() >= 5, "status registry populated")
	_check(GameData.get_status(&"burn") != null, "burn status defined")
	_check(GameData.get_status(&"not_a_status") == null, "unknown status is null")
	var poisoned := Combatant.from_species(&"normal_pup", 10)
	_check(poisoned.apply_status(&"poison"), "status applies to a clean combatant")
	_check(not poisoned.apply_status(&"burn"), "second status is rejected while afflicted")
	var hp_before := poisoned.hp
	var dot := poisoned.tick_status()
	_check(dot > 0 and poisoned.hp == hp_before - dot, "poison deals end-of-turn damage")
	for i in 10:
		poisoned.tick_status()
	_check(not poisoned.has_status(), "status clears after its duration")

	print("== Move PP / status fields ==")
	var fb := GameData.get_move(&"flame_burst")
	_check(fb.max_pp > 0, "moves have positive max PP")
	_check(fb.status == &"burn" and fb.status_chance > 0.0, "flame_burst can burn")
	var pe := Essence.new(&"fire_mole", 5)
	pe.ensure_pp()
	var start_pp := pe.pp_for(&"flame_burst")
	_check(start_pp > 0, "essence initializes PP for known moves")
	_check(pe.spend_pp(&"flame_burst") and pe.pp_for(&"flame_burst") == start_pp - 1, "spending PP decrements it")
	pe.restore_pp()
	_check(pe.pp_for(&"flame_burst") == start_pp, "restore_pp refills PP")

	print("== Encounter tables ==")
	var table := [
		{"species_id": "normal_pup", "level_min": 3, "level_max": 6, "weight": 1.0},
		{"species_id": "fire_mole", "level_min": 4, "level_max": 4, "weight": 2.0},
	]
	var enc := GameData.roll_encounter(table)
	_check(enc.has("species_id") and GameData.get_creature(enc["species_id"]) != null, "encounter rolls a real species")
	_check(int(enc["level"]) >= 3 and int(enc["level"]) <= 6, "encounter level within table bounds")
	_check(GameData.roll_encounter([]).is_empty(), "empty table yields no encounter")

	print("== Story flags & world position ==")
	GameState.set_flag(&"intro_seen", true)
	_check(bool(GameState.get_flag(&"intro_seen")), "story flag set and read")
	_check(not bool(GameState.get_flag(&"never_set")), "unset flag defaults false")
	GameState.set_world_position(&"route_01", Vector2i(7, 9))
	var wp := GameState.get_world_position()
	_check(wp.get("route", &"") == &"route_01" and wp.get("cell") == Vector2i(7, 9), "world position persists in state")

	print("== Extended save round-trip ==")
	var sd2 := GameState.data
	var redict := sd2.to_dict()
	var re2 := SaveData.from_dict(redict)
	_check(re2.story_flags.get("intro_seen", false) == true, "save keeps story flags")
	_check(re2.world_position.get("route", "") == "route_01", "save keeps world position")
	var e_pp := Essence.new(&"electric_eel", 6)
	e_pp.ensure_pp()
	e_pp.status = &"paralyze"
	e_pp.status_turns = 3
	var e_round := Essence.from_dict(e_pp.to_dict())
	_check(e_round.pp.size() == e_pp.pp.size(), "save keeps essence PP")
	_check(e_round.status == e_pp.status, "save keeps essence status")

	print("== Rumble API ==")
	Settings.rumble(0.4, 0.6, 0.1)
	Settings.stop_rumble()
	_check(true, "rumble API callable without error")

	print("== Autosave ==")
	var _autosave_prev := Settings.autosave_enabled
	Settings.autosave_enabled = false
	_check(not GameState.autosave(), "autosave() is a no-op when disabled")
	Settings.autosave_enabled = _autosave_prev

