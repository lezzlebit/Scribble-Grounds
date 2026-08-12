extends Camera3D

class_name CameraController

var GameValues = GlobalGameplayValues

# @export var painter: RaycastPainter
@export var raycast: RaycastPainter
@export var first_person_pivot: Node3D
@export var wall_sticker: Node3D
@export var wall_camera_pivot: Node3D




var screen_pixel_size: int = 2

var camera_lerp_value: float = 0
@export var lerp_speed: float

var current_mesh: MeshInstance3D
var current_pixel_scale: float = 1
var current_raw_pixel_scale: float = 1
var current_texture_scale: int = 1


var current_zoom_level: int = 3
var zoom_values: Array[int] = [1, 2, 3, 4, 6, 8, 16]

var pan_pixels: Vector2


func _ready() -> void:
	GameValues.main_camera = self
	pass

func _unhandled_input(event: InputEvent):
	
	if !GameValues.first_person:

		
		if event is InputEventMouseMotion:
			if Input.is_action_pressed("pan_mouse"):
				pan_pixels += event.relative / float(screen_pixel_size)

func find_paint_wall():
	
	var result: Object = raycast.get_collider()
	var collision_position: Vector3 = raycast.get_collision_point()
	var collision_normal: Vector3 = raycast.get_collision_normal()
	
	
	if result as StaticBody3D:
		var parent = result.get_parent()
		if parent is DrawTile and Input.is_action_just_pressed("toggle_drawing"):
			
			pan_pixels = Vector2.ZERO
			
			wall_sticker.reparent(result.get_parent())
			wall_sticker.global_position = collision_position
			wall_sticker.look_at(wall_sticker.global_position - collision_normal, parent.basis.y)
			set_mesh(parent)

			current_texture_scale = parent.texture_height
			if get_pixel_scale(collision_position - parent.position, collision_normal):
				GameValues.first_person = false


# https://discussions.unity.com/t/fit-object-exactly-into-perspective-cameras-field-of-view-focus-the-object/677696/2

func get_pixel_scale(position: Vector3, normal: Vector3):
	
	var sample_distance: float = 0.05
	
	
	var side_position: Vector3 = wall_sticker.global_basis.x * sample_distance
	var pos_1 = UvPosition.get_uv_coords(position, normal, true)
	var pos_2 = UvPosition.get_uv_coords(position + side_position, normal, true)
	
	if pos_1 == null or pos_2 == null:
		print("oh no")
		return false
	
	current_raw_pixel_scale = (pos_1.distance_to(pos_2))
	current_pixel_scale = sample_distance / (pos_1.distance_to(pos_2))
	
	return true


func get_camera_distance():


	var object_size = (get_viewport().size.y / float(current_texture_scale)) * current_pixel_scale
	var camera_view = 2 * tan(0.5 * deg_to_rad(1) * fov)
	var distance = (1/float(screen_pixel_size)) * object_size / camera_view
	
	return distance


func set_mesh(obj: MeshInstance3D):
	var new_mesh = obj
	if current_mesh != new_mesh: 
		UvPosition.set_mesh(obj as MeshInstance3D)
	current_mesh = new_mesh


func check_parent(parent: Node3D):
	if get_parent() != parent:
		reparent(parent)

func update_position(delta: float):
	
	
	var distance = get_camera_distance()


	var pan_pos: Vector2 = (pan_pixels / current_texture_scale) * current_pixel_scale
	# var pan_pos: Vector2 = pan_pixels / 256.0
	
	wall_camera_pivot.position = Vector3(-pan_pos.x, pan_pos.y, distance)
	
	var first_person_position: Vector3 = first_person_pivot.global_position
	var first_person_rotation: Quaternion = first_person_pivot.global_basis.get_rotation_quaternion()
	
	var wall_pivot_position: Vector3 = wall_camera_pivot.global_position
	var wall_pivot_rotation: Quaternion = wall_camera_pivot.global_basis.get_rotation_quaternion()
	
	var wall_pivot_camera_near: float = get_camera_distance() - 0.5
	var default_near: float = 0.1
	
	var lerp_desired_position: float
	if GameValues.first_person: lerp_desired_position = 0
	if !GameValues.first_person: lerp_desired_position = 1
	camera_lerp_value = lerp(camera_lerp_value, lerp_desired_position, delta * lerp_speed)
	camera_lerp_value = clamp(camera_lerp_value, 0, 1)
	
	near = lerp(default_near, wall_pivot_camera_near, camera_lerp_value)
	global_position = first_person_position.lerp(wall_pivot_position, camera_lerp_value)
	quaternion = first_person_rotation.slerp(wall_pivot_rotation, camera_lerp_value)


func handle_zoom():
	
	var zoom_add: float = 0
	if Input.is_action_just_pressed("zoom_in"):
		zoom_add = 1
	if Input.is_action_just_pressed("zoom_out"):
		zoom_add = -1
	
	current_zoom_level += zoom_add
	
	var old_screen_pixel_size: float = screen_pixel_size
	
	current_zoom_level = clampi(current_zoom_level, 0, zoom_values.size() - 1)
	screen_pixel_size = zoom_values[current_zoom_level]
	
	#if zoom_add != 0: 
		#
		#var middle: Vector2 = get_viewport().size / 2
		#
		#var pixel_size_delta: float = old_screen_pixel_size - float(screen_pixel_size)
		#print(pixel_size_delta)
		#
		##if pixel_size_delta > 0:
			##pan_pixels += (middle / old_screen_pixel_size) / 10
	
	
	



func _process(delta: float) -> void:
	
	handle_zoom()
	
	if GameValues.first_person:
		find_paint_wall()
		raycast.position = Vector3.ZERO
		raycast.rotation = Vector3.ZERO
		raycast.target_position.z = -5
		near = 0.05

	elif Input.is_action_just_pressed("toggle_drawing"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		GameValues.first_person = true
		GameValues.world_textures.save_unsaved_textures()
	
	if !GameValues.first_person:
		var camera_distance: float = get_camera_distance()
		raycast.target_position.z = camera_distance * -2
		raycast.raycast_draw(camera_distance)
	
	
	
	update_position(delta)
	
	pass
