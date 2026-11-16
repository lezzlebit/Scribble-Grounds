extends Camera3D

class_name WaterReflectionCamera

@export var water: Node3D
@export var viewport: SubViewport
@export var water_height: float
var pixel_size: int = 1
var can_view_objects: bool = true



func _ready() -> void:
	GlobalGameplayValues.reflection_camera = self
	pass


func _process(delta: float) -> void:
	
	

	var main_cam: CameraController = GlobalGameplayValues.main_camera
	fov = main_cam.fov
	if can_view_objects:
		near = main_cam.near
		far = main_cam.far
	else:
		near = 0.01
		far = 0.02
	
	environment = main_cam.environment
	viewport.size = main_cam.get_viewport().size / pixel_size
	var height = -(main_cam.global_position.y - water_height) + water_height
	global_position = Vector3(main_cam.global_position.x, height, main_cam.global_position.z)
	global_rotation = Vector3(-main_cam.global_rotation.x, main_cam.global_rotation.y, main_cam.global_rotation.z)
	
	water.visible = GlobalGameplayValues.first_person
	
	pass
