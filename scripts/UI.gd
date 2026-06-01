class_name UI
extends RefCounted
## Small helpers to build the colorful, cartoony UI consistently in code.

const BG := Color("2b2440")
const PANEL := Color("3d335c")
const ACCENT := Color("ffd166")
const TEXT := Color("fef9ef")

## Outfit colors offered during character creation (also used for the
## overworld player sprite).
const APPEARANCES := [
	Color("ef5a3a"), Color("3aa0ef"), Color("4fb24f"),
	Color("f4d03f"), Color("8a6bff"), Color("ff7fb0"),
]


static func make_button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(260, 48)
	b.focus_mode = Control.FOCUS_ALL
	b.add_theme_font_size_override("font_size", 22)
	b.add_theme_color_override("font_color", TEXT)
	b.add_theme_color_override("font_focus_color", BG)
	b.add_theme_color_override("font_hover_color", BG)
	b.add_theme_stylebox_override("normal", _box(PANEL))
	b.add_theme_stylebox_override("hover", _box(ACCENT))
	b.add_theme_stylebox_override("focus", _box(ACCENT))
	b.add_theme_stylebox_override("pressed", _box(ACCENT.darkened(0.15)))
	return b


static func make_title(text: String, size := 56) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", ACCENT)
	return l


static func make_label(text: String, size := 20) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", TEXT)
	return l


static func make_panel(color := PANEL) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _box(color, 16))
	return p


static func fill_background(node: Control, color := BG) -> ColorRect:
	var rect := ColorRect.new()
	rect.color = color
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_child(rect)
	node.move_child(rect, 0)
	return rect


static func _box(color: Color, radius := 10) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(10)
	return sb
