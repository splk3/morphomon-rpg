class_name PlaceholderSprite
extends Node2D
## A code-drawn, cartoony placeholder figure used for creatures and characters
## until hand-drawn sprite sheets are added. It animates procedurally (idle bob,
## blink, wobble) so the world feels alive without binary art assets.

enum Kind { CREATURE, PERSON, CUBE }

@export var tint: Color = Color.WHITE:
	set(value):
		tint = value
		queue_redraw()
@export var kind: Kind = Kind.CREATURE
@export var body_radius: float = 20.0
@export var facing: int = 1   # 1 = right, -1 = left

var _time := 0.0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	match kind:
		Kind.PERSON:
			_draw_person()
		Kind.CUBE:
			_draw_cube()
		_:
			_draw_creature()


func _draw_creature() -> void:
	var bob := sin(_time * 3.0) * 3.0
	var squash := 1.0 + sin(_time * 3.0) * 0.05
	var center := Vector2(0, bob)
	# shadow
	draw_ellipse_filled(Vector2(0, body_radius * 0.9), body_radius * 0.8, body_radius * 0.25, Color(0, 0, 0, 0.2))
	# body
	draw_ellipse_filled(center, body_radius * facing, body_radius * squash, tint)
	draw_ellipse_filled(center, body_radius * facing, body_radius * squash, tint.darkened(0.25), false, 3.0)
	# belly highlight
	draw_ellipse_filled(center + Vector2(0, body_radius * 0.25), body_radius * 0.5, body_radius * 0.45, tint.lightened(0.35))
	# eyes (blink)
	var blink := 1.0 if fmod(_time, 3.0) > 0.12 else 0.15
	var eye_y := center.y - body_radius * 0.2
	for sx in [-0.4, 0.4]:
		var ep := Vector2(sx * body_radius, eye_y)
		draw_ellipse_filled(ep, body_radius * 0.16, body_radius * 0.2 * blink, Color.WHITE)
		draw_ellipse_filled(ep + Vector2(facing * 1.5, 0), body_radius * 0.08, body_radius * 0.1 * blink, Color.BLACK)
	# cheeks
	for sx in [-0.55, 0.55]:
		draw_ellipse_filled(Vector2(sx * body_radius, eye_y + body_radius * 0.25), body_radius * 0.12, body_radius * 0.09, Color(1, 0.5, 0.5, 0.5))


func _draw_person() -> void:
	var bob := sin(_time * 4.0) * 2.0
	var center := Vector2(0, bob)
	draw_ellipse_filled(Vector2(0, body_radius * 1.1), body_radius * 0.7, body_radius * 0.22, Color(0, 0, 0, 0.2))
	# body
	draw_rect(Rect2(center + Vector2(-body_radius * 0.5, -body_radius * 0.1), Vector2(body_radius, body_radius)), tint)
	# head
	var head := center + Vector2(0, -body_radius * 0.7)
	draw_ellipse_filled(head, body_radius * 0.45, body_radius * 0.45, Color("f3c79a"))
	# hair cap
	draw_ellipse_filled(head + Vector2(0, -body_radius * 0.12), body_radius * 0.46, body_radius * 0.3, tint.darkened(0.3))
	# eyes
	for sx in [-0.18, 0.18]:
		draw_ellipse_filled(head + Vector2(sx * body_radius * facing, 0), body_radius * 0.06, body_radius * 0.08, Color.BLACK)


func _draw_cube() -> void:
	var spin := sin(_time * 2.0) * 0.15
	var s := body_radius
	var pts := PackedVector2Array([
		Vector2(-s, -s).rotated(spin), Vector2(s, -s).rotated(spin),
		Vector2(s, s).rotated(spin), Vector2(-s, s).rotated(spin),
	])
	draw_colored_polygon(pts, tint)
	draw_polyline(pts + PackedVector2Array([pts[0]]), tint.darkened(0.3), 3.0)


## Filled ellipse helper (Godot has no built-in filled ellipse primitive).
func draw_ellipse_filled(c: Vector2, rx: float, ry: float, color: Color, filled := true, width := 1.0) -> void:
	var pts := PackedVector2Array()
	var steps := 24
	for i in steps + 1:
		var a := TAU * float(i) / float(steps)
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	if filled:
		draw_colored_polygon(pts, color)
	else:
		draw_polyline(pts, color, width)
