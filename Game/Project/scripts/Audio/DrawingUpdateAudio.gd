extends AudioStreamPlayer3D

class_name DrawingUpdateAudio


@export var audio_clips: Array[AudioStream]
var polyphonic_played: bool = false
@export var pitch_variation: float

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	pass

func update_at_position(obj):
	if len(GlobalGameplayValues.network_handler.required_images) > 0:
		return
	global_position = obj.global_position
	if obj is DrawTile:
		var faces = obj.mesh.get_faces()
		var selected_face = rng.randi_range(0, faces.size()-1)
		
		global_position = faces[selected_face]

	play_random()

func _init() -> void:
	stream = AudioStreamPolyphonic.new()

func play_random():
	
	var sfx: AudioStream = audio_clips[rng.randi_range(0, len(audio_clips)-1)]
	if stream is AudioStreamPolyphonic:
		if !polyphonic_played: play()
		polyphonic_played = true
		var playback = get_stream_playback() as AudioStreamPlaybackPolyphonic
		playback.play_stream(sfx, 0, 1, rng.randf_range(1-pitch_variation, 1+pitch_variation), 0, "SFX");
