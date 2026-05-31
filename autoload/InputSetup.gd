extends Node
## Registers gameplay input actions for keyboard and for Xbox / PlayStation
## gamepads. Runs first (before Settings) so custom bindings can layer on top.
## Registered as the `InputSetup` autoload.
##
## Godot maps controllers through SDL, so button index 0 is A/Cross, 1 is
## B/Circle, etc. — a single mapping therefore covers both Xbox and PlayStation
## pads. Menus reuse Godot's built-in ui_* actions (already keyboard + joypad).

func _ready() -> void:
	_action(&"move_up", [KEY_W, KEY_UP], [JOY_BUTTON_DPAD_UP], JOY_AXIS_LEFT_Y, -1.0)
	_action(&"move_down", [KEY_S, KEY_DOWN], [JOY_BUTTON_DPAD_DOWN], JOY_AXIS_LEFT_Y, 1.0)
	_action(&"move_left", [KEY_A, KEY_LEFT], [JOY_BUTTON_DPAD_LEFT], JOY_AXIS_LEFT_X, -1.0)
	_action(&"move_right", [KEY_D, KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT], JOY_AXIS_LEFT_X, 1.0)
	_action(&"interact", [KEY_E, KEY_ENTER, KEY_SPACE], [JOY_BUTTON_A])
	_action(&"cancel", [KEY_ESCAPE, KEY_BACKSPACE], [JOY_BUTTON_B])
	_action(&"run", [KEY_SHIFT], [JOY_BUTTON_X])
	_action(&"open_menu", [KEY_TAB], [JOY_BUTTON_START, JOY_BUTTON_Y])
	_action(&"scan", [KEY_Q], [JOY_BUTTON_RIGHT_SHOULDER])


func _action(name: StringName, keys: Array, buttons: Array, axis: int = -1, axis_value: float = 0.0) -> void:
	if not InputMap.has_action(name):
		InputMap.add_action(name)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(name, ev)
	for b in buttons:
		var jb := InputEventJoypadButton.new()
		jb.button_index = b
		InputMap.action_add_event(name, jb)
	if axis >= 0:
		var jm := InputEventJoypadMotion.new()
		jm.axis = axis
		jm.axis_value = axis_value
		InputMap.action_add_event(name, jm)
