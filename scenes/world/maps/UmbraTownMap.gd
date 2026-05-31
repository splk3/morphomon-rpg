extends TileMapWorld

const ROUTE_TO_UMBRA_SCENE := "res://scenes/world/maps/RouteToUmbra.tscn"
const ROUTE_TO_NOVA_SCENE := "res://scenes/world/maps/RouteToNova.tscn"

func _ready() -> void:
	route_id = &"umbra_town"
	display_name = "Umbra Town"
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
		"#.BBBBB...=.#####..#",
		"#.BBBBB...=.##=##..#",
		"#.BB......=.#####..#",
		"#..................#",
		"####################",
	])
	encounter_table = []
	warp_table = {
		Vector2i(1, 7): {"scene": ROUTE_TO_UMBRA_SCENE, "route": &"route_to_umbra", "cell": Vector2i(21, 7)},
		Vector2i(18, 7): {"scene": ROUTE_TO_NOVA_SCENE, "route": &"route_to_nova", "cell": Vector2i(2, 7)},
	}
	super._ready()
