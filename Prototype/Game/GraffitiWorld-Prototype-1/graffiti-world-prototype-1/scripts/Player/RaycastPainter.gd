extends RayCast3D

class_name RaycastPainter

var GameValues = GlobalGameplayValues
var current_mesh: MeshInstance3D
var last_raycast_pos: Vector3

var previous_frame_available: bool = false
var able_to_draw: bool = true
var undo_triggered: bool = false

var current_color: Color
var overwrite_alpha: bool = true
var brush_thickness: int = 1

func set_thickness(is_thick: bool):
	if is_thick:
		brush_thickness = 2
	else:
		brush_thickness = 1

func set_overwrite_alpha(set_to: bool):
	overwrite_alpha = !set_to

func draw_line(pos_1, pos_2, obj: DrawTile):
	
	var distance_requirement: float
	if brush_thickness <= 1: 
		distance_requirement = 64
	else: distance_requirement = 2
	
	var should_overwrite_alpha: bool = overwrite_alpha
	
	if current_color == Color.TRANSPARENT: should_overwrite_alpha = true
		
	
	var distance: int = (pos_1.distance_to(pos_2) * distance_requirement) + 5
	distance = clampi(distance, 1, 256)
	for i in range(distance):
		var lerpPos: Vector3 = pos_2.lerp(pos_1, float(i)/float(distance))
		var coords = UvPosition.get_uv_coords(lerpPos - obj.position, get_collision_normal(), false)
		if !coords:
			return
		if brush_thickness <= 1:
			obj.set_pixel(coords.x, coords.y, current_color, should_overwrite_alpha)
		else:
			obj.fill_spot(coords.x, coords.y, brush_thickness, current_color, should_overwrite_alpha)

func paint(obj: DrawTile):
	

	
	if Input.is_action_pressed("pen_down"):
		

		var world_textures: WorldTextures = GlobalGameplayValues.world_textures
		if !world_textures.painted_tiles.has(obj):
			world_textures.painted_tiles.append(obj)

		if Input.is_action_just_pressed("pen_down") and !undo_triggered:
			undo_triggered = true
			add_to_undo_buffer()
		
		var collision_point: Vector3 = get_collision_point()
		
		var new_mesh = obj as MeshInstance3D
		if current_mesh != new_mesh: 
			UvPosition.set_mesh(obj as MeshInstance3D)
			previous_frame_available = false
		current_mesh = new_mesh
		
		if previous_frame_available:
			draw_line(last_raycast_pos, collision_point, obj)
		var coords = UvPosition.get_uv_coords(get_collision_point() - obj.position, get_collision_normal(), false)
		obj.set_pixel(coords.x, coords.y, current_color, overwrite_alpha)

		

		
		last_raycast_pos = collision_point
		previous_frame_available = true
		
		
		
		pass
	else:
		previous_frame_available = false




func add_to_undo_buffer():
	var edited_objects: Array[DrawTile] = GlobalGameplayValues.world_textures.painted_tiles
	for i in edited_objects:
		i.add_undo()

func move_undo(index: int):
	var edited_objects: Array[DrawTile] = GlobalGameplayValues.world_textures.painted_tiles
	for i in edited_objects:
		i.move_undo(index)

func _process(delta: float) -> void:
	if !Input.is_action_pressed("pen_down"):
		undo_triggered = false

func raycast_draw(ray_length: float):
	
	var cam: Camera3D = GameValues.main_camera as Camera3D
	
	
	
	var mousepos = get_viewport().get_mouse_position()
	#global_position = cam.global_position + (-cam.transform.basis.z * cam.near)
	global_position = cam.project_position(mousepos, cam.near)
	var look_at_pos = global_position + cam.project_ray_normal(mousepos)
	look_at(look_at_pos)
	var space_state = get_world_3d().direct_space_state

	var result: Object = get_collider()
	
	
	
	var could_reach: bool = false
	if result as StaticBody3D:
		var parent = result.get_parent()
		if parent is DrawTile and able_to_draw:
			paint(parent)
			could_reach = true
			pass
	if !could_reach:
		previous_frame_available = false
		current_mesh = null
	
	if Input.is_action_just_pressed("undo"):
		move_undo(-1)
	if Input.is_action_just_pressed("redo"):
		move_undo(1)
	
	pass
