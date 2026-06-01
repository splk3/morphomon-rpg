extends CanvasLayer
## Reusable text chat-bubble used for dialogue, narration and cutscenes.
## Show a sequence of lines; the player advances with "interact". A typewriter
## effect reveals each line one character at a time.

signal finished

const REVEAL_SPEED := 45.0  # characters per second

var _lines: Array = []
var _index := 0
var _revealed := 0.0
var _panel: PanelContainer
var _label: RichTextLabel
var _speaker_label: Label
var _hint: Label
var _active := false


func _ready() -> void:
	layer = 50
	_build()
	hide_bubble()


func _build() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	margin.offset_top = -180
	margin.offset_bottom = -20
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 40)
	add_child(margin)

	_panel = UI.make_panel(UI.PANEL)
	margin.add_child(_panel)
	var box := VBoxContainer.new()
	_panel.add_child(box)
	_speaker_label = UI.make_label("", 18)
	_speaker_label.add_theme_color_override("font_color", UI.ACCENT)
	box.add_child(_speaker_label)

	_label = RichTextLabel.new()
	_label.bbcode_enabled = true
	_label.fit_content = true
	_label.scroll_active = false
	_label.custom_minimum_size = Vector2(0, 80)
	_label.add_theme_font_size_override("normal_font_size", 22)
	box.add_child(_label)

	_hint = UI.make_label("▼ interact", 14)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	box.add_child(_hint)


## lines: Array of either String, or { "speaker": String, "text": String }.
func show_lines(lines: Array) -> void:
	_lines = lines
	_index = 0
	_active = true
	_panel.get_parent().visible = true
	_show_current()


func hide_bubble() -> void:
	_active = false
	_panel.get_parent().visible = false


func is_active() -> bool:
	return _active


func _show_current() -> void:
	var entry: Variant = _lines[_index]
	var speaker := ""
	var text := ""
	if entry is Dictionary:
		speaker = entry.get("speaker", "")
		text = entry.get("text", "")
	else:
		text = str(entry)
	_speaker_label.text = speaker
	_speaker_label.visible = not speaker.is_empty()
	_label.text = text
	_label.visible_characters = 0
	_revealed = 0.0
	_hint.visible = false


func _process(delta: float) -> void:
	if not _active:
		return
	if _label.visible_characters < _label.get_total_character_count():
		_revealed += delta * REVEAL_SPEED
		_label.visible_characters = int(_revealed)
		if _label.visible_characters >= _label.get_total_character_count():
			_hint.visible = true
	else:
		_hint.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	if event.is_action_pressed("cancel") or event.is_action_pressed("ui_cancel"):
		# Cancel/back dismisses the whole conversation without advancing.
		get_viewport().set_input_as_handled()
		AudioManager.play_sfx(&"cancel")
		hide_bubble()
		finished.emit()
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if _label.visible_characters < _label.get_total_character_count():
			# Reveal the whole line instantly on first press.
			_label.visible_characters = _label.get_total_character_count()
			_hint.visible = true
			return
		AudioManager.play_sfx(&"select")
		_index += 1
		if _index >= _lines.size():
			hide_bubble()
			finished.emit()
		else:
			_show_current()
