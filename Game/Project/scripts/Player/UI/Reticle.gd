extends Node


@export var able_to_draw: Control


func _process(delta: float) -> void:
	
	var hit: bool = false
	var collider: StaticBody3D = GlobalGameplayValues.main_camera.raycast.get_collider()
	if collider:
		if collider.get_parent() is DrawTile:
			hit = GlobalGameplayValues.first_person
	
	able_to_draw.visible = hit
	
	
	pass
