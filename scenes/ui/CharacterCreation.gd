extends Control
## New-game character customization: gender, appearance and name.

var _gender := "boy"
var _appearance := 0
var _name_edit: LineEdit
var _preview: PlaceholderSprite
var _gender_label: Label


func _ready() -> void:
	UI.fill_background(self)
	AudioManager.play_music(&"title")
	_build()


func _build() -> void:
	var root := HBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 40)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(root)

	# --- Preview ---
	var preview_box := UI.make_panel()
	preview_box.custom_minimum_size = Vector2(260, 360)
	root.add_child(preview_box)
	var pv := Control.new()
	preview_box.add_child(pv)
	_preview = PlaceholderSprite.new()
	_preview.kind = PlaceholderSprite.Kind.PERSON
	_preview.body_radius = 60
	_preview.position = Vector2(110, 200)
	_preview.tint = UI.APPEARANCES[_appearance]
	pv.add_child(_preview)

	# --- Controls ---
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	root.add_child(col)

	col.add_child(UI.make_title("Create Your Hero", 36))

	col.add_child(UI.make_label("Gender", 20))
	var gender_row := HBoxContainer.new()
	gender_row.add_theme_constant_override("separation", 10)
	col.add_child(gender_row)
	_gender_label = UI.make_label("Boy", 20)
	var prev_g := UI.make_button("<")
	prev_g.custom_minimum_size = Vector2(60, 40)
	prev_g.pressed.connect(_toggle_gender)
	var next_g := UI.make_button(">")
	next_g.custom_minimum_size = Vector2(60, 40)
	next_g.pressed.connect(_toggle_gender)
	gender_row.add_child(prev_g)
	gender_row.add_child(_gender_label)
	gender_row.add_child(next_g)

	col.add_child(UI.make_label("Look", 20))
	var look_row := HBoxContainer.new()
	look_row.add_theme_constant_override("separation", 10)
	col.add_child(look_row)
	var prev_a := UI.make_button("<")
	prev_a.custom_minimum_size = Vector2(60, 40)
	prev_a.pressed.connect(_cycle_appearance.bind(-1))
	var next_a := UI.make_button(">")
	next_a.custom_minimum_size = Vector2(60, 40)
	next_a.pressed.connect(_cycle_appearance.bind(1))
	look_row.add_child(prev_a)
	look_row.add_child(UI.make_label("Outfit color", 18))
	look_row.add_child(next_a)

	col.add_child(UI.make_label("Name", 20))
	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "Enter a name..."
	_name_edit.max_length = 12
	_name_edit.custom_minimum_size = Vector2(260, 44)
	_name_edit.text = "Robin"
	col.add_child(_name_edit)

	var confirm := UI.make_button("Begin Adventure")
	confirm.pressed.connect(_on_confirm)
	col.add_child(confirm)

	var back := UI.make_button("Back")
	back.pressed.connect(func() -> void:
		AudioManager.play_sfx(&"cancel")
		get_tree().change_scene_to_file(Routes.SAVE_SELECT))
	col.add_child(back)

	_name_edit.grab_focus()


func _toggle_gender() -> void:
	AudioManager.play_sfx(&"select")
	_gender = "girl" if _gender == "boy" else "boy"
	_gender_label.text = "Girl" if _gender == "girl" else "Boy"


func _cycle_appearance(dir: int) -> void:
	AudioManager.play_sfx(&"select")
	_appearance = wrapi(_appearance + dir, 0, UI.APPEARANCES.size())
	_preview.tint = UI.APPEARANCES[_appearance]


func _on_confirm() -> void:
	var chosen_name := _name_edit.text.strip_edges()
	if chosen_name.is_empty():
		chosen_name = "Robin"
	AudioManager.play_sfx(&"confirm")
	GameState.start_new_game(GameState.current_slot, chosen_name, _gender, _appearance)
	GameState.save()
	get_tree().change_scene_to_file(Routes.STARTER_CHOICE)
