extends TileMapWorld

const EMBER_TOWN_SCENE := "res://scenes/world/maps/EmberTownMap.tscn"


func _ready() -> void:
	# Route 01 data: tall-grass encounter table and a west gate warp to Ember Town.
	route_id = &"route_01"
	display_name = "Route 01"
	default_start_cell = Vector2i(2, 1)
	tile_rows = PackedStringArray([
		"########################",
		"#W====....gggg....~~~~~#",
		"#....=....gggg.....~~~~#",
		"#....=.................#",
		"#....======....gggg....#",
		"#.........=....gggg....#",
		"#..ggg....=............#",
		"#..ggg....=======......#",
		"#.........=............#",
		"#....gggg.=....gggg....#",
		"#....gggg.=....gggg....#",
		"#..........~~~~........#",
		"#..........~~~~........#",
		"#......................#",
		"########################",
	])
	encounter_table = [
		{"species_id": &"fire_lizard", "level_min": 3, "level_max": 5, "weight": 35},
		{"species_id": &"fire_moth", "level_min": 3, "level_max": 6, "weight": 30},
		{"species_id": &"normal_raccoon", "level_min": 2, "level_max": 4, "weight": 25},
		{"species_id": &"earth_scarab", "level_min": 4, "level_max": 6, "weight": 10},
	]
	warp_table = {
		Vector2i(1, 1): {"scene": EMBER_TOWN_SCENE, "route": &"ember_town", "cell": Vector2i(12, 12)},
	}
	super._ready()
