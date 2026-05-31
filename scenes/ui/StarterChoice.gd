extends Control
## The headmaster's office: choose a starter essence (plant / fire / water).

func _ready() -> void:
	UI.fill_background(self)
	AudioManager.play_music(&"title")
	_build()


func _build() -> void:
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.add_theme_constant_override("separation", 12)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(col)

	col.add_child(UI.make_title("Choose Your Starter Essence", 36))
	var prompt := UI.make_label(
		"\"Welcome! As our school's champion, pick the essence your Morphomon will master first.\"", 18)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(prompt)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 30)
	col.add_child(row)

	var first: Control = null
	for species_id in GameData.STARTER_IDS:
		var card := _make_card(species_id)
		row.add_child(card)
		if first == null:
			first = card.get_meta("focus_target")
	if first != null:
		first.grab_focus()


func _make_card(species_id: StringName) -> PanelContainer:
	var species := GameData.get_creature(species_id)
	var element: ElementType = GameData.elements[species.element]
	var panel := UI.make_panel(element.color.darkened(0.5))
	panel.custom_minimum_size = Vector2(260, 360)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)

	box.add_child(UI.make_label(element.display_name + " — " + species.display_name, 22))

	var art := Control.new()
	art.custom_minimum_size = Vector2(220, 160)
	box.add_child(art)
	var sprite := PlaceholderSprite.new()
	sprite.tint = species.tint
	sprite.body_radius = 50
	sprite.position = Vector2(110, 90)
	art.add_child(sprite)

	var desc := UI.make_label(species.description, 15)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(220, 60)
	box.add_child(desc)

	var pick := UI.make_button("Choose")
	pick.custom_minimum_size = Vector2(220, 44)
	pick.pressed.connect(_on_choose.bind(species_id))
	box.add_child(pick)

	panel.set_meta("focus_target", pick)
	return panel


func _on_choose(species_id: StringName) -> void:
	if GameState.choose_starter(species_id):
		AudioManager.play_sfx(&"transform")
		GameState.save()
		get_tree().change_scene_to_file(Routes.OVERWORLD)
