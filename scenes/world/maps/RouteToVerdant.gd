extends TileMapWorld

const BEDROCK_TOWN_SCENE := "res://scenes/world/maps/BedrockTownMap.tscn"
const VERDANT_TOWN_SCENE := "res://scenes/world/maps/VerdantTownMap.tscn"

func _ready() -> void:
	route_id = &"route_to_verdant"
	display_name = "Bedrock-Verdant Route"
	default_start_cell = Vector2i(2, 7)
	tile_rows = PackedStringArray([
		"########################",
		"#......................#",
		"#...ggggg.....gggggg...#",
		"#...ggggg..=..gggggg...#",
		"#.ggggggg..=..gggggg...#",
		"#.gg.......=...........#",
		"#.gg.......=...........#",
		"#W====================W#",
		"#..........=...........#",
		"#..........=ggg........#",
		"#...gggggg.=ggggggggg..#",
		"#...gggggg.=ggggggggg..#",
		"#...gggggg..ggggggggg..#",
		"#......................#",
		"########################",
	])
	encounter_table = [
		{"species_id": &"earth_tortoise", "level_min": 16, "level_max": 21, "weight": 20},
		{"species_id": &"earth_golem", "level_min": 17, "level_max": 22, "weight": 20},
		{"species_id": &"plant_fox", "level_min": 16, "level_max": 21, "weight": 25},
		{"species_id": &"plant_deer", "level_min": 17, "level_max": 22, "weight": 25},
		{"species_id": &"plant_cactus", "level_min": 18, "level_max": 22, "weight": 10},
	]
	warp_table = {
		Vector2i(1, 7): {"scene": BEDROCK_TOWN_SCENE, "route": &"bedrock_town", "cell": Vector2i(17, 7)},
		Vector2i(22, 7): {"scene": VERDANT_TOWN_SCENE, "route": &"verdant_town", "cell": Vector2i(2, 7)},
	}
	super._ready()
