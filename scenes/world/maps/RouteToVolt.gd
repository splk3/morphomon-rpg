extends TileMapWorld

const TIDE_TOWN_SCENE := "res://scenes/world/maps/TideTownMap.tscn"
const VOLT_TOWN_SCENE := "res://scenes/world/maps/VoltTownMap.tscn"

func _ready() -> void:
	route_id = &"route_to_volt"
	display_name = "Tide-Volt Route"
	default_start_cell = Vector2i(2, 7)
	tile_rows = PackedStringArray([
		"########################",
		"#......................#",
		"#...ggggg.....gggggg...#",
		"#...ggggg..=..gggggg...#",
		"#...ggggg..=..gggggg...#",
		"#.....=....=.=.........#",
		"#.......=..=....=......#",
		"#W====================W#",
		"#..........=......=....#",
		"#..........=...........#",
		"#...gggggg.=...gggggg..#",
		"#...gggggg.=...gggggg..#",
		"#...gggggg.....gggggg..#",
		"#......................#",
		"########################",
	])
	encounter_table = [
		{"species_id": &"water_octopus", "level_min": 8, "level_max": 12, "weight": 20},
		{"species_id": &"water_penguin", "level_min": 8, "level_max": 13, "weight": 20},
		{"species_id": &"electric_mouse", "level_min": 9, "level_max": 13, "weight": 25},
		{"species_id": &"electric_beetle", "level_min": 9, "level_max": 13, "weight": 25},
		{"species_id": &"electric_eel", "level_min": 10, "level_max": 13, "weight": 10},
	]
	warp_table = {
		Vector2i(1, 7): {"scene": TIDE_TOWN_SCENE, "route": &"tide_town", "cell": Vector2i(17, 7)},
		Vector2i(22, 7): {"scene": VOLT_TOWN_SCENE, "route": &"volt_town", "cell": Vector2i(2, 7)},
	}
	super._ready()
