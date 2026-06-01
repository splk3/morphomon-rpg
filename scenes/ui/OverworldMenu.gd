class_name OverworldMenu
extends CanvasLayer
## Modal overlay for the in-world menu (party / morphopedia / save / settings)
## and the town's Morphomon Club services (heal / cloud storage / headmaster).

enum Kind { MAIN, TOWN }

signal closed

const MORPHOPEDIA_MENU_SCENE := preload("res://scenes/ui/MorphopediaMenu.tscn")

var kind: Kind = Kind.MAIN
var _root: Control
var _content: VBoxContainer
var _morphopedia_menu: MorphopediaMenu


func _ready() -> void:
	layer = 40
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(center)
	var panel := UI.make_panel()
	panel.custom_minimum_size = Vector2(520, 0)
	center.add_child(panel)
	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 10)
	panel.add_child(_content)

	if kind == Kind.TOWN:
		_show_town_root()
	else:
		_show_main_root()


func _unhandled_input(event: InputEvent) -> void:
	if _morphopedia_menu != null:
		return
	if event.is_action_pressed("cancel") or event.is_action_pressed("open_menu"):
		get_viewport().set_input_as_handled()
		_close()


func _clear() -> void:
	for c in _content.get_children():
		c.queue_free()


func _title(text: String) -> void:
	_content.add_child(UI.make_title(text, 30))


func _button(text: String, cb: Callable, focus := false) -> Button:
	var b := UI.make_button(text)
	b.pressed.connect(func() -> void:
		AudioManager.play_sfx(&"select")
		cb.call())
	_content.add_child(b)
	if focus:
		b.call_deferred("grab_focus")
	return b


# ----------------------------------------------------------------- MAIN
func _show_main_root() -> void:
	_clear()
	_title("Menu")
	_button("Party", _show_party, true)
	_button("Morphopedia", _show_morphopedia)
	_button("Save Game", _save_game)
	_button("Settings", func() -> void: get_tree().change_scene_to_file(Routes.SETTINGS))
	_button("Close", _close)


func _show_party() -> void:
	_clear()
	_title("Your Morphomon")
	var mon := GameState.data.morphomon
	if mon.essences.is_empty():
		_content.add_child(UI.make_label("No essences loaded yet.", 18))
	for i in mon.essences.size():
		var e := mon.essences[i]
		e.ensure_full_hp()
		var line := "%s  Lv.%d  HP %d/%d%s" % [
			e.display_label(), e.level, e.current_hp, e.max_hp(),
			"  (active)" if i == mon.active_index else ""]
		_content.add_child(UI.make_label(line, 18))
	_button("Back", _show_main_root, true)


func _show_morphopedia() -> void:
	_clear()
	_morphopedia_menu = MORPHOPEDIA_MENU_SCENE.instantiate() as MorphopediaMenu
	_morphopedia_menu.closed.connect(_on_morphopedia_closed)
	add_child(_morphopedia_menu)


func _on_morphopedia_closed() -> void:
	if _morphopedia_menu != null:
		_morphopedia_menu.queue_free()
		_morphopedia_menu = null
	_show_main_root()


func _save_game() -> void:
	GameState.save()
	AudioManager.play_sfx(&"confirm")
	_clear()
	_title("Saved!")
	_content.add_child(UI.make_label("Your adventure has been saved.", 18))
	_button("Back", _show_main_root, true)


# ----------------------------------------------------------------- TOWN
func _show_town_root() -> void:
	_clear()
	var town := GameData.get_town(GameState.data.current_town)
	_title((town.display_name if town else "Town") + " School")
	_button("Heal Morphomon (Club)", _heal, true)
	_button("Cloud Storage", _show_cloud)
	_button("Challenge Headmaster", _challenge_headmaster)
	_button("Leave", _close)


func _heal() -> void:
	GameState.heal_team()
	AudioManager.play_sfx(&"confirm")
	GameState.save()
	_clear()
	_title("Morphomon Club")
	_content.add_child(UI.make_label("Your Morphomon's essences are fully restored!", 18))
	_button("Back", _show_town_root, true)


func _show_cloud() -> void:
	_clear()
	_title("Cloud Storage")
	var mon := GameState.data.morphomon
	_content.add_child(UI.make_label(
		"Loaded %d / %d. Store essences to free space, or load from the cloud." % [
			mon.essences.size(), Morphomon.MAX_ESSENCES], 16))

	_content.add_child(UI.make_label("Loaded:", 18))
	for i in mon.essences.size():
		var e := mon.essences[i]
		var row := HBoxContainer.new()
		_content.add_child(row)
		row.add_child(UI.make_label("%s Lv.%d" % [e.display_label(), e.level], 16))
		if mon.essences.size() > 1:
			var store := UI.make_button("→ Cloud")
			store.custom_minimum_size = Vector2(120, 32)
			store.pressed.connect(_store_to_cloud.bind(i))
			row.add_child(store)

	_content.add_child(UI.make_label("Cloud:", 18))
	if GameState.data.cloud_essences.is_empty():
		_content.add_child(UI.make_label("(empty)", 14))
	for i in GameState.data.cloud_essences.size():
		var e := GameState.data.cloud_essences[i]
		var row := HBoxContainer.new()
		_content.add_child(row)
		row.add_child(UI.make_label("%s Lv.%d" % [e.display_label(), e.level], 16))
		var load_btn := UI.make_button("Load")
		load_btn.custom_minimum_size = Vector2(120, 32)
		load_btn.disabled = mon.is_full()
		load_btn.pressed.connect(_load_from_cloud.bind(i))
		row.add_child(load_btn)

	_button("Back", _show_town_root, true)


func _store_to_cloud(index: int) -> void:
	var mon := GameState.data.morphomon
	if mon.essences.size() <= 1:
		return
	var e := mon.remove_essence(index)
	if e != null:
		GameState.data.cloud_essences.append(e)
	GameState.save()
	_show_cloud()


func _load_from_cloud(index: int) -> void:
	var mon := GameState.data.morphomon
	if mon.is_full() or index >= GameState.data.cloud_essences.size():
		return
	var e: Essence = GameState.data.cloud_essences[index]
	if mon.add_essence(e):
		GameState.data.cloud_essences.remove_at(index)
	GameState.save()
	_show_cloud()


func _challenge_headmaster() -> void:
	var town := GameData.get_town(GameState.data.current_town)
	if town == null:
		return
	if GameState.data.defeated_headmasters.has(String(town.id)):
		_clear()
		_title("Headmaster")
		_content.add_child(UI.make_label("You have already earned this school's badge!", 18))
		_button("Back", _show_town_root, true)
		return
	var element := town.element
	var pool := GameData.creatures_of_element(element)
	if pool.is_empty():
		pool = GameData.creatures.values()
	var team: Array = []
	for i in 3:
		team.append({"species_id": (pool.pick_random() as CreatureSpecies).id, "level": randi_range(6, 9)})
	GameState.start_trainer_battle(town.headmaster_name, team, town.id)
	get_tree().change_scene_to_file(Routes.BATTLE)


func _close() -> void:
	AudioManager.play_sfx(&"cancel")
	closed.emit()
	queue_free()
