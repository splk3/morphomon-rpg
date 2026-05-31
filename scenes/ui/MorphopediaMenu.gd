class_name MorphopediaMenu
extends CanvasLayer
## Rich modal Morphopedia browser with discovery gating and creature detail pages.

signal closed

const CARD_SIZE := Vector2(220, 190)

var _root: Control
var _content: VBoxContainer
var _first_focus: Control
var _showing_detail := false


func _ready() -> void:
	layer = 45
	_build_shell()
	_show_grid()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") or event.is_action_pressed("open_menu"):
		get_viewport().set_input_as_handled()
		if _showing_detail:
			_show_grid()
		else:
			_close()


func _build_shell() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.62)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(center)

	var panel := UI.make_panel()
	panel.custom_minimum_size = Vector2(900, 650)
	center.add_child(panel)

	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 12)
	panel.add_child(_content)


func _clear() -> void:
	_first_focus = null
	for child in _content.get_children():
		child.queue_free()


func _title(text: String) -> void:
	_content.add_child(UI.make_title(text, 34))


func _button(text: String, cb: Callable, focus := false) -> Button:
	var button := UI.make_button(text)
	button.pressed.connect(func() -> void:
		AudioManager.play_sfx(&"select")
		cb.call())
	_content.add_child(button)
	if focus:
		button.call_deferred("grab_focus")
	return button


func _show_grid() -> void:
	_showing_detail = false
	_clear()
	_title("Morphopedia")

	var discovered := _discovered_set()
	var total := GameData.creatures.size()
	_content.add_child(UI.make_label("Discovered %d / %d species" % [_discovered_count(discovered), total], 18))

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(860, 500)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.add_child(scroll)

	var sections := VBoxContainer.new()
	sections.add_theme_constant_override("separation", 14)
	sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(sections)

	for element_id in GameData.ELEMENT_IDS:
		var species_list := _species_for_element(element_id)
		if species_list.is_empty():
			continue
		var element: ElementType = GameData.elements.get(element_id, null)
		var section_name := String(element_id)
		var section_color := UI.ACCENT
		if element != null:
			section_name = element.display_name
			section_color = element.color
		sections.add_child(_make_section_title(section_name, section_color))
		var grid := GridContainer.new()
		grid.columns = 3
		grid.add_theme_constant_override("h_separation", 12)
		grid.add_theme_constant_override("v_separation", 12)
		sections.add_child(grid)
		for species in species_list:
			var is_discovered := discovered.has(species.id)
			var card := _make_entry_card(species, is_discovered)
			grid.add_child(card)
			if _first_focus == null:
				_first_focus = card

	_button("Back", _close, _first_focus == null)
	if _first_focus != null:
		_first_focus.call_deferred("grab_focus")


func _show_detail(species_id: StringName) -> void:
	_showing_detail = true
	_clear()

	var species := GameData.get_creature(species_id)
	var discovered := _discovered_set()
	if species == null:
		_title("Morphopedia")
		_content.add_child(UI.make_label("Unknown species.", 18))
		_button("Back", _show_grid, true)
		return

	var is_discovered := discovered.has(species.id)
	_title(species.display_name if is_discovered else "???")

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(860, 500)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.add_child(scroll)

	var detail := VBoxContainer.new()
	detail.add_theme_constant_override("separation", 14)
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(detail)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 18)
	detail.add_child(top)
	top.add_child(_make_art(species, is_discovered, Vector2(220, 180), 70.0))

	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 10)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(info)

	if not is_discovered:
		info.add_child(UI.make_label("Not yet discovered.", 22))
		info.add_child(_make_wrapped_label("Scan this Morphomon in the wild to reveal its lore, stats, and habitat clues.", 16, 560))
		_button("Back", _show_grid, true)
		return

	var element: ElementType = GameData.elements.get(species.element, null)
	if element != null:
		info.add_child(_make_badge(element.display_name, element.color, 20))
	info.add_child(_make_wrapped_label(species.description, 17, 560))
	info.add_child(UI.make_label("Scan difficulty: %s" % _scan_difficulty(species.scan_resistance), 18))
	info.add_child(UI.make_label("Where found: %s" % _where_found(species), 18))

	var stats_title := UI.make_label("Base Stats", 22)
	detail.add_child(stats_title)
	var stats := GridContainer.new()
	stats.columns = 4
	stats.add_theme_constant_override("h_separation", 12)
	detail.add_child(stats)
	stats.add_child(_make_stat_panel("HP", species.base_hp, Color("ef476f")))
	stats.add_child(_make_stat_panel("ATK", species.base_attack, Color("ffd166")))
	stats.add_child(_make_stat_panel("DEF", species.base_defense, Color("06d6a0")))
	stats.add_child(_make_stat_panel("SPD", species.base_speed, Color("118ab2")))

	_button("Back", _show_grid, true)


func _make_entry_card(species: CreatureSpecies, discovered: bool) -> Button:
	var element: ElementType = GameData.elements.get(species.element, null)
	var tint := species.tint if discovered else Color(0.05, 0.06, 0.08)
	var normal_color := UI.PANEL.darkened(0.35)
	if discovered and element != null:
		normal_color = element.color.darkened(0.55)

	var button := Button.new()
	button.custom_minimum_size = CARD_SIZE
	button.focus_mode = Control.FOCUS_ALL
	button.text = ""
	button.add_theme_stylebox_override("normal", _box(normal_color, 14))
	button.add_theme_stylebox_override("hover", _box(UI.ACCENT.darkened(0.1), 14))
	button.add_theme_stylebox_override("focus", _box(UI.ACCENT, 14))
	button.add_theme_stylebox_override("pressed", _box(UI.ACCENT.darkened(0.2), 14))
	button.pressed.connect(func() -> void:
		AudioManager.play_sfx(&"select")
		_show_detail(species.id))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	button.add_child(margin)

	var box_container := VBoxContainer.new()
	box_container.add_theme_constant_override("separation", 6)
	box_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(box_container)

	box_container.add_child(_make_art_with_tint(tint, Vector2(190, 92), 36.0))
	var name_label := UI.make_label(species.display_name if discovered else "???", 19)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box_container.add_child(name_label)
	if discovered and element != null:
		var badge := _make_badge(element.display_name, element.color, 14)
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box_container.add_child(badge)
	else:
		var unknown := UI.make_label("Undiscovered", 14)
		unknown.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		unknown.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box_container.add_child(unknown)

	return button


func _make_art(species: CreatureSpecies, discovered: bool, min_size: Vector2, radius: float) -> Control:
	return _make_art_with_tint(species.tint if discovered else Color(0.05, 0.06, 0.08), min_size, radius)


func _make_art_with_tint(tint: Color, min_size: Vector2, radius: float) -> Control:
	var art := Control.new()
	art.custom_minimum_size = min_size
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sprite := PlaceholderSprite.new()
	sprite.kind = PlaceholderSprite.Kind.CREATURE
	sprite.tint = tint
	sprite.body_radius = radius
	sprite.position = min_size * 0.5 + Vector2(0, 8)
	art.add_child(sprite)
	return art


func _make_section_title(text: String, color: Color) -> Label:
	var label := UI.make_label(text, 24)
	label.add_theme_color_override("font_color", color.lightened(0.2))
	return label


func _make_badge(text: String, color: Color, size: int) -> Label:
	var badge := UI.make_label(text, size)
	badge.add_theme_color_override("font_color", UI.BG)
	badge.add_theme_stylebox_override("normal", _box(color, 12))
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return badge


func _make_wrapped_label(text: String, size: int, width: float) -> Label:
	var label := UI.make_label(text, size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(width, 0)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


func _make_stat_panel(label_text: String, value: int, color: Color) -> PanelContainer:
	var panel := UI.make_panel(color.darkened(0.45))
	panel.custom_minimum_size = Vector2(190, 86)
	var box_container := VBoxContainer.new()
	box_container.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(box_container)
	var label := UI.make_label(label_text, 16)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box_container.add_child(label)
	var number := UI.make_label(str(value), 28)
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box_container.add_child(number)
	return panel


func _species_for_element(element_id: StringName) -> Array[CreatureSpecies]:
	var out: Array[CreatureSpecies] = []
	for creature in GameData.creatures_of_element(element_id):
		if creature is CreatureSpecies:
			out.append(creature)
	out.sort_custom(func(a: CreatureSpecies, b: CreatureSpecies) -> bool:
		return a.display_name.to_lower() < b.display_name.to_lower())
	return out


func _discovered_set() -> Dictionary:
	var out := {}
	if GameState.data == null:
		return out
	for id in GameState.data.morphopedia:
		out[StringName(id)] = true
	return out


func _discovered_count(discovered: Dictionary) -> int:
	var count := 0
	for id in discovered.keys():
		if GameData.creatures.has(id):
			count += 1
	return count


func _scan_difficulty(scan_resistance: float) -> String:
	if scan_resistance < 0.34:
		return "Low"
	if scan_resistance < 0.67:
		return "Medium"
	return "High"


func _where_found(species: CreatureSpecies) -> String:
	if species.element == &"normal":
		return "Common across many areas"
	var towns: Array[String] = []
	for town in GameData.towns_ordered:
		if town.element == species.element:
			towns.append(town.display_name)
	if towns.is_empty():
		return "Habitat unknown"
	return ", ".join(towns)


func _box(color: Color, radius := 10) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(8)
	return style


func _close() -> void:
	AudioManager.play_sfx(&"cancel")
	closed.emit()
	queue_free()
