extends TileMapWorld

const VOLT_TOWN_SCENE := "res://scenes/world/maps/VoltTownMap.tscn"
const BEDROCK_TOWN_SCENE := "res://scenes/world/maps/BedrockTownMap.tscn"

func _ready() -> void:
	route_id = &"route_to_bedrock"
	display_name = "Volt-Bedrock Route"
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
		"#.##.......=...........#",
		"#.##gggggg.=...gggggg..#",
		"#...gggggg.=...gggggg..#",
		"#...gggggg.....gggggg..#",
		"#......................#",
		"########################",
	])
	encounter_table = [
		{"species_id": &"electric_drone", "level_min": 12, "level_max": 16, "weight": 20},
		{"species_id": &"electric_ram", "level_min": 13, "level_max": 17, "weight": 20},
		{"species_id": &"earth_scarab", "level_min": 12, "level_max": 16, "weight": 25},
		{"species_id": &"earth_coyote", "level_min": 13, "level_max": 17, "weight": 25},
		{"species_id": &"earth_armadillo", "level_min": 14, "level_max": 17, "weight": 10},
	]
	warp_table = {
		Vector2i(1, 7): {"scene": VOLT_TOWN_SCENE, "route": &"volt_town", "cell": Vector2i(17, 7)},
		Vector2i(22, 7): {"scene": BEDROCK_TOWN_SCENE, "route": &"bedrock_town", "cell": Vector2i(2, 7)},
	}
	super._ready()
