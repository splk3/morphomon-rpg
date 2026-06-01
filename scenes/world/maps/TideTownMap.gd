extends TileMapWorld

const ROUTE_TO_TIDE_SCENE := "res://scenes/world/maps/RouteToTide.tscn"
const ROUTE_TO_VOLT_SCENE := "res://scenes/world/maps/RouteToVolt.tscn"

func _ready() -> void:
	route_id = &"tide_town"
	display_name = "Tide Town"
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
		"#.........=.======.#",
		"#...BBB...=.~~~~~~.#",
		"#...BBB...=.~~~~~~.#",
		"#.........=.~~~~~~.#",
		"#..................#",
		"####################",
	])
	encounter_table = []
	warp_table = {
		Vector2i(1, 7): {"scene": ROUTE_TO_TIDE_SCENE, "route": &"route_to_tide", "cell": Vector2i(21, 7)},
		Vector2i(18, 7): {"scene": ROUTE_TO_VOLT_SCENE, "route": &"route_to_volt", "cell": Vector2i(2, 7)},
	}
	super._ready()
