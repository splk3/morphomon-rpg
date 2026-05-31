extends TileMapWorld

const ROUTE_SPROUT_EMBER_SCENE := "res://scenes/world/maps/RouteSproutEmber.tscn"

func _ready() -> void:
	route_id = &"hometown"
	display_name = "Sprout Town"
	default_start_cell = Vector2i(10, 12)
	tile_rows = PackedStringArray([
		"####################",
		"#..................#",
		"#..BBBB......BBB...#",
		"#..BBBB.=====BBB...#",
		"#..BBBB......BBB...#",
		"#.........=........#",
		"#.........=........#",
		"#=================W#",
		"#.........=........#",
		"#.........=........#",
		"#...BBB...=.BBB....#",
		"#...BBB...=.BBB....#",
		"#.........=........#",
		"#..................#",
		"####################",
	])
	encounter_table = []
	warp_table = {
		Vector2i(18, 7): {"scene": ROUTE_SPROUT_EMBER_SCENE, "route": &"route_sprout_ember", "cell": Vector2i(2, 7)},
	}
	super._ready()
