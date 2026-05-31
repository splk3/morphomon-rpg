extends Control
## Control remapping menu for gameplay actions.

const ACTIONS: Array[StringName] = [
	&"move_up",
	&"move_down",
	&"move_left",
	&"move_right",
	&"interact",
	&"cancel",
	&"run",
	&"open_menu",
	&"scan",
]

const ACTION_LABELS := {
	&"move_up": "Move Up",
	&"move_down": "Move Down",
	&"move_left": "Move Left",
	&"move_right": "Move Right",
	&"interact": "Interact",
	&"cancel": "Cancel",
	&"run": "Run",
	&"open_menu": "Menu",
	&"scan": "Scan",
}

var _binding_labels: Dictionary = {}
var _status_label: Label
var _vibration_button: Button
var _first_focus: Control
var _capturing_action: StringName = &""


func _ready() -> void:
	UI.fill_background(self)
	_build()
	_refresh_all()
	if _first_focus != null:
		_first_focus.grab_focus()


func _input(event: InputEvent) -> void:
	if _capturing_action == &"":
		return
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if not key_event.pressed or key_event.echo:
			return
		accept_event()
		if key_event.physical_keycode == KEY_ESCAPE:
			_cancel_capture()
			return
		_store_binding({"type": "key", "keycode": key_event.physical_keycode})
	elif event is InputEventJoypadButton:
		var button_event := event as InputEventJoypadButton
		if not button_event.pressed:
			return
		accept_event()
		_store_binding({"type": "button", "button_index": button_event.button_index})


func _build() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 60)
	add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	margin.add_child(col)

	col.add_child(UI.make_title("Control Remapping", 40))
	var hint := UI.make_label("Choose Rebind, then press a keyboard key or gamepad button. Press Esc to cancel capture.", 16)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(hint)

	var panel := UI.make_panel(UI.PANEL)
	col.add_child(panel)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 8)
	panel.add_child(rows)

	for action in ACTIONS:
		_add_action_row(rows, action)

	_status_label = UI.make_label("", 18)
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_status_label)

	var controls_row := HBoxContainer.new()
	controls_row.add_theme_constant_override("separation", 16)
	col.add_child(controls_row)

	_vibration_button = UI.make_button("Gamepad Vibration: On")
	_vibration_button.pressed.connect(_on_toggle_vibration)
	controls_row.add_child(_vibration_button)

	var reset := UI.make_button("Reset to Defaults")
	reset.pressed.connect(_on_reset_defaults)
	controls_row.add_child(reset)

	var back := UI.make_button("Back")
	back.pressed.connect(_on_back)
	controls_row.add_child(back)


func _add_action_row(parent: VBoxContainer, action: StringName) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)

	var name_label := UI.make_label(str(ACTION_LABELS.get(action, str(action))), 18)
	name_label.custom_minimum_size = Vector2(190, 0)
	row.add_child(name_label)

	var binding_label := UI.make_label("", 18)
	binding_label.custom_minimum_size = Vector2(220, 0)
	row.add_child(binding_label)
	_binding_labels[action] = binding_label

	var rebind := UI.make_button("Rebind")
	rebind.custom_minimum_size = Vector2(160, 44)
	rebind.pressed.connect(_start_capture.bind(action))
	row.add_child(rebind)
	if _first_focus == null:
		_first_focus = rebind


func _refresh_all() -> void:
	for action in ACTIONS:
		_refresh_action(action)
	_refresh_vibration_label()
	if _capturing_action == &"":
		_status_label.text = ""


func _refresh_action(action: StringName) -> void:
	var label := _binding_labels.get(action) as Label
	if label == null:
		return
	label.text = _primary_binding_text(action)


func _primary_binding_text(action: StringName) -> String:
	if not InputMap.has_action(action):
		return "Unregistered"
	var events := InputMap.action_get_events(action)
	if events.is_empty():
		return "Unbound"
	return _event_label(events[0])


func _event_label(event: InputEvent) -> String:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		return OS.get_keycode_string(key_event.physical_keycode)
	if event is InputEventJoypadButton:
		var button_event := event as InputEventJoypadButton
		return "Pad Button %d" % button_event.button_index
	if event is InputEventJoypadMotion:
		var motion_event := event as InputEventJoypadMotion
		var direction := "+" if motion_event.axis_value >= 0.0 else "-"
		return "Pad Axis %d %s" % [motion_event.axis, direction]
	return event.as_text()


func _start_capture(action: StringName) -> void:
	AudioManager.play_sfx(&"confirm")
	_capturing_action = action
	_status_label.text = "Press a key or button for %s..." % str(ACTION_LABELS.get(action, str(action)))


func _cancel_capture() -> void:
	AudioManager.play_sfx(&"cancel")
	_capturing_action = &""
	_status_label.text = "Rebind cancelled."


func _store_binding(binding: Dictionary) -> void:
	var action := _capturing_action
	_capturing_action = &""
	Settings.custom_bindings.erase(action)
	Settings.custom_bindings.erase(str(action))
	Settings.custom_bindings[str(action)] = [binding]
	Settings.apply_bindings()
	Settings.save_settings()
	AudioManager.play_sfx(&"confirm")
	_refresh_action(action)
	_status_label.text = "%s set to %s." % [str(ACTION_LABELS.get(action, str(action))), _primary_binding_text(action)]


func _on_toggle_vibration() -> void:
	Settings.gamepad_vibration = not Settings.gamepad_vibration
	Settings.save_settings()
	AudioManager.play_sfx(&"confirm")
	_refresh_vibration_label()


func _refresh_vibration_label() -> void:
	_vibration_button.text = "Gamepad Vibration: %s" % ["On" if Settings.gamepad_vibration else "Off"]


func _on_reset_defaults() -> void:
	AudioManager.play_sfx(&"cancel")
	_capturing_action = &""
	Settings.custom_bindings.clear()
	if is_instance_valid(InputSetup) and InputSetup.has_method("_ready"):
		for action in ACTIONS:
			if InputMap.has_action(action):
				InputMap.action_erase_events(action)
		InputSetup.call("_ready")
	else:
		Settings.apply_bindings()
	Settings.save_settings()
	_refresh_all()
	_status_label.text = "Controls reset to defaults."


func _on_back() -> void:
	AudioManager.play_sfx(&"cancel")
	get_tree().change_scene_to_file(Routes.SETTINGS)
