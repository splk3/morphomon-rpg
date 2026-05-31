extends TileMapWorld

const ROUTE_01_SCENE := "res://scenes/world/maps/Route01Map.tscn"
const ROUTE_SPROUT_EMBER_SCENE := "res://scenes/world/maps/RouteSproutEmber.tscn"
const ROUTE_TO_TIDE_SCENE := "res://scenes/world/maps/RouteToTide.tscn"


func _ready() -> void:
	# Ember Town data: compact town layout plus west, east, and south gate warps.
	route_id = &"ember_town"
	display_name = "Ember Town"
	default_start_cell = Vector2i(12, 12)
	tile_rows = PackedStringArray([
		"####################",
		"#......B.....B.....#",
		"#..BBBBB.....B.....#",
		"#..B...B...........#",
		"#..BBBBB....~~~....#",
		"#..........~~~~~...#",
		"#....=====.........#",
		"#W...=...=........W#",
		"#....=...=..BB.....#",
		"#....=====..BB.....#",
		"#..........====....#",
		"#............=.....#",
		"#............=.....#",
		"#...........W......#",
		"####################",
	])
	encounter_table = []
	warp_table = {
		Vector2i(1, 7): {"scene": ROUTE_SPROUT_EMBER_SCENE, "route": &"route_sprout_ember", "cell": Vector2i(21, 7)},
		Vector2i(18, 7): {"scene": ROUTE_TO_TIDE_SCENE, "route": &"route_to_tide", "cell": Vector2i(2, 7)},
		Vector2i(12, 13): {"scene": ROUTE_01_SCENE, "route": &"route_01", "cell": Vector2i(2, 1)},
	}
	super._ready()
