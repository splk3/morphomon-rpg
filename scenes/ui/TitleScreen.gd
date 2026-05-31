extends Control
## Main menu. The game boots here.

func _ready() -> void:
	UI.fill_background(self)
	AudioManager.play_music(&"title")

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 14)
	center.add_child(col)

	var title := UI.make_title("MORPHOMON")
	col.add_child(title)
	var subtitle := UI.make_label("Scan • Transform • Adventure", 22)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	col.add_child(spacer)

	var play := UI.make_button("Play")
	play.pressed.connect(_on_play)
	col.add_child(play)

	var settings := UI.make_button("Settings")
	settings.pressed.connect(_on_settings)
	col.add_child(settings)

	var quit := UI.make_button("Quit")
	quit.pressed.connect(_on_quit)
	col.add_child(quit)

	play.grab_focus()


func _on_play() -> void:
	AudioManager.play_sfx(&"confirm")
	get_tree().change_scene_to_file(Routes.SAVE_SELECT)


func _on_settings() -> void:
	AudioManager.play_sfx(&"confirm")
	get_tree().change_scene_to_file(Routes.SETTINGS)


func _on_quit() -> void:
	AudioManager.play_sfx(&"cancel")
	get_tree().quit()
