extends TileMapWorld

const EMBER_TOWN_SCENE := "res://scenes/world/maps/EmberTownMap.tscn"
const TIDE_TOWN_SCENE := "res://scenes/world/maps/TideTownMap.tscn"

func _ready() -> void:
	route_id = &"route_to_tide"
	display_name = "Ember-Tide Route"
	default_start_cell = Vector2i(2, 7)
	tile_rows = PackedStringArray([
		"########################",
		"#......................#",
		"#...ggggg.....gggggg...#",
		"#...ggggg..=..gggggg...#",
		"#...ggggg..=..gggggg...#",
		"#..........=.....~~~~..#",
		"#..........=.....~~~~..#",
		"#W====================W#",
		"#..........=...........#",
		"#..........=...........#",
		"#...gggggg.=...gggggg..#",
		"#.~~gggggg.=...gggggg..#",
		"#.~~gggggg.....gggggg..#",
		"#......................#",
		"########################",
	])
	encounter_table = [
		{"species_id": &"fire_turtle", "level_min": 5, "level_max": 8, "weight": 20},
		{"species_id": &"fire_boar", "level_min": 6, "level_max": 9, "weight": 20},
		{"species_id": &"water_otter", "level_min": 5, "level_max": 8, "weight": 25},
		{"species_id": &"water_crane", "level_min": 6, "level_max": 9, "weight": 25},
		{"species_id": &"water_penguin", "level_min": 7, "level_max": 9, "weight": 10},
	]
	warp_table = {
		Vector2i(1, 7): {"scene": EMBER_TOWN_SCENE, "route": &"ember_town", "cell": Vector2i(17, 7)},
		Vector2i(22, 7): {"scene": TIDE_TOWN_SCENE, "route": &"tide_town", "cell": Vector2i(2, 7)},
	}
	super._ready()
