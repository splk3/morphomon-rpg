extends TileMapWorld

const LUMEN_TOWN_SCENE := "res://scenes/world/maps/LumenTownMap.tscn"
const UMBRA_TOWN_SCENE := "res://scenes/world/maps/UmbraTownMap.tscn"

func _ready() -> void:
	route_id = &"route_to_umbra"
	display_name = "Lumen-Umbra Route"
	default_start_cell = Vector2i(2, 7)
	tile_rows = PackedStringArray([
		"########################",
		"#......................#",
		"#...ggggg.....gggggg...#",
		"#...ggggg..=..gggggg...#",
		"#...ggggg..=..gggggg...#",
		"#..........=....####...#",
		"#..........=....####...#",
		"#W====================W#",
		"#..........=...........#",
		"#..........=...........#",
		"#...gggggg.=###gggggg..#",
		"#...gggggg.=###gggggg..#",
		"#...gggggg..###gggggg..#",
		"#......................#",
		"########################",
	])
	encounter_table = [
		{"species_id": &"light_lion", "level_min": 24, "level_max": 31, "weight": 20},
		{"species_id": &"light_unicorn", "level_min": 25, "level_max": 32, "weight": 20},
		{"species_id": &"dark_bat", "level_min": 24, "level_max": 31, "weight": 25},
		{"species_id": &"dark_cat", "level_min": 25, "level_max": 32, "weight": 25},
		{"species_id": &"dark_ghost", "level_min": 26, "level_max": 32, "weight": 10},
	]
	warp_table = {
		Vector2i(1, 7): {"scene": LUMEN_TOWN_SCENE, "route": &"lumen_town", "cell": Vector2i(17, 7)},
		Vector2i(22, 7): {"scene": UMBRA_TOWN_SCENE, "route": &"umbra_town", "cell": Vector2i(2, 7)},
	}
	super._ready()
