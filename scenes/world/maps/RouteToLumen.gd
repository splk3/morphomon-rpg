extends TileMapWorld

const VERDANT_TOWN_SCENE := "res://scenes/world/maps/VerdantTownMap.tscn"
const LUMEN_TOWN_SCENE := "res://scenes/world/maps/LumenTownMap.tscn"

func _ready() -> void:
	route_id = &"route_to_lumen"
	display_name = "Verdant-Lumen Route"
	default_start_cell = Vector2i(2, 7)
	tile_rows = PackedStringArray([
		"########################",
		"#......................#",
		"#...ggggg.....gggggg...#",
		"#...ggggg..=..gggggg...#",
		"#...ggggg..=..gggggg...#",
		"#....=.=.=.=.=.=.=.=...#",
		"#..........=...........#",
		"#W====================W#",
		"#..........=...........#",
		"#.....=.=.===.=.=.=.=..#",
		"#...gggggg.=...gggggg..#",
		"#...gggggg.=...gggggg..#",
		"#...gggggg.....gggggg..#",
		"#......................#",
		"########################",
	])
	encounter_table = [
		{"species_id": &"plant_frog", "level_min": 20, "level_max": 26, "weight": 20},
		{"species_id": &"plant_snail", "level_min": 21, "level_max": 27, "weight": 20},
		{"species_id": &"light_dove", "level_min": 20, "level_max": 26, "weight": 25},
		{"species_id": &"light_lamb", "level_min": 21, "level_max": 27, "weight": 25},
		{"species_id": &"light_beetle", "level_min": 22, "level_max": 27, "weight": 10},
	]
	warp_table = {
		Vector2i(1, 7): {"scene": VERDANT_TOWN_SCENE, "route": &"verdant_town", "cell": Vector2i(17, 7)},
		Vector2i(22, 7): {"scene": LUMEN_TOWN_SCENE, "route": &"lumen_town", "cell": Vector2i(2, 7)},
	}
	super._ready()
