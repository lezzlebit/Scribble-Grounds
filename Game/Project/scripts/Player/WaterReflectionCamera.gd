extends Camera3D

class_name WaterReflectionCamera

@export var water: Node3D
@export var viewport: SubViewport
@export var water_height: float


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	
	

	var main_cam: CameraController = GlobalGameplayValues.main_camera
	fov = main_cam.fov
	near = main_cam.near
	far = main_cam.far
	environment = main_cam.environment
	viewport.size = main_cam.get_viewport().size / 1
	var height = -(main_cam.global_position.y - water_height) + water_height
	global_position = Vector3(main_cam.global_position.x, height, main_cam.global_position.z)
	global_rotation = Vector3(-main_cam.global_rotation.x, main_cam.global_rotation.y, main_cam.global_rotation.z)
	
	water.visible = GlobalGameplayValues.first_person
	
	pass
