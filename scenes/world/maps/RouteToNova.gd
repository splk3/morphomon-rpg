extends TileMapWorld

const UMBRA_TOWN_SCENE := "res://scenes/world/maps/UmbraTownMap.tscn"
const NOVA_TOWN_SCENE := "res://scenes/world/maps/NovaTownMap.tscn"

func _ready() -> void:
	route_id = &"route_to_nova"
	display_name = "Umbra-Nova Route"
	default_start_cell = Vector2i(2, 7)
	tile_rows = PackedStringArray([
		"########################",
		"#......................#",
		"#...ggggg.....gggggg...#",
		"#...ggggg..=..gggggg...#",
		"#...ggggg..=.=gggggg...#",
		"#....=.....=...........#",
		"#..........=...........#",
		"#W====================W#",
		"#..........=.......=...#",
		"#......=...=...........#",
		"#...gggggg.=...=ggggg..#",
		"#...gggggg.=...gggggg..#",
		"#...gggggg.....gggggg..#",
		"#......................#",
		"########################",
	])
	encounter_table = [
		{"species_id": &"dark_wolf", "level_min": 30, "level_max": 37, "weight": 20},
		{"species_id": &"dark_mushroom", "level_min": 30, "level_max": 38, "weight": 20},
		{"species_id": &"astro_owl", "level_min": 31, "level_max": 38, "weight": 25},
		{"species_id": &"astro_crab", "level_min": 31, "level_max": 38, "weight": 25},
		{"species_id": &"astro_bunny", "level_min": 32, "level_max": 38, "weight": 10},
	]
	warp_table = {
		Vector2i(1, 7): {"scene": UMBRA_TOWN_SCENE, "route": &"umbra_town", "cell": Vector2i(17, 7)},
		Vector2i(22, 7): {"scene": NOVA_TOWN_SCENE, "route": &"nova_town", "cell": Vector2i(2, 7)},
	}
	super._ready()
