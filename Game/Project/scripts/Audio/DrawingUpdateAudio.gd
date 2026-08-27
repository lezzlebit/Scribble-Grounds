extends AudioStreamPlayer3D

class_name DrawingUpdateAudio

func _ready() -> void:
	pass

func update_at_position(obj):
	global_position = obj.global_position
	play(0)
