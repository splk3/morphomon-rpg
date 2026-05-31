class_name TileMapWorld
extends Node2D
## Shared TileMapLayer world prototype. Subclasses provide route_id,
## display_name, default_start_cell, tile_rows, encounter_table, and warp_table.
## tile_rows uses: . ground, = path, g grass, ~ water, # wall, B building, W warp.

const TILE := 48
const MOVE_TIME := 0.12
const ENCOUNTER_CHANCE := 0.14
const BATTLE_SCENE := "res://scenes/battle/Battle.tscn"

enum Terrain { GROUND, PATH, GRASS, WATER, BUILDING, WALL, WARP }

const TERRAIN_ATLAS := {
	Terrain.GROUND: Vector2i(0, 0),
	Terrain.PATH: Vector2i(1, 0),
	Terrain.GRASS: Vector2i(2, 0),
	Terrain.WATER: Vector2i(3, 0),
	Terrain.BUILDING: Vector2i(4, 0),
	Terrain.WALL: Vector2i(5, 0),
	Terrain.WARP: Vector2i(6, 0),
}

const TERRAIN_COLORS := {
	Terrain.GROUND: Color("6fae5a"),
	Terrain.PATH: Color("cda86b"),
	Terrain.GRASS: Color("3f7d3a"),
	Terrain.WATER: Color("3a86c8"),
	Terrain.BUILDING: Color("c97f4f"),
	Terrain.WALL: Color("4a3328"),
	Terrain.WARP: Color("f2c14e"),
}

var route_id: StringName = &""
var display_name := "TileMap World"
var default_start_cell := Vector2i(1, 1)
var tile_rows := PackedStringArray()
var encounter_table: Array = []
var warp_table: Dictionary = {}

var _map_size := Vector2i.ZERO
var _player_cell := Vector2i.ZERO
var _moving := false
var _move_from := Vector2.ZERO
var _move_to := Vector2.ZERO
var _move_t := 0.0
var _facing := 1
var _terrain_layer: TileMapLayer
var _player_sprite: PlaceholderSprite
var _camera: Camera2D


func _ready() -> void:
	randomize()
	_map_size = _measure_map()
	_build_tile_layer()
	_build_player()
	_restore_or_place_player()


func _process(delta: float) -> void:
	if _player_sprite == null:
		return
	if _moving:
		_move_t += delta / MOVE_TIME
		if _move_t >= 1.0:
			_move_t = 1.0
			_moving = false
			_player_sprite.position = _move_to
			_on_arrived()
		else:
			_player_sprite.position = _move_from.lerp(_move_to, _move_t)
		return

	var dir := Vector2i.ZERO
	if Input.is_action_pressed("move_up"):
		dir = Vector2i(0, -1)
	elif Input.is_action_pressed("move_down"):
		dir = Vector2i(0, 1)
	elif Input.is_action_pressed("move_left"):
		dir = Vector2i(-1, 0)
	elif Input.is_action_pressed("move_right"):
		dir = Vector2i(1, 0)
	if dir != Vector2i.ZERO:
		_try_move(dir)


func _measure_map() -> Vector2i:
	var width := 0
	for row in tile_rows:
		width = maxi(width, row.length())
	return Vector2i(width, tile_rows.size())


func _build_tile_layer() -> void:
	_terrain_layer = TileMapLayer.new()
	_terrain_layer.name = "Terrain"
	_terrain_layer.tile_set = _make_tileset()
	add_child(_terrain_layer)
	for y in _map_size.y:
		for x in _map_size.x:
			var cell := Vector2i(x, y)
			var terrain := _terrain_at(cell)
			_terrain_layer.set_cell(cell, 0, TERRAIN_ATLAS[terrain])


func _make_tileset() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE, TILE)
	var image := Image.create(TILE * TERRAIN_COLORS.size(), TILE, false, Image.FORMAT_RGBA8)
	for terrain in TERRAIN_COLORS.keys():
		_paint_tile(image, int(terrain), TERRAIN_COLORS[terrain])
	var texture := ImageTexture.create_from_image(image)
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(TILE, TILE)
	for terrain in TERRAIN_COLORS.keys():
		source.create_tile(Vector2i(int(terrain), 0))
	tile_set.add_source(source, 0)
	return tile_set


func _paint_tile(image: Image, tile_index: int, color: Color) -> void:
	var x0 := tile_index * TILE
	for y in TILE:
		for x in TILE:
			image.set_pixel(x0 + x, y, color)
	match tile_index:
		Terrain.GRASS:
			for blade_x in [10, 24, 38]:
				for i in 16:
					image.set_pixel(x0 + blade_x + int(i / 4), TILE - 8 - i, Color("2e5e2a"))
		Terrain.WATER:
			for y in [12, 28, 40]:
				for x in range(6, TILE - 6):
					image.set_pixel(x0 + x, y, Color("80c8f0"))
		Terrain.BUILDING:
			for y in 18:
				for x in TILE:
					image.set_pixel(x0 + x, y, Color("e85a3a"))
		Terrain.WARP:
			for y in range(16, 32):
				for x in range(16, 32):
					image.set_pixel(x0 + x, y, Color("fff0a8"))


func _build_player() -> void:
	_player_sprite = PlaceholderSprite.new()
	_player_sprite.kind = PlaceholderSprite.Kind.PERSON
	_player_sprite.tint = Color("4f7ed9")
	_player_sprite.body_radius = 18
	add_child(_player_sprite)

	_camera = Camera2D.new()
	_camera.zoom = Vector2(1.4, 1.4)
	_player_sprite.add_child(_camera)
	_camera.make_current()


func _restore_or_place_player() -> void:
	_player_cell = default_start_cell
	if GameState.has_active_game():
		var saved := GameState.get_world_position()
		if not saved.is_empty() and saved.get("route", &"") == route_id:
			_player_cell = saved.get("cell", default_start_cell)
		GameState.set_world_position(route_id, _player_cell)
	_player_sprite.position = _cell_to_pixel(_player_cell)


func _try_move(dir: Vector2i) -> void:
	if dir.x != 0:
		_facing = signi(dir.x)
		_player_sprite.facing = _facing
	var target := _player_cell + dir
	if _is_blocked(target):
		return
	_player_cell = target
	_move_from = _player_sprite.position
	_move_to = _cell_to_pixel(target)
	_move_t = 0.0
	_moving = true


func _on_arrived() -> void:
	if _try_warp():
		return
	if GameState.has_active_game():
		GameState.set_world_position(route_id, _player_cell)
	if _terrain_at(_player_cell) == Terrain.GRASS and randf() < ENCOUNTER_CHANCE:
		_start_wild_battle()


func _try_warp() -> bool:
	if not warp_table.has(_player_cell):
		return false
	var warp: Dictionary = warp_table[_player_cell]
	var target_route: StringName = warp.get("route", &"")
	var target_cell: Vector2i = warp.get("cell", default_start_cell)
	if GameState.has_active_game():
		GameState.set_world_position(target_route, target_cell)
	var scene_path := String(warp.get("scene", ""))
	if scene_path != "":
		get_tree().change_scene_to_file(scene_path)
	return true


func _start_wild_battle() -> void:
	if not GameState.has_active_game():
		return
	var encounter := GameData.roll_encounter(encounter_table)
	if encounter.is_empty():
		return
	GameState.start_wild_battle(StringName(encounter.get("species_id", &"")), int(encounter.get("level", 1)))
	get_tree().change_scene_to_file(BATTLE_SCENE)


func _terrain_at(cell: Vector2i) -> int:
	if cell.x < 0 or cell.y < 0 or cell.y >= tile_rows.size():
		return Terrain.WALL
	var row := tile_rows[cell.y]
	if cell.x >= row.length():
		return Terrain.WALL
	match row.substr(cell.x, 1):
		"=":
			return Terrain.PATH
		"g":
			return Terrain.GRASS
		"~":
			return Terrain.WATER
		"B":
			return Terrain.BUILDING
		"W":
			return Terrain.WARP
		"#":
			return Terrain.WALL
		_:
			return Terrain.GROUND


func _is_blocked(cell: Vector2i) -> bool:
	var terrain := _terrain_at(cell)
	return terrain == Terrain.WATER or terrain == Terrain.BUILDING or terrain == Terrain.WALL


func _cell_to_pixel(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * TILE + TILE / 2.0, cell.y * TILE + TILE / 2.0)
