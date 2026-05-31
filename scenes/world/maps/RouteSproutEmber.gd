extends TileMapWorld

const SPROUT_TOWN_SCENE := "res://scenes/world/maps/SproutTownMap.tscn"
const EMBER_TOWN_SCENE := "res://scenes/world/maps/EmberTownMap.tscn"

func _ready() -> void:
	route_id = &"route_sprout_ember"
	display_name = "Sprout-Ember Route"
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
		{"species_id": &"normal_pup", "level_min": 2, "level_max": 4, "weight": 25},
		{"species_id": &"normal_raccoon", "level_min": 2, "level_max": 4, "weight": 25},
		{"species_id": &"fire_lizard", "level_min": 3, "level_max": 5, "weight": 25},
		{"species_id": &"fire_moth", "level_min": 3, "level_max": 5, "weight": 15},
		{"species_id": &"normal_ferret", "level_min": 2, "level_max": 5, "weight": 10},
	]
	warp_table = {
		Vector2i(1, 7): {"scene": SPROUT_TOWN_SCENE, "route": &"hometown", "cell": Vector2i(17, 7)},
		Vector2i(22, 7): {"scene": EMBER_TOWN_SCENE, "route": &"ember_town", "cell": Vector2i(2, 7)},
	}
	super._ready()
