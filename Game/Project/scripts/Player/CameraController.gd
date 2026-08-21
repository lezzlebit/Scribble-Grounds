extends Camera3D

class_name CameraController

var GameValues = GlobalGameplayValues

# @export var painter: RaycastPainter
@export var raycast: RaycastPainter
@export var first_person_pivot: Node3D
@export var wall_sticker: Node3D
@export var wall_camera_pivot: Node3D
@export var drawing_controls: Control
@export var pause_screen: Control




var screen_pixel_size: int = 2

var camera_lerp_value: float = 0
@export var lerp_speed: float

var current_mesh: MeshInstance3D
var current_pixel_scale: float = 1
var current_raw_pixel_scale: float = 1
var current_texture_scale: int = 1
var current_uv_up_position: Vector2 = Vector2.UP


var current_zoom_level: int = 3
var zoom_values: Array[int] = [2, 3, 4, 6, 8, 16, 24, 32]

var mouse_drawing_position: Vector2
var pan_pixels: Vector2
var currently_panning: bool = false
var picking_color_for_replace: bool = false
var hit_paint_wall: bool = false

var currently_drawing: bool = false

var sprint_fov_multiplier_lerp: float = 1.0


func _ready() -> void:
	GameValues.main_camera = self
	pass


func _unhandled_input(event: InputEvent):
	
	if !GameValues.first_person and !picking_color_for_replace:

		var camera_distance: float = get_camera_distance()
		# raycast.target_position.z = far * -1
		
		# if !Input.is_action_pressed("pen_down"):
		# mouse_drawing_position = get_viewport().get_mouse_position()
		
		if event is InputEventMouseMotion:
			currently_drawing = event.button_mask == 1
		
		
	
		
		if event is InputEventMouseMotion:
			mouse_drawing_position = event.position
			
			# mouse_drawing_position = get_viewport().get_mouse_position()
			# mouse_drawing_position += event.screen_relative
			if Input.is_action_pressed("pan_mouse") or (Input.is_action_pressed("pen_down") and currently_panning):
				currently_panning = true
				pan_pixels += event.relative / float(screen_pixel_size)
				clamp_pan()
		
		raycast.raycast_draw(camera_distance)

func clamp_pan():
	pan_pixels.x = clamp(pan_pixels.x, -512, 512)
	pan_pixels.y = clamp(pan_pixels.y, -512, 512)

func find_paint_wall():
	
	var result: Object = raycast.get_collider()
	var collision_position: Vector3 = raycast.get_collision_point()
	var collision_normal: Vector3 = raycast.get_collision_normal()
	
	
	if result as StaticBody3D:
		var parent = result.get_parent()
		if parent is DrawTile and Input.is_action_just_pressed("begin_drawing"):
			
			pan_pixels = Vector2.ZERO
			
			wall_sticker.reparent(result.get_parent())
			wall_sticker.global_position = collision_position
			
			print("normal: " + str(collision_normal))
			
			
			wall_sticker.look_at(wall_sticker.global_position - collision_normal, Vector3.UP)
			
			
			set_mesh(parent, false)

			current_texture_scale = parent.texture_height
			if get_pixel_scale(collision_position, collision_normal, parent):
				
				GameValues.first_person = false
			
			if collision_normal == Vector3.UP:
				var up_normal: Vector3 = Vector3(current_uv_up_position.y, 0, current_uv_up_position.x).normalized()
				wall_sticker.look_at(wall_sticker.global_position - collision_normal, up_normal)


# https://discussions.unity.com/t/fit-object-exactly-into-perspective-cameras-field-of-view-focus-the-object/677696/2

func get_pixel_scale(hit_position: Vector3, normal: Vector3, obj: DrawTile):
	
	var sample_distance: float = 0.05
	
	set_mesh(obj, false)
	
	var side_position: Vector3 = wall_sticker.global_basis.y * sample_distance
	

	
	var pos_1 = UvPosition.get_uv_coords(hit_position, normal, false)
	var pos_2 = UvPosition.get_uv_coords(hit_position + side_position, normal, false)
	



	
	if pos_1 == null or pos_2 == null:
		print("oh no")
		return false

	current_uv_up_position = pos_1 - pos_2;
	
	current_raw_pixel_scale = (pos_1.distance_to(pos_2))
	current_pixel_scale = sample_distance / (pos_1.distance_to(pos_2))
	
	return true


func get_camera_distance():


	var object_size = (get_viewport().size.y / float(current_texture_scale)) * current_pixel_scale
	var camera_view = 2 * tan(0.5 * deg_to_rad(1) * fov)
	var distance = (1/float(screen_pixel_size)) * object_size / camera_view
	
	return distance


func set_mesh(obj: MeshInstance3D, refresh: bool):
	if refresh:
		var new_mesh = obj
		if current_mesh != new_mesh: 
			UvPosition.set_mesh(obj as MeshInstance3D, true)
		current_mesh = new_mesh
	else:
		UvPosition.set_mesh(obj as MeshInstance3D, true)


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
	
	var wall_pivot_fov: float = 30
	var default_fov: float = 75 * sprint_fov_multiplier_lerp
	
	var wall_pivot_camera_near: float = get_camera_distance() - 2
	var default_near: float = 0.1
	var wall_pivot_camera_far: float = get_camera_distance() + 15
	var default_far: float = 1000
	
	var lerp_desired_position: float
	if GameValues.first_person: lerp_desired_position = 0
	if !GameValues.first_person: lerp_desired_position = 1
	camera_lerp_value = lerp(camera_lerp_value, lerp_desired_position, delta * lerp_speed)
	camera_lerp_value = clamp(camera_lerp_value, 0, 1)
	
	fov = lerp(default_fov, wall_pivot_fov, camera_lerp_value)
	
	near = lerp(default_near, wall_pivot_camera_near, camera_lerp_value)
	far = lerp(default_far, wall_pivot_camera_far, camera_lerp_value)
	global_position = first_person_position.lerp(wall_pivot_position, camera_lerp_value)
	quaternion = first_person_rotation.slerp(wall_pivot_rotation, camera_lerp_value)


func handle_zoom():
	
	var zoom_add: float = 0
	if Input.is_action_just_pressed("zoom_in"):
		zoom_add = 1
	if Input.is_action_just_pressed("zoom_out"):
		zoom_add = -1
	
	
	
	
	current_zoom_level += zoom_add
	
	
	
	
	
	current_zoom_level = clampi(current_zoom_level, 0, zoom_values.size() - 1)
	
	var old_screen_pixel_size: float = screen_pixel_size
	screen_pixel_size = zoom_values[current_zoom_level]
	
	if zoom_add != 0: 
		
		var middle: Vector2 = get_viewport().size / 2
		var mouse_pos = (get_viewport().get_mouse_position() - middle)
		
		var pixel_size_delta: float = 1/(1-(old_screen_pixel_size / float(screen_pixel_size)))
		
		pan_pixels -= (mouse_pos / pixel_size_delta) / old_screen_pixel_size
		clamp_pan()
	
	
	


func begin_pan_input():
	if (Input.is_action_just_released("pen_down") \
	or Input.is_action_just_released("pan_mouse")) \
	and !Input.is_action_pressed("begin_pan"):
		currently_panning = false
	
	if Input.is_action_just_pressed("begin_pan"):
		currently_panning = true
	
	if Input.is_action_just_released("begin_pan")\
	and (!Input.is_action_pressed("pen_down") \
	and !Input.is_action_pressed("pan_mouse")):
		currently_panning = false


func drawing_mouse():
	if currently_panning:
		if Input.is_action_pressed("pan_mouse") or Input.is_action_pressed("pen_down"):
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_MOVE)
	else:
		if hit_paint_wall and !picking_color_for_replace:
			Input.set_default_cursor_shape(Input.CURSOR_CROSS)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _process(delta: float) -> void:
	
	
	
	handle_zoom()
	
	drawing_controls.visible = !GameValues.first_person
	
	
	if !Input.is_action_pressed("pen_down"):
		mouse_drawing_position = get_viewport().get_mouse_position()
	
	if !picking_color_for_replace: begin_pan_input()
	
	
	if GameValues.first_person and !GameValues.paused:
		if Input.is_action_pressed("sprint"):
			sprint_fov_multiplier_lerp = lerp(sprint_fov_multiplier_lerp, 1.06, delta*15)
		else:
			sprint_fov_multiplier_lerp = lerp(sprint_fov_multiplier_lerp, 1.0, delta*15)
		find_paint_wall()
		raycast.position = Vector3.ZERO
		raycast.rotation = Vector3.ZERO
		raycast.target_position = Vector3(0, 0, -2)

	elif Input.is_action_just_pressed("end_drawing") and !picking_color_for_replace:
		
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		GameValues.first_person = true
		GameValues.world_textures.save_unsaved_textures()
	
	update_position(delta)
	
	pause_screen.visible = GameValues.paused
	if GameValues.paused:
		pause_screen.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		pause_screen.process_mode = Node.PROCESS_MODE_DISABLED
	
	if !GameValues.paused and GameValues.first_person:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if GameValues.paused:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		else:
			drawing_mouse()
	

	
	pass
