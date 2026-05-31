extends TileMapWorld

const ROUTE_TO_VOLT_SCENE := "res://scenes/world/maps/RouteToVolt.tscn"
const ROUTE_TO_BEDROCK_SCENE := "res://scenes/world/maps/RouteToBedrock.tscn"

func _ready() -> void:
	route_id = &"volt_town"
	display_name = "Volt Town"
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
		"#.........=........#",
		"#.B.BBB...=.=.=....#",
		"#.B.BBB...=..=.=...#",
		"#.B.......=.....=..#",
		"#..................#",
		"####################",
	])
	encounter_table = []
	warp_table = {
		Vector2i(1, 7): {"scene": ROUTE_TO_VOLT_SCENE, "route": &"route_to_volt", "cell": Vector2i(21, 7)},
		Vector2i(18, 7): {"scene": ROUTE_TO_BEDROCK_SCENE, "route": &"route_to_bedrock", "cell": Vector2i(2, 7)},
	}
	super._ready()
