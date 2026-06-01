extends TileMapWorld

const ROUTE_TO_VERDANT_SCENE := "res://scenes/world/maps/RouteToVerdant.tscn"
const ROUTE_TO_LUMEN_SCENE := "res://scenes/world/maps/RouteToLumen.tscn"

func _ready() -> void:
	route_id = &"verdant_town"
	display_name = "Verdant Town"
	default_start_cell = Vector2i(10, 12)
	tile_rows = PackedStringArray([
		"####################",
		"#..................#",
		"#..BBBB......BBB...#",
		"#..BBBB......BBB...#",
		"#..BBBB......BBB...#",
		"#.........=........#",
		"#.........=........#",
		"#W================W#",
		"#.........=........#",
		"#.........=.=====..#",
		"#...BBB...=.....=..#",
		"#...BBB...=.....=..#",
		"#.........=======..#",
		"#..................#",
		"####################",
	])
	encounter_table = []
	warp_table = {
		Vector2i(1, 7): {"scene": ROUTE_TO_VERDANT_SCENE, "route": &"route_to_verdant", "cell": Vector2i(21, 7)},
		Vector2i(18, 7): {"scene": ROUTE_TO_LUMEN_SCENE, "route": &"route_to_lumen", "cell": Vector2i(2, 7)},
	}
	super._ready()
