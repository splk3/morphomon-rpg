extends Node
## Generates and plays simple procedural chiptune music and sound effects so the
## game ships with happy placeholder audio without binary assets. Registered as
## the `AudioManager` autoload.

const SAMPLE_RATE := 22050

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_index := 0
var _current_track := &""
var _music_cache: Dictionary = {}
var _sfx_cache: Dictionary = {}

# Note frequencies (Hz) for a small playful palette.
const NOTE := {
	"C4": 261.63, "D4": 293.66, "E4": 329.63, "F4": 349.23, "G4": 392.00,
	"A4": 440.00, "B4": 493.88, "C5": 523.25, "D5": 587.33, "E5": 659.25,
	"G5": 783.99, "REST": 0.0,
}

# Happy, bouncy melodies (note, beats) per context.
const TRACKS := {
	"town": [["C4",1],["E4",1],["G4",1],["E4",1],["F4",1],["A4",1],["G4",1],["E4",1],
		["D4",1],["F4",1],["A4",1],["G4",1],["C5",2],["G4",2]],
	"battle": [["E4",1],["E4",1],["G4",1],["C5",1],["B4",1],["G4",1],["A4",1],["E4",1],
		["F4",1],["A4",1],["C5",1],["A4",1],["G4",2],["E4",1],["C4",1]],
	"victory": [["C4",1],["E4",1],["G4",1],["C5",2],["G4",1],["C5",3]],
	"title": [["C4",2],["G4",2],["A4",2],["E4",2],["F4",2],["C4",2],["G4",2],["G4",2]],
}


func _ready() -> void:
	_ensure_buses()
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)
	for i in 4:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)


func _ensure_buses() -> void:
	# Create Music and SFX buses routed to Master if the project lacks them.
	for bus_name in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus_name) < 0:
			var idx := AudioServer.bus_count
			AudioServer.add_bus(idx)
			AudioServer.set_bus_name(idx, bus_name)
			AudioServer.set_bus_send(idx, "Master")


# ------------------------------------------------------------------- music
func play_music(track: StringName) -> void:
	if _current_track == track and _music_player.playing:
		return
	_current_track = track
	if not TRACKS.has(String(track)):
		_music_player.stop()
		return
	if not _music_cache.has(track):
		_music_cache[track] = _build_melody(TRACKS[String(track)], 0.22, true)
	_music_player.stream = _music_cache[track]
	_music_player.play()


func stop_music() -> void:
	_current_track = &""
	_music_player.stop()


# --------------------------------------------------------------------- sfx
func play_sfx(name: StringName) -> void:
	if not _sfx_cache.has(name):
		_sfx_cache[name] = _build_sfx(name)
	var player := _sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % _sfx_players.size()
	player.stream = _sfx_cache[name]
	player.play()


func _build_sfx(name: StringName) -> AudioStreamWAV:
	match String(name):
		"confirm":
			return _build_melody([["C5", 1], ["G5", 1]], 0.07, false)
		"cancel":
			return _build_melody([["G4", 1], ["C4", 1]], 0.07, false)
		"select":
			return _build_melody([["E5", 1]], 0.05, false)
		"hit":
			return _build_noise(0.12, 0.5)
		"scan":
			return _build_melody([["C4", 1], ["E4", 1], ["G4", 1], ["C5", 1]], 0.05, false)
		"transform":
			return _build_melody([["C4", 1], ["G4", 1], ["E5", 1], ["G5", 1]], 0.06, false)
		"battle_start":
			# Rising fanfare that plays as the screen wipes into a battle.
			return _build_melody(
				[["C4", 1], ["E4", 1], ["G4", 1], ["C5", 1], ["E5", 2], ["G5", 2]],
				0.07, false)
		"victory":
			return _build_melody(TRACKS["victory"], 0.12, false)
		_:
			return _build_melody([["C5", 1]], 0.06, false)


# ----------------------------------------------------------------- synthesis
func _build_melody(notes: Array, beat_seconds: float, loop: bool) -> AudioStreamWAV:
	var data := PackedByteArray()
	for entry in notes:
		var freq: float = NOTE.get(entry[0], 0.0)
		var dur: float = beat_seconds * float(entry[1])
		_append_square(data, freq, dur)
	return _wav_from_bytes(data, loop)


func _append_square(data: PackedByteArray, freq: float, duration: float) -> void:
	var total := int(duration * SAMPLE_RATE)
	for i in total:
		var value := 0.0
		if freq > 0.0:
			var phase := fmod(float(i) * freq / float(SAMPLE_RATE), 1.0)
			value = 1.0 if phase < 0.5 else -1.0
			# Soft attack/decay envelope to avoid clicks.
			var env := clampf(float(i) / 200.0, 0.0, 1.0) * clampf(float(total - i) / 400.0, 0.0, 1.0)
			value *= 0.35 * env
		_append_sample(data, value)


func _build_noise(duration: float, amplitude: float) -> AudioStreamWAV:
	var data := PackedByteArray()
	var total := int(duration * SAMPLE_RATE)
	for i in total:
		var env := clampf(float(total - i) / float(total), 0.0, 1.0)
		_append_sample(data, (randf() * 2.0 - 1.0) * amplitude * env)
	return _wav_from_bytes(data, false)


func _append_sample(data: PackedByteArray, value: float) -> void:
	var s := int(clampf(value, -1.0, 1.0) * 32767.0)
	data.append(s & 0xFF)
	data.append((s >> 8) & 0xFF)


func _wav_from_bytes(data: PackedByteArray, loop: bool) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = data
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = data.size() / 2
	return wav
