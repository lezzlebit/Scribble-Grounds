extends Node


@export var raycast_painter : RaycastPainter
@export var brush_audio_player : AudioStreamPlayer3D
var smooth_brush_distance: float = 0
var brush_distance: float = 0
var smooth_brush_vertical: float = 0
var brush_vertical: float = 0
var pen_down: bool = false

@export var audio_clips: Array[AudioStream]


func _ready() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and !GlobalGameplayValues.first_person:
		pen_down = event.button_mask == 1
		brush_vertical = event.relative.normalized().y
		brush_distance = event.relative.length_squared()

func _process(delta: float) -> void:

	var target_distance: float = (brush_distance)
	if GlobalGameplayValues.first_person:
		pen_down = false
	
	
	smooth_brush_distance = lerp(smooth_brush_distance, target_distance, delta * 35)
	smooth_brush_vertical = lerp(smooth_brush_vertical, brush_vertical, delta * 100)
	
	if !pen_down: smooth_brush_distance = 0

	brush_audio_player.volume_linear = smooth_brush_distance / 50000000
	brush_audio_player.pitch_scale = (smooth_brush_vertical / 7) + 1
	brush_distance = 0
	
	pass
