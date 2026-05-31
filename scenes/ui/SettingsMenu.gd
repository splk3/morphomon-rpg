extends Control
## Settings: audio, graphics and controls. Changes only take effect on "Apply".
## Display changes (window mode / resolution / vsync) trigger a 10 second
## confirmation; if the player does not confirm, the previous display settings
## are restored automatically (in case the new mode is unusable).

var _master: HSlider
var _music: HSlider
var _sfx: HSlider
var _window_mode: OptionButton
var _resolution: OptionButton
var _vsync: CheckButton
var _vibration: CheckButton

var _confirm_panel: PanelContainer
var _confirm_label: Label
var _revert_timer: Timer
var _countdown_left := 0.0
var _pre_apply_display: Dictionary = {}


func _ready() -> void:
	UI.fill_background(self)
	_build()
	_load_from_settings()


func _build() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 60)
	add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	margin.add_child(col)
	col.add_child(UI.make_title("Settings", 40))

	# --- Audio ---
	col.add_child(UI.make_label("Audio", 24))
	_master = _add_slider(col, "Master Volume")
	_music = _add_slider(col, "Music Volume")
	_sfx = _add_slider(col, "Sound Effects")

	# --- Graphics ---
	col.add_child(UI.make_label("Graphics", 24))
	_window_mode = _add_options(col, "Window Mode", Settings.WINDOW_MODES)
	var res_labels: Array[String] = []
	for r in Settings.RESOLUTIONS:
		res_labels.append("%d x %d" % [r.x, r.y])
	_resolution = _add_options(col, "Resolution", res_labels)
	_vsync = _add_toggle(col, "V-Sync")

	# --- Controls ---
	col.add_child(UI.make_label("Controls", 24))
	_vibration = _add_toggle(col, "Gamepad Vibration")
	var remap := UI.make_button("Customize Controls")
	remap.pressed.connect(func() -> void: get_tree().change_scene_to_file(Routes.REMAP))
	col.add_child(remap)
	var hint := UI.make_label(
		"Move: WASD / Arrows / D-Pad / Left Stick   •   Interact: E / A   •   Cancel: Esc / B   •   Menu: Tab / Start",
		14)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(hint)

	# --- Buttons ---
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 16)
	col.add_child(btn_row)
	var apply := UI.make_button("Apply")
	apply.pressed.connect(_on_apply)
	btn_row.add_child(apply)
	var back := UI.make_button("Back")
	back.pressed.connect(_on_back)
	btn_row.add_child(back)

	_build_confirm_panel()
	apply.grab_focus()


func _add_slider(parent: VBoxContainer, label: String) -> HSlider:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)
	var l := UI.make_label(label, 18)
	l.custom_minimum_size = Vector2(220, 0)
	row.add_child(l)
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.custom_minimum_size = Vector2(300, 30)
	row.add_child(s)
	return s


func _add_options(parent: VBoxContainer, label: String, items: Array) -> OptionButton:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)
	var l := UI.make_label(label, 18)
	l.custom_minimum_size = Vector2(220, 0)
	row.add_child(l)
	var o := OptionButton.new()
	for item in items:
		o.add_item(str(item))
	row.add_child(o)
	return o


func _add_toggle(parent: VBoxContainer, label: String) -> CheckButton:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)
	var l := UI.make_label(label, 18)
	l.custom_minimum_size = Vector2(220, 0)
	row.add_child(l)
	var c := CheckButton.new()
	row.add_child(c)
	return c


func _load_from_settings() -> void:
	_master.value = Settings.master_volume
	_music.value = Settings.music_volume
	_sfx.value = Settings.sfx_volume
	_window_mode.selected = Settings.window_mode
	_resolution.selected = Settings.resolution_index
	_vsync.button_pressed = Settings.vsync_enabled
	_vibration.button_pressed = Settings.gamepad_vibration


func _on_apply() -> void:
	AudioManager.play_sfx(&"confirm")
	# Audio + control settings apply immediately.
	Settings.master_volume = _master.value
	Settings.music_volume = _music.value
	Settings.sfx_volume = _sfx.value
	Settings.gamepad_vibration = _vibration.button_pressed
	Settings.apply_audio()

	var new_display := {
		"window_mode": _window_mode.selected,
		"resolution_index": _resolution.selected,
		"vsync_enabled": _vsync.button_pressed,
	}
	if new_display == Settings.current_display_state():
		Settings.save_settings()
		return

	# Display changed — apply, then start the 10 second confirmation.
	_pre_apply_display = Settings.current_display_state()
	Settings.apply_display(new_display)
	_start_confirmation()


func _build_confirm_panel() -> void:
	_confirm_panel = UI.make_panel(UI.PANEL.darkened(0.1))
	_confirm_panel.set_anchors_preset(Control.PRESET_CENTER)
	_confirm_panel.visible = false
	add_child(_confirm_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	_confirm_panel.add_child(box)
	_confirm_label = UI.make_label("Keep these display settings?", 20)
	box.add_child(_confirm_label)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	box.add_child(row)
	var keep := UI.make_button("Keep")
	keep.pressed.connect(_on_keep_display)
	row.add_child(keep)
	var revert := UI.make_button("Revert")
	revert.pressed.connect(_on_revert_display)
	row.add_child(revert)

	_revert_timer = Timer.new()
	_revert_timer.wait_time = 1.0
	_revert_timer.timeout.connect(_on_countdown_tick)
	add_child(_revert_timer)
	_confirm_panel.set_meta("keep_button", keep)


func _start_confirmation() -> void:
	_countdown_left = Settings.REVERT_SECONDS
	_confirm_panel.visible = true
	_update_countdown_label()
	_revert_timer.start()
	(_confirm_panel.get_meta("keep_button") as Button).grab_focus()


func _on_countdown_tick() -> void:
	_countdown_left -= 1.0
	if _countdown_left <= 0.0:
		_on_revert_display()
	else:
		_update_countdown_label()


func _update_countdown_label() -> void:
	_confirm_label.text = "Keep these display settings?\nReverting in %d second%s..." % [
		int(_countdown_left), "" if int(_countdown_left) == 1 else "s"]


func _on_keep_display() -> void:
	AudioManager.play_sfx(&"confirm")
	_revert_timer.stop()
	_confirm_panel.visible = false
	Settings.save_settings()


func _on_revert_display() -> void:
	AudioManager.play_sfx(&"cancel")
	_revert_timer.stop()
	_confirm_panel.visible = false
	if not _pre_apply_display.is_empty():
		Settings.apply_display(_pre_apply_display)
	_load_from_settings()
	Settings.save_settings()


func _on_back() -> void:
	AudioManager.play_sfx(&"cancel")
	# Don't leave while the player still owes us a display decision.
	if _confirm_panel.visible:
		return
	if GameState.has_active_game():
		get_tree().change_scene_to_file(Routes.OVERWORLD)
	else:
		get_tree().change_scene_to_file(Routes.TITLE)
