extends AudioStreamPlayer3D

class_name RandomAudioOneshot

@export var audio_clips: Array[AudioStream]
var rng = RandomNumberGenerator.new()
var polyphonic_played: bool = false
@export var pitch_variation: float

func _init() -> void:
	stream = AudioStreamPolyphonic.new()

func play_random():
	
	var sfx: AudioStream = audio_clips[rng.randi_range(0, len(audio_clips)-1)]
	if stream is AudioStreamPolyphonic:
		if !polyphonic_played: play()
		polyphonic_played = true
		var playback = get_stream_playback() as AudioStreamPlaybackPolyphonic
		playback.play_stream(sfx, 0, 1, rng.randf_range(1-pitch_variation, 1+pitch_variation), 0, "SFX");
