extends Node2D
## Draws the overworld terrain grid. The parent Overworld supplies `map` (a 2D
## Array of Terrain enum values) before this node enters the tree.

const TILE := 48

# Mirror of Overworld.TERRAIN_COLOR keyed by the same int enum values.
const COLORS := {
	0: Color("6fae5a"), # GROUND
	1: Color("cda86b"), # PATH
	2: Color("3f7d3a"), # GRASS
	3: Color("3a86c8"), # WATER
	4: Color("4a4458"), # CAVE
	5: Color("245a2a"), # TREE
	6: Color("c97f4f"), # TOWN
}

var map: Array = []
var _time := 0.0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	for y in map.size():
		var row: Array = map[y]
		for x in row.size():
			var t: int = row[x]
			var rect := Rect2(x * TILE, y * TILE, TILE, TILE)
			draw_rect(rect, COLORS.get(t, Color.MAGENTA))
			match t:
				2: # tall grass blades
					_draw_grass(x, y)
				3: # water shimmer
					var shimmer := 0.08 * sin(_time * 2.0 + x + y)
					draw_rect(rect, Color(1, 1, 1, 0.06 + shimmer), false, 2.0)
				5: # tree
					draw_circle(rect.get_center(), TILE * 0.32, Color("1c4720"))
				6: # town roof accent
					draw_rect(Rect2(x * TILE, y * TILE, TILE, TILE * 0.4), Color("e85a3a"))


func _draw_grass(x: int, y: int) -> void:
	var base := Vector2(x * TILE, y * TILE)
	var sway := sin(_time * 2.0 + x * 0.7 + y) * 2.0
	for i in 3:
		var bx := base.x + 8 + i * 14
		draw_line(Vector2(bx, base.y + TILE - 4),
			Vector2(bx + sway, base.y + TILE - 20), Color("2e5e2a"), 3.0)
