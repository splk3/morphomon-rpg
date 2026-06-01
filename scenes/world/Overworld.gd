extends Node2D
## Top-down overworld: grid movement, random encounters in tall grass / water /
## caves, a town with Morphomon Club services, and a trainer to battle.

const TILE := 48
const MAP_W := 34
const MAP_H := 24
const ENCOUNTER_CHANCE := 0.14
const MOVE_TIME := 0.12
## Identifies the procedural overworld when persisting the player's position.
const WORLD_ROUTE := &"overworld"

enum Terrain { GROUND, PATH, GRASS, WATER, CAVE, TREE, TOWN }

const TERRAIN_COLOR := {
	Terrain.GROUND: Color("6fae5a"),
	Terrain.PATH: Color("cda86b"),
	Terrain.GRASS: Color("3f7d3a"),
	Terrain.WATER: Color("3a86c8"),
	Terrain.CAVE: Color("4a4458"),
	Terrain.TREE: Color("245a2a"),
	Terrain.TOWN: Color("c97f4f"),
}

var _map: Array = []                 # _map[y][x] = Terrain
var _player_cell := Vector2i(6, 12)
var _player_pixel := Vector2.ZERO
var _moving := false
var _move_from := Vector2.ZERO
var _move_to := Vector2.ZERO
var _move_t := 0.0
var _facing := 1

var _terrain_node: Node2D
var _player_sprite: PlaceholderSprite
var _trainer_cell := Vector2i(20, 8)
var _camera: Camera2D
var _hud: Label
var _dialogue
var _menu_open := false
var _busy := false


func _ready() -> void:
	randomize()
	if not GameState.has_active_game():
		# Safety: never sit in the overworld without a save loaded.
		get_tree().change_scene_to_file(Routes.TITLE)
		return
	_generate_map()
	_build_world()
	_restore_player_cell()
	_player_pixel = _cell_to_pixel(_player_cell)
	_player_sprite.position = _player_pixel
	AudioManager.play_music(&"town")
	_update_hud()
	_intro_if_needed()


# ---------------------------------------------------------------- map
func _generate_map() -> void:
	_map = []
	for y in MAP_H:
		var row := []
		for x in MAP_W:
			var t := Terrain.GROUND
			if x == 0 or y == 0 or x == MAP_W - 1 or y == MAP_H - 1:
				t = Terrain.TREE
			row.append(t)
		_map.append(row)

	# A central path.
	for x in range(3, MAP_W - 3):
		_map[12][x] = Terrain.PATH
	for y in range(6, 18):
		_map[y][14] = Terrain.PATH

	# Town building (top-left-ish).
	for y in range(3, 6):
		for x in range(4, 9):
			_map[y][x] = Terrain.TOWN

	# Tall grass patch (right side).
	for y in range(5, 12):
		for x in range(22, 30):
			_map[y][x] = Terrain.GRASS

	# Pond (bottom).
	for y in range(16, 21):
		for x in range(6, 14):
			_map[y][x] = Terrain.WATER

	# Cave area (bottom-right).
	for y in range(16, 21):
		for x in range(24, 31):
			_map[y][x] = Terrain.CAVE


func _terrain_at(cell: Vector2i) -> int:
	if cell.x < 0 or cell.y < 0 or cell.x >= MAP_W or cell.y >= MAP_H:
		return Terrain.TREE
	return _map[cell.y][cell.x]


func _is_blocked(cell: Vector2i) -> bool:
	return _terrain_at(cell) == Terrain.TREE


# ---------------------------------------------------------------- build
func _build_world() -> void:
	_terrain_node = Node2D.new()
	_terrain_node.set_script(preload("res://scenes/world/TerrainGrid.gd"))
	_terrain_node.set("map", _map)
	add_child(_terrain_node)

	# Trainer NPC (if not yet defeated).
	if not _trainer_defeated():
		var trainer := PlaceholderSprite.new()
		trainer.kind = PlaceholderSprite.Kind.PERSON
		trainer.tint = Color("d23a5a")
		trainer.body_radius = 18
		trainer.position = _cell_to_pixel(_trainer_cell)
		trainer.name = "Trainer"
		add_child(trainer)

	_player_sprite = PlaceholderSprite.new()
	_player_sprite.kind = PlaceholderSprite.Kind.PERSON
	_player_sprite.tint = UI.APPEARANCES[GameState.data.appearance % UI.APPEARANCES.size()]
	_player_sprite.body_radius = 18
	add_child(_player_sprite)

	_camera = Camera2D.new()
	_camera.zoom = Vector2(1.4, 1.4)
	_player_sprite.add_child(_camera)
	_camera.make_current()

	# HUD
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := UI.make_panel(Color(0, 0, 0, 0.45))
	panel.position = Vector2(16, 16)
	layer.add_child(panel)
	_hud = UI.make_label("", 16)
	panel.add_child(_hud)

	_dialogue = CanvasLayer.new()
	_dialogue.set_script(preload("res://scenes/ui/DialogueBubble.gd"))
	add_child(_dialogue)


func _cell_to_pixel(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * TILE + TILE / 2.0, cell.y * TILE + TILE / 2.0)


## Resume on the tile the player last stood on (e.g. after a battle) instead of
## restarting at the map entrance.
func _restore_player_cell() -> void:
	var wp := GameState.get_world_position()
	if wp.is_empty() or String(wp.get("route", "")) != String(WORLD_ROUTE):
		return
	var cell: Vector2i = wp.get("cell", _player_cell)
	if cell.x >= 0 and cell.y >= 0 and cell.x < MAP_W and cell.y < MAP_H and not _is_blocked(cell):
		_player_cell = cell


func _save_position() -> void:
	GameState.set_world_position(WORLD_ROUTE, _player_cell)


# ---------------------------------------------------------------- input/move
func _process(delta: float) -> void:
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

	if _busy or _menu_open or (_dialogue and _dialogue.is_active()):
		return

	var dir := Vector2i.ZERO
	# Pick the dominant axis so analog-stick diagonals resolve to a single grid
	# step. Polling per-action with elif made the left stick unreliable: a slight
	# vertical lean while pushing sideways would always win. get_axis() already
	# applies each action's deadzone, so the d-pad (digital) still works exactly.
	var ix := Input.get_axis("move_left", "move_right")
	var iy := Input.get_axis("move_up", "move_down")
	if absf(ix) > absf(iy):
		if absf(ix) > 0.0:
			dir = Vector2i(signi(ix), 0)
	elif absf(iy) > 0.0:
		dir = Vector2i(0, signi(iy))
	if dir != Vector2i.ZERO:
		_try_move(dir)


# Interact/menu use events (not polling) so that a dialogue or overlay that
# consumes the press can't be re-triggered later in the same frame.
func _unhandled_input(event: InputEvent) -> void:
	if _moving or _busy or _menu_open or (_dialogue and _dialogue.is_active()):
		return
	if event.is_action_pressed("open_menu"):
		get_viewport().set_input_as_handled()
		_open_menu()
	elif event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_try_interact()


func _try_move(dir: Vector2i) -> void:
	if dir.x != 0:
		_facing = signi(dir.x)
		_player_sprite.facing = _facing
	var target := _player_cell + dir
	if _is_blocked(target):
		return
	if target == _trainer_cell and not _trainer_defeated():
		_start_trainer_battle()
		return
	_player_cell = target
	_move_from = _player_sprite.position
	_move_to = _cell_to_pixel(target)
	_move_t = 0.0
	_moving = true


func _on_arrived() -> void:
	_save_position()
	var t := _terrain_at(_player_cell)
	if t == Terrain.GRASS or t == Terrain.WATER or t == Terrain.CAVE:
		if randf() < ENCOUNTER_CHANCE:
			_start_wild_battle(t)


# ---------------------------------------------------------------- encounters
func _element_for_terrain(t: int) -> StringName:
	match t:
		Terrain.WATER:
			return &"water"
		Terrain.CAVE:
			return [&"earth", &"dark"].pick_random()
		_:
			return [&"plant", &"normal"].pick_random()


func _start_wild_battle(t: int) -> void:
	var element := _element_for_terrain(t)
	var pool := GameData.creatures_of_element(element)
	if pool.is_empty():
		pool = GameData.creatures.values()
	var species: CreatureSpecies = pool.pick_random()
	var level := randi_range(3, 7)
	AudioManager.play_sfx(&"select")
	GameState.start_wild_battle(species.id, level)
	get_tree().change_scene_to_file(Routes.BATTLE)


func _start_trainer_battle() -> void:
	var town := GameData.get_town(GameState.data.current_town)
	var element := town.element if town else &"normal"
	var pool := GameData.creatures_of_element(element)
	if pool.is_empty():
		pool = GameData.creatures.values()
	var team: Array = []
	for i in 2:
		team.append({"species_id": (pool.pick_random() as CreatureSpecies).id, "level": randi_range(4, 7)})
	GameState.start_trainer_battle("Rival Student", team)
	# Mark this roaming trainer as defeated regardless of outcome flag below;
	# the actual win is recorded by the headmaster flow. Here we just battle.
	GameState.data.defeated_headmasters.append("roaming_" + str(_trainer_cell))
	_save_position()
	get_tree().change_scene_to_file(Routes.BATTLE)


func _trainer_defeated() -> bool:
	return GameState.data.defeated_headmasters.has("roaming_" + str(_trainer_cell))


# ---------------------------------------------------------------- interact
func _try_interact() -> void:
	# Interact when standing next to the town building. If there's nothing
	# adjacent to interact with, stay silent and let play continue.
	for dir in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
		if _terrain_at(_player_cell + dir) == Terrain.TOWN:
			_open_town_services()
			return


# ---------------------------------------------------------------- narration
func _intro_if_needed() -> void:
	if GameState.get_flag(&"intro_seen"):
		return
	var intro := preload("res://scenes/ui/cutscenes/IntroCutscene.tscn").instantiate()
	add_child(intro)
	_busy = true
	intro.finished.connect(func() -> void:
		_busy = false
		intro.queue_free()
	, CONNECT_ONE_SHOT)
	intro.play()


func _say(lines: Array) -> void:
	if _dialogue:
		_dialogue.show_lines(lines)


# ---------------------------------------------------------------- HUD
func _update_hud() -> void:
	var town := GameData.get_town(GameState.data.current_town)
	var active := GameState.data.morphomon.active_essence()
	var active_text := active.display_label() + " Lv." + str(active.level) if active else "none"
	_hud.text = "%s   |   %s   |   Active: %s   |   Scanned: %d\n[Tab/Start] Menu   [E/A] Interact   Move: WASD/Stick" % [
		GameState.data.player_name,
		town.display_name if town else "Wilds",
		active_text,
		GameState.data.morphopedia.size(),
	]


# ---------------------------------------------------------------- menus
func _open_menu() -> void:
	_menu_open = true
	var overlay := OverworldMenu.new()
	overlay.kind = OverworldMenu.Kind.MAIN
	overlay.closed.connect(_on_menu_closed)
	add_child(overlay)


func _open_town_services() -> void:
	_menu_open = true
	AudioManager.play_sfx(&"confirm")
	var overlay := OverworldMenu.new()
	overlay.kind = OverworldMenu.Kind.TOWN
	overlay.closed.connect(_on_menu_closed)
	add_child(overlay)


func _on_menu_closed() -> void:
	_menu_open = false
	_update_hud()
