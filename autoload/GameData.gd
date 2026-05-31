extends Node
## Central registry for all static game content: elements, type effectiveness,
## moves, creatures and towns. Registered as the `GameData` autoload.

const ELEMENT_IDS: Array[StringName] = [
	&"normal", &"fire", &"water", &"electric", &"earth",
	&"plant", &"light", &"dark", &"astro",
]

const STARTER_IDS: Array[StringName] = [&"plant_cactus", &"fire_mole", &"water_crane"]

var elements: Dictionary = {}      # StringName -> ElementType
var moves: Dictionary = {}         # StringName -> MoveData
var creatures: Dictionary = {}     # StringName -> CreatureSpecies
var towns: Dictionary = {}         # StringName -> TownData
var towns_ordered: Array[TownData] = []

## Effectiveness multiplier for attacker element -> defender element.
## Anything unspecified defaults to 1.0 (neutral).
var _type_chart: Dictionary = {}


func _ready() -> void:
	_build_elements()
	_build_type_chart()
	_build_moves()
	_build_creatures()
	_build_towns()


func _build_elements() -> void:
	var defs := {
		&"normal": ["Normal", Color("d9d9d9"), "Element-less essences taught at the hometown school."],
		&"fire": ["Fire", Color("ef5a3a"), "Blazing essences full of heat and energy."],
		&"water": ["Water", Color("3aa0ef"), "Flowing essences that shift and adapt."],
		&"electric": ["Electric", Color("f4d03f"), "Crackling, fast-moving essences."],
		&"earth": ["Earth", Color("b07a3a"), "Sturdy, grounded essences."],
		&"plant": ["Plant", Color("4fb24f"), "Living, growing essences."],
		&"light": ["Light", Color("fff4b0"), "Radiant, hopeful essences."],
		&"dark": ["Dark", Color("6a4f8a"), "Shadowy, mysterious essences."],
		&"astro": ["Astro", Color("8a6bff"), "Cosmic essences from beyond the sky."],
	}
	for id in defs.keys():
		var e := ElementType.new()
		e.id = id
		e.display_name = defs[id][0]
		e.color = defs[id][1]
		e.description = defs[id][2]
		elements[id] = e


func _build_type_chart() -> void:
	# attacker -> { defender: multiplier }
	_type_chart = {
		&"fire": {&"plant": 2.0, &"earth": 2.0, &"water": 0.5, &"fire": 0.5},
		&"water": {&"fire": 2.0, &"earth": 2.0, &"plant": 0.5, &"water": 0.5},
		&"electric": {&"water": 2.0, &"astro": 2.0, &"earth": 0.5, &"electric": 0.5},
		&"earth": {&"electric": 2.0, &"fire": 2.0, &"plant": 0.5, &"water": 0.5},
		&"plant": {&"water": 2.0, &"earth": 2.0, &"fire": 0.5, &"plant": 0.5},
		&"light": {&"dark": 2.0, &"astro": 2.0, &"light": 0.5},
		&"dark": {&"light": 2.0, &"dark": 0.5},
		&"astro": {&"light": 2.0, &"electric": 0.5, &"astro": 0.5},
	}


func effectiveness(attack_element: StringName, defender_element: StringName) -> float:
	var row: Variant = _type_chart.get(attack_element, {})
	return float(row.get(defender_element, 1.0))


func _build_moves() -> void:
	# A generic move plus one signature move per element.
	_add_move(&"tackle", "Tackle", &"normal", 18, 1.0, "A plain body slam.")
	_add_move(&"scratch", "Scratch", &"normal", 16, 1.0, "Quick claw swipes.")
	_add_move(&"flame_burst", "Flame Burst", &"fire", 26, 0.95, "A burst of fire.")
	_add_move(&"aqua_jet", "Aqua Jet", &"water", 24, 1.0, "A fast jet of water.")
	_add_move(&"spark", "Spark", &"electric", 24, 0.95, "A jolt of electricity.")
	_add_move(&"rock_throw", "Rock Throw", &"earth", 25, 0.9, "Hurls heavy stones.")
	_add_move(&"vine_lash", "Vine Lash", &"plant", 24, 0.95, "Whipping vines strike.")
	_add_move(&"light_ray", "Light Ray", &"light", 26, 0.95, "A focused beam of light.")
	_add_move(&"shadow_claw", "Shadow Claw", &"dark", 26, 0.95, "Claws wreathed in shadow.")
	_add_move(&"star_shot", "Star Shot", &"astro", 27, 0.9, "Fires a shard of starlight.")


func _add_move(id: StringName, name: String, element: StringName, power: int, acc: float, desc: String) -> void:
	var m := MoveData.new()
	m.id = id
	m.display_name = name
	m.element = element
	m.power = power
	m.accuracy = acc
	m.description = desc
	moves[id] = m


func get_move(id: StringName) -> MoveData:
	return moves.get(id, null)


func default_move_for(element: StringName) -> StringName:
	for id in moves.keys():
		if moves[id].element == element:
			return id
	return &"tackle"


func _build_creatures() -> void:
	for entry in CreatureCatalog.ENTRIES:
		var c := CreatureSpecies.new()
		c.id = StringName(entry["id"])
		c.display_name = entry["name"]
		c.element = StringName(entry["element"])
		c.description = entry.get("description", "")
		c.base_hp = int(entry.get("hp", 22))
		c.base_attack = int(entry.get("attack", 12))
		c.base_defense = int(entry.get("defense", 10))
		c.base_speed = int(entry.get("speed", 10))
		c.scan_resistance = float(entry.get("scan_resistance", 0.5))
		c.tint = Color(entry.get("tint", "ffffff"))
		var move_list: Array[StringName] = []
		move_list.append(GameData.default_move_for(c.element))
		move_list.append(&"tackle")
		c.moves = move_list
		creatures[c.id] = c


func get_creature(id: StringName) -> CreatureSpecies:
	return creatures.get(id, null)


func creatures_of_element(element: StringName) -> Array:
	var out: Array = []
	for c in creatures.values():
		if c.element == element:
			out.append(c)
	return out


func _build_towns() -> void:
	# order 0 is the hometown (normal); the rest follow the element progression.
	var town_defs := [
		{"id": "hometown", "name": "Sprout Town", "element": "normal", "home": true, "headmaster": "Principal Maple"},
		{"id": "ember_town", "name": "Ember Town", "element": "fire", "home": false, "headmaster": "Headmaster Cinder"},
		{"id": "tide_town", "name": "Tide Town", "element": "water", "home": false, "headmaster": "Headmaster Marina"},
		{"id": "volt_town", "name": "Volt Town", "element": "electric", "home": false, "headmaster": "Headmaster Sparx"},
		{"id": "bedrock_town", "name": "Bedrock Town", "element": "earth", "home": false, "headmaster": "Headmaster Gravel"},
		{"id": "verdant_town", "name": "Verdant Town", "element": "plant", "home": false, "headmaster": "Headmaster Fern"},
		{"id": "lumen_town", "name": "Lumen Town", "element": "light", "home": false, "headmaster": "Headmaster Halo"},
		{"id": "umbra_town", "name": "Umbra Town", "element": "dark", "home": false, "headmaster": "Headmaster Vesper"},
		{"id": "nova_town", "name": "Nova Town", "element": "astro", "home": false, "headmaster": "Headmaster Cosmo"},
	]
	var order := 0
	for d in town_defs:
		var t := TownData.new()
		t.id = StringName(d["id"])
		t.display_name = d["name"]
		t.element = StringName(d["element"])
		t.is_hometown = d["home"]
		t.headmaster_name = d["headmaster"]
		t.order = order
		t.description = "%s — home of the %s school." % [d["name"], elements[StringName(d["element"])].display_name]
		towns[t.id] = t
		towns_ordered.append(t)
		order += 1


func get_town(id: StringName) -> TownData:
	return towns.get(id, null)
