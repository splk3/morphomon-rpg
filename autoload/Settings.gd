extends Node
## Persistent user settings (audio, graphics, controls). Registered as `Settings`.
##
## Display changes (window mode / resolution / vsync) are applied through
## [method apply_display], which the settings menu pairs with a 10 second
## "keep these settings?" confirmation so a bad choice auto-reverts.

const CONFIG_PATH := "user://settings.cfg"
const REVERT_SECONDS := 10.0

const WINDOW_MODES := ["Windowed", "Fullscreen", "Borderless"]
const RESOLUTIONS := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]

signal settings_changed

# --- Audio (linear 0..1) ---
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 0.9

# --- Graphics ---
var window_mode: int = 0          # index into WINDOW_MODES
var resolution_index: int = 0     # index into RESOLUTIONS
var vsync_enabled: bool = true

# --- Controls ---
## Player-remapped input events keyed by action name (serialized form).
var custom_bindings: Dictionary = {}
var gamepad_vibration: bool = true

# --- Gameplay ---
var autosave_enabled: bool = true


func _ready() -> void:
	load_settings()
	apply_audio()
	apply_display()


# ---------------------------------------------------------------- audio
func apply_audio() -> void:
	_set_bus_volume("Master", master_volume)
	_set_bus_volume("Music", music_volume)
	_set_bus_volume("SFX", sfx_volume)
	settings_changed.emit()


func _set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return
	AudioServer.set_bus_volume_db(idx, linear_to_db(clampf(linear, 0.0, 1.0)))
	AudioServer.set_bus_mute(idx, linear <= 0.001)


# -------------------------------------------------------------- graphics
func current_display_state() -> Dictionary:
	return {
		"window_mode": window_mode,
		"resolution_index": resolution_index,
		"vsync_enabled": vsync_enabled,
	}


func apply_display(state: Dictionary = {}) -> void:
	if not state.is_empty():
		window_mode = int(state.get("window_mode", window_mode))
		resolution_index = int(state.get("resolution_index", resolution_index))
		vsync_enabled = bool(state.get("vsync_enabled", vsync_enabled))

	var win := get_window()
	if win == null:
		return
	match window_mode:
		1: # Fullscreen
			win.mode = Window.MODE_FULLSCREEN
			win.borderless = false
		2: # Borderless fullscreen
			win.mode = Window.MODE_FULLSCREEN
			win.borderless = true
		_: # Windowed
			win.mode = Window.MODE_WINDOWED
			win.borderless = false
			var res: Vector2i = RESOLUTIONS[clampi(resolution_index, 0, RESOLUTIONS.size() - 1)]
			win.size = res

	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED
	)
	settings_changed.emit()


# -------------------------------------------------------------- controls
func apply_bindings() -> void:
	for action in custom_bindings.keys():
		if not InputMap.has_action(action):
			continue
		InputMap.action_erase_events(action)
		for ev_dict in custom_bindings[action]:
			var ev := _event_from_dict(ev_dict)
			if ev != null:
				InputMap.action_add_event(action, ev)


func _event_from_dict(d: Dictionary) -> InputEvent:
	match d.get("type", ""):
		"key":
			var k := InputEventKey.new()
			k.physical_keycode = int(d.get("keycode", 0))
			return k
		"button":
			var b := InputEventJoypadButton.new()
			b.button_index = int(d.get("button_index", 0))
			return b
		"motion":
			var m := InputEventJoypadMotion.new()
			m.axis = int(d.get("axis", 0))
			m.axis_value = float(d.get("axis_value", 1.0))
			return m
	return null


# ----------------------------------------------------------- gamepad rumble
## Starts gamepad vibration, honoring the [member gamepad_vibration] preference.
## Magnitudes are 0..1; duration is in seconds. Safe to call when no pad exists.
func rumble(weak: float = 0.5, strong: float = 0.5, duration: float = 0.2, device: int = 0) -> void:
	if not gamepad_vibration:
		return
	Input.start_joy_vibration(device, clampf(weak, 0.0, 1.0), clampf(strong, 0.0, 1.0), duration)


func stop_rumble(device: int = 0) -> void:
	Input.stop_joy_vibration(device)


# ------------------------------------------------------------ persistence
func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", master_volume)
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("graphics", "window_mode", window_mode)
	cfg.set_value("graphics", "resolution_index", resolution_index)
	cfg.set_value("graphics", "vsync", vsync_enabled)
	cfg.set_value("controls", "bindings", custom_bindings)
	cfg.set_value("controls", "gamepad_vibration", gamepad_vibration)
	cfg.set_value("gameplay", "autosave", autosave_enabled)
	cfg.save(CONFIG_PATH)


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) != OK:
		return
	master_volume = cfg.get_value("audio", "master", master_volume)
	music_volume = cfg.get_value("audio", "music", music_volume)
	sfx_volume = cfg.get_value("audio", "sfx", sfx_volume)
	window_mode = cfg.get_value("graphics", "window_mode", window_mode)
	resolution_index = cfg.get_value("graphics", "resolution_index", resolution_index)
	vsync_enabled = cfg.get_value("graphics", "vsync", vsync_enabled)
	custom_bindings = cfg.get_value("controls", "bindings", {})
	gamepad_vibration = cfg.get_value("controls", "gamepad_vibration", true)
	autosave_enabled = cfg.get_value("gameplay", "autosave", true)
	apply_bindings()
