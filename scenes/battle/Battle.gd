extends Control
## Turn-based battle. The player's Morphomon transforms into its active essence
## and fights a wild creature or a trainer's team. Player actions: Attack,
## Transform (swap essence), Scan (wild only), Run (wild only).

enum Phase { INTRO, PLAYER_CHOICE, RESOLVING, WIN, LOSE, FLED, CAPTURED }

var _phase := Phase.INTRO
var _wild := true
var _player: Combatant
var _enemy: Combatant
var _enemy_team: Array = []      # for trainer battles: Array of {species_id, level}
var _enemy_team_index := 0
var _trainer_name := ""

var _player_sprite: PlaceholderSprite
var _enemy_sprite: PlaceholderSprite
var _player_bar: ProgressBar
var _enemy_bar: ProgressBar
var _player_info: Label
var _enemy_info: Label
var _message: Label
var _action_box: VBoxContainer
var _busy := false


func _ready() -> void:
	UI.fill_background(self, Color("23304a"))
	AudioManager.play_music(&"battle")
	_setup_combatants()
	if not _is_valid_battle():
		# Defensive: never crash on a missing essence or corrupt species id.
		push_warning("Battle aborted: invalid combatant setup.")
		GameState.pending_battle = {}
		GameState.heal_team()
		get_tree().change_scene_to_file(Routes.OVERWORLD)
		return
	_build_ui()
	_intro()


func _is_valid_battle() -> bool:
	return _player != null and _player.species != null \
		and _enemy != null and _enemy.species != null


func _setup_combatants() -> void:
	var cfg := GameState.pending_battle
	_wild = cfg.get("wild", true)
	var active := GameState.data.morphomon.active_essence()
	if active == null or active.current_hp <= 0:
		var idx := GameState.data.morphomon.first_usable_index()
		if idx >= 0:
			GameState.data.morphomon.active_index = idx
			active = GameState.data.morphomon.active_essence()
	_player = Combatant.from_essence(active)
	if _wild:
		_enemy = Combatant.from_species(cfg.get("species_id", &""), cfg.get("level", 5))
	else:
		_trainer_name = cfg.get("trainer_name", "Trainer")
		_enemy_team = cfg.get("trainer_team", [])
		_enemy_team_index = 0
		if _enemy_team.is_empty():
			return
		var first: Dictionary = _enemy_team[0]
		_enemy = Combatant.from_species(first["species_id"], first["level"])


func _build_ui() -> void:
	# Enemy (top-right)
	_enemy_sprite = _make_sprite(Vector2(940, 200), _enemy.species.tint, 60)
	_enemy_info = UI.make_label("", 20)
	_enemy_info.position = Vector2(620, 60)
	add_child(_enemy_info)
	_enemy_bar = _make_bar(Vector2(620, 100))

	# Player (bottom-left)
	_player_sprite = _make_sprite(Vector2(300, 460), _player.species.tint, 70)
	_player_info = UI.make_label("", 20)
	_player_info.position = Vector2(80, 380)
	add_child(_player_info)
	_player_bar = _make_bar(Vector2(80, 420))

	# Message + actions
	var bottom := PanelContainer.new()
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -170
	bottom.add_theme_stylebox_override("panel", _panel_box())
	add_child(bottom)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 20)
	bottom.add_child(h)

	_message = UI.make_label("", 22)
	_message.custom_minimum_size = Vector2(560, 140)
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	h.add_child(_message)

	_action_box = VBoxContainer.new()
	_action_box.add_theme_constant_override("separation", 8)
	h.add_child(_action_box)

	_refresh_status()


func _make_sprite(pos: Vector2, tint: Color, radius: float) -> PlaceholderSprite:
	var s := PlaceholderSprite.new()
	s.tint = tint
	s.body_radius = radius
	s.position = pos
	add_child(s)
	return s


func _make_bar(pos: Vector2) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(260, 22)
	bar.position = pos
	bar.min_value = 0
	bar.max_value = 100
	bar.show_percentage = false
	add_child(bar)
	return bar


func _panel_box() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = UI.PANEL
	sb.set_content_margin_all(16)
	return sb


func _refresh_status() -> void:
	_enemy_info.text = "%s  Lv.%d" % [_enemy.display_name(), _enemy.level]
	_player_info.text = "%s  Lv.%d" % [_player.display_name(), _player.level]
	_enemy_bar.value = _enemy.hp_ratio() * 100.0
	_player_bar.value = _player.hp_ratio() * 100.0
	_player_sprite.tint = _player.species.tint
	_enemy_sprite.tint = _enemy.species.tint


# ---------------------------------------------------------------- flow
func _intro() -> void:
	var who := "A wild %s appeared!" % _enemy.display_name() if _wild \
		else "%s wants to battle!" % _trainer_name
	await _say(who)
	await _say("Your Morphomon transforms into %s!" % _player.display_name())
	AudioManager.play_sfx(&"transform")
	_player_choice()


func _player_choice() -> void:
	_phase = Phase.PLAYER_CHOICE
	_message.text = "What will %s do?" % _player.display_name()
	_clear_actions()
	_add_action("Attack", _choose_attack)
	_add_action("Transform", _choose_transform)
	if _wild:
		_add_action("Scan", _action_scan)
		_add_action("Run", _action_run)


func _choose_attack() -> void:
	_clear_actions()
	for move_id in _player.species.moves:
		var move := GameData.get_move(move_id)
		if move == null:
			continue
		_add_action(move.display_name, _action_attack.bind(move))
	_add_action("Back", _player_choice)


func _choose_transform() -> void:
	_clear_actions()
	var essences := GameState.data.morphomon.essences
	for i in essences.size():
		var e := essences[i]
		e.ensure_full_hp()
		var label := "%s Lv.%d" % [e.display_label(), e.level]
		if i == GameState.data.morphomon.active_index:
			label += " (active)"
		var btn := _add_action(label, _action_transform.bind(i))
		if e.current_hp <= 0 or i == GameState.data.morphomon.active_index:
			btn.disabled = true
	_add_action("Back", _player_choice)


# ---------------------------------------------------------------- actions
func _action_attack(move: MoveData) -> void:
	if _busy:
		return
	await _do_player_move(move)
	if _check_end():
		return
	await _enemy_turn()
	if _check_end():
		return
	_player_choice()


func _do_player_move(move: MoveData) -> void:
	_busy = true
	_clear_actions()
	if randf() > move.accuracy:
		await _say("%s used %s... but it missed!" % [_player.display_name(), move.display_name])
		_busy = false
		return
	var dmg := _player.damage_against(move, _enemy)
	_enemy.take_damage(dmg)
	AudioManager.play_sfx(&"hit")
	_refresh_status()
	await _say("%s used %s! %s" % [_player.display_name(), move.display_name, _effect_text(move.element, _enemy)])
	_busy = false


func _action_transform(index: int) -> void:
	GameState.data.morphomon.active_index = index
	_player = Combatant.from_essence(GameState.data.morphomon.active_essence())
	_refresh_status()
	AudioManager.play_sfx(&"transform")
	await _say("Your Morphomon transforms into %s!" % _player.display_name())
	await _enemy_turn()
	if _check_end():
		return
	_player_choice()


func _action_scan() -> void:
	_busy = true
	_clear_actions()
	AudioManager.play_sfx(&"scan")
	await _say("You aim your scanner at %s..." % _enemy.display_name())
	var success := GameState.attempt_scan(
		_enemy.species.id, _enemy.level, _enemy.hp_ratio())
	if success:
		_phase = Phase.CAPTURED
		await _say("Gotcha! %s's essence was stored!" % _enemy.display_name())
		AudioManager.play_sfx(&"victory")
		_end_battle()
		return
	await _say("Scan failed! %s broke free." % _enemy.display_name())
	_busy = false
	await _enemy_turn()
	if _check_end():
		return
	_player_choice()


func _action_run() -> void:
	_busy = true
	_clear_actions()
	if randf() < 0.7:
		_phase = Phase.FLED
		await _say("You got away safely!")
		_end_battle()
		return
	await _say("Couldn't escape!")
	_busy = false
	await _enemy_turn()
	if _check_end():
		return
	_player_choice()


func _enemy_turn() -> void:
	_busy = true
	if _enemy.is_fainted():
		_busy = false
		return
	var move := GameData.get_move(_enemy.species.moves[randi() % _enemy.species.moves.size()])
	if randf() > move.accuracy:
		await _say("%s used %s... but it missed!" % [_enemy.display_name(), move.display_name])
		_busy = false
		return
	var dmg := _enemy.damage_against(move, _player)
	_player.take_damage(dmg)
	AudioManager.play_sfx(&"hit")
	_refresh_status()
	await _say("%s used %s! %s" % [_enemy.display_name(), move.display_name, _effect_text(move.element, _player)])
	_busy = false


func _effect_text(element: StringName, target: Combatant) -> String:
	var mult := GameData.effectiveness(element, target.species.element)
	if mult >= 2.0:
		return "It's super effective!"
	if mult <= 0.5:
		return "It's not very effective..."
	return ""


# ---------------------------------------------------------------- endings
func _check_end() -> bool:
	if _enemy.is_fainted():
		_on_enemy_fainted()
		return true
	if _player.is_fainted():
		_on_player_fainted()
		return true
	return false


func _on_enemy_fainted() -> void:
	_busy = true
	await _say("%s was knocked out!" % _enemy.display_name())
	var xp := 6 + _enemy.level * 4
	if _player.essence != null and _player.essence.add_experience(xp):
		await _say("%s grew to Lv.%d!" % [_player.display_name(), _player.essence.level])
		_player = Combatant.from_essence(_player.essence)
		_refresh_status()
	# Trainer battles can field more creatures.
	if not _wild:
		_enemy_team_index += 1
		if _enemy_team_index < _enemy_team.size():
			var next: Dictionary = _enemy_team[_enemy_team_index]
			_enemy = Combatant.from_species(next["species_id"], next["level"])
			_refresh_status()
			await _say("%s sends out %s!" % [_trainer_name, _enemy.display_name()])
			_busy = false
			_player_choice()
			return
	_phase = Phase.WIN
	AudioManager.play_sfx(&"victory")
	await _say("You won the battle!")
	_record_headmaster_win()
	_end_battle()


## When the defeated team belonged to a headmaster, award the school badge.
func _record_headmaster_win() -> void:
	var town_id: String = GameState.pending_battle.get("headmaster_town", "")
	if town_id.is_empty():
		return
	if not GameState.data.defeated_headmasters.has(town_id):
		GameState.data.defeated_headmasters.append(town_id)
	GameState.heal_team()


func _on_player_fainted() -> void:
	_busy = true
	# Try to auto-switch to another usable essence.
	var idx := GameState.data.morphomon.first_usable_index()
	if idx >= 0:
		GameState.data.morphomon.active_index = idx
		_player = Combatant.from_essence(GameState.data.morphomon.active_essence())
		_refresh_status()
		await _say("Your Morphomon transforms into %s!" % _player.display_name())
		_busy = false
		_player_choice()
		return
	_phase = Phase.LOSE
	await _say("Your Morphomon is out of power! You rush back to town...")
	GameState.heal_team()
	_end_battle()


func _end_battle() -> void:
	GameState.pending_battle = {}
	GameState.save()
	await get_tree().create_timer(0.6).timeout
	get_tree().change_scene_to_file(Routes.OVERWORLD)


# ---------------------------------------------------------------- helpers
func _say(text: String) -> void:
	_message.text = text
	await get_tree().create_timer(0.9).timeout


func _clear_actions() -> void:
	for c in _action_box.get_children():
		c.queue_free()


func _add_action(text: String, cb: Callable) -> Button:
	var b := UI.make_button(text)
	b.custom_minimum_size = Vector2(220, 40)
	b.pressed.connect(func() -> void:
		AudioManager.play_sfx(&"select")
		cb.call())
	_action_box.add_child(b)
	if _action_box.get_child_count() == 1:
		b.call_deferred("grab_focus")
	return b
