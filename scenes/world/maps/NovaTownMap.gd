extends TileMapWorld

const ROUTE_TO_NOVA_SCENE := "res://scenes/world/maps/RouteToNova.tscn"

func _ready() -> void:
	route_id = &"nova_town"
	display_name = "Nova Town"
	default_start_cell = Vector2i(10, 12)
	tile_rows = PackedStringArray([
		"####################",
		"#..................#",
		"#..BBBB......BBB...#",
		"#..BBBB......BBB...#",
		"#..BBBB......BBB...#",
		"#.........=........#",
		"#.........=........#",
		"#W=================#",
		"#.........=........#",
		"#.........=........#",
		"#.BBBBB...=.=.=.=..#",
		"#.BBBBB...=........#",
		"#.........=..=.=...#",
		"#..................#",
		"####################",
	])
	encounter_table = []
	warp_table = {
		Vector2i(1, 7): {"scene": ROUTE_TO_NOVA_SCENE, "route": &"route_to_nova", "cell": Vector2i(21, 7)},
	}
	super._ready()
