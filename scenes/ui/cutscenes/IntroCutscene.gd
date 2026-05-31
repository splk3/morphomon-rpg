extends Node
## Self-contained opening story cutscene for the first overworld visit.

signal finished

const INTRO_SEEN_FLAG := &"intro_seen"
const DIALOGUE_BUBBLE_SCRIPT := preload("res://scenes/ui/DialogueBubble.gd")

const INTRO_DIALOGUE: Array[Dictionary] = [
	{
		"speaker": "Mom",
		"text": "Happy first day of school, {player_name}! I have something special for you before you go."
	},
	{
		"speaker": "Mom",
		"text": "This is your very own Morphomon robot. It can carry creature essences and transform to protect you."
	},
	{
		"speaker": "Mom",
		"text": "Treat it kindly, scan wild creatures, and it will grow alongside you."
	},
	{
		"speaker": "{headmaster_name}",
		"text": "Welcome to {town_name} School, {player_name}. Today marks the beginning of your Morphomon studies."
	},
	{
		"speaker": "{headmaster_name}",
		"text": "Your teachers and classmates have chosen you to represent our hometown school."
	},
	{
		"speaker": "{headmaster_name}",
		"text": "Travel with your Morphomon, learn from every town, and challenge each headmaster when you are ready."
	},
	{
		"speaker": "Mom",
		"text": "I'm proud of you, {player_name}. Go show everyone the spirit of {town_name}!"
	},
	{
		"speaker": "",
		"text": "Your journey as {town_name} School's representative begins now."
	},
]

var _dialogue
var _playing := false


func play() -> void:
	if _playing:
		await finished
		return
	if GameState.data == null:
		finished.emit()
		return
	if bool(GameState.get_flag(INTRO_SEEN_FLAG, false)):
		finished.emit()
		return

	_playing = true
	if not is_inside_tree():
		await ready
	_dialogue = DIALOGUE_BUBBLE_SCRIPT.new()
	add_child(_dialogue)
	_dialogue.show_lines(_build_dialogue_lines())
	await _dialogue.finished
	_dialogue.queue_free()
	_dialogue = null

	GameState.set_flag(INTRO_SEEN_FLAG, true)
	GameState.save()
	_playing = false
	finished.emit()


func _build_dialogue_lines() -> Array[Dictionary]:
	var hometown: TownData = GameData.get_town(&"hometown")
	var context := {
		"player_name": GameState.data.player_name,
		"town_name": hometown.display_name if hometown != null else "Sprout Town",
		"headmaster_name": hometown.headmaster_name if hometown != null else "Principal Maple",
	}
	var lines: Array[Dictionary] = []
	for entry in INTRO_DIALOGUE:
		lines.append({
			"speaker": str(entry.get("speaker", "")).format(context),
			"text": str(entry.get("text", "")).format(context),
		})
	return lines
