extends Control
## Lets the player pick one of three save slots. Empty slots start a new game;
## used slots can be continued or deleted.

func _ready() -> void:
	UI.fill_background(self)
	_build()


func _build() -> void:
	for c in get_children():
		if c is ColorRect:
			continue
		c.queue_free()

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 80)
	margin.add_theme_constant_override("margin_right", 80)
	margin.add_theme_constant_override("margin_top", 50)
	margin.add_theme_constant_override("margin_bottom", 50)
	add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	margin.add_child(col)

	col.add_child(UI.make_title("Choose a Save Slot", 40))

	var first_focus: Control = null
	for slot in SaveManager.SLOT_COUNT:
		var row := _make_slot_row(slot)
		col.add_child(row)
		if first_focus == null:
			first_focus = row.get_meta("focus_target")

	var back := UI.make_button("Back")
	back.pressed.connect(func() -> void:
		AudioManager.play_sfx(&"cancel")
		get_tree().change_scene_to_file(Routes.TITLE))
	col.add_child(back)

	if first_focus != null:
		first_focus.grab_focus()


func _make_slot_row(slot: int) -> PanelContainer:
	var panel := UI.make_panel()
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	panel.add_child(hbox)

	var summary := SaveManager.slot_summary(slot)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info)
	info.add_child(UI.make_label("Slot %d" % (slot + 1), 26))

	var buttons := VBoxContainer.new()
	buttons.add_theme_constant_override("separation", 8)
	hbox.add_child(buttons)

	var focus_target: Control
	if summary.get("empty", true):
		info.add_child(UI.make_label("— Empty —", 18))
		var new_btn := UI.make_button("New Game")
		new_btn.custom_minimum_size = Vector2(200, 44)
		new_btn.pressed.connect(_on_new_game.bind(slot))
		buttons.add_child(new_btn)
		focus_target = new_btn
	else:
		info.add_child(UI.make_label("%s  (%s)" % [summary["player_name"], summary["gender"]], 18))
		info.add_child(UI.make_label("%s • %d badges • %d scanned" % [
			summary["town"], summary["badges"], summary["discovered"]], 16))
		info.add_child(UI.make_label("Played: %s" % _format_time(summary["play_seconds"]), 14))
		var continue_btn := UI.make_button("Continue")
		continue_btn.custom_minimum_size = Vector2(200, 44)
		continue_btn.pressed.connect(_on_continue.bind(slot))
		buttons.add_child(continue_btn)
		var delete_btn := UI.make_button("Delete")
		delete_btn.custom_minimum_size = Vector2(200, 36)
		delete_btn.pressed.connect(_on_delete.bind(slot))
		buttons.add_child(delete_btn)
		focus_target = continue_btn

	panel.set_meta("focus_target", focus_target)
	return panel


func _on_new_game(slot: int) -> void:
	AudioManager.play_sfx(&"confirm")
	GameState.current_slot = slot
	get_tree().change_scene_to_file(Routes.CHARACTER_CREATION)


func _on_continue(slot: int) -> void:
	if GameState.load_game(slot):
		AudioManager.play_sfx(&"confirm")
		get_tree().change_scene_to_file(Routes.OVERWORLD)


func _on_delete(slot: int) -> void:
	AudioManager.play_sfx(&"cancel")
	SaveManager.delete_slot(slot)
	_build()


func _format_time(seconds: float) -> String:
	var total := int(seconds)
	return "%d:%02d" % [total / 60, total % 60]
