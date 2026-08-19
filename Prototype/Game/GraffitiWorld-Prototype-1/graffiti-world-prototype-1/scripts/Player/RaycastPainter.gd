extends RayCast3D

class_name RaycastPainter

@export var color_rect: ColorRect
@export var blit_viewport: SubViewport

var GameValues = GlobalGameplayValues
var current_mesh: MeshInstance3D
var last_raycast_pos: Vector3

var previous_frame_available: bool = false
var able_to_draw: bool = true
var undo_triggered: bool = false

var current_color: Color = Color.BLACK
var should_overwrite: bool = true

var undo_slots: int = 0
var redo_slots: int = 0

@export var brush_type: Brush

func set_overwrite(set_to: bool):
	should_overwrite = !set_to



func paint(obj: DrawTile):
	


	
	if Input.is_action_pressed("pen_down") and !GameValues.main_camera.currently_panning:
		

		var world_textures: WorldTextures = GlobalGameplayValues.world_textures
		if !world_textures.painted_tiles.has(obj):
			world_textures.painted_tiles.append(obj)

		if Input.is_action_just_pressed("pen_down") and !undo_triggered:
			undo_triggered = true
			add_to_undo_buffer()
		
		var collision_point: Vector3 = get_collision_point()
		
		var new_mesh = obj as MeshInstance3D
		if current_mesh != new_mesh: 
			UvPosition.set_mesh(obj as MeshInstance3D, true)
			previous_frame_available = false
		current_mesh = new_mesh
		
		
		
		if previous_frame_available:
			# draw_line(last_raycast_pos, collision_point, obj)
			pass
		var coords = UvPosition.get_uv_coords(get_collision_point(), get_collision_normal(), false)
		
		if coords:
			
			var hit_data = HitData.new()
			
			hit_data.hit_position = get_collision_point()
			hit_data.hit_normal = get_collision_normal()
			hit_data.hit_color = current_color
			hit_data.should_overwrite = should_overwrite
			hit_data.has_last_hit_position = previous_frame_available
			hit_data.last_hit_position = last_raycast_pos
			hit_data.hit_tile = obj
			
			brush_type.draw(hit_data)
		else:
			print("no coords")
		
		last_raycast_pos = collision_point
		previous_frame_available = true
		
		
		
		pass
	else:
		previous_frame_available = false




func add_to_undo_buffer():
	var edited_objects: Array[DrawTile] = GlobalGameplayValues.world_textures.painted_tiles
	for i in edited_objects:
		undo_slots = 0
		redo_slots = 0
		i.add_undo()
	GameValues.drawing_controls.update_undo_buttons(undo_slots, redo_slots)

func move_undo(index: int):
	var edited_objects: Array[DrawTile] = GlobalGameplayValues.world_textures.painted_tiles
	for i in edited_objects:
		undo_slots = 0
		redo_slots = 0
		i.move_undo(index)
	GameValues.drawing_controls.update_undo_buttons(undo_slots, redo_slots)

func _process(delta: float) -> void:
	if !Input.is_action_pressed("pen_down"):
		undo_triggered = false
	



func raycast_draw(ray_length: float):
	
	var cam: Camera3D = GameValues.main_camera as Camera3D

	var mousepos = GameValues.main_camera.mouse_drawing_position
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
	
	GameValues.main_camera.hit_paint_wall = could_reach
	
	if Input.is_action_just_pressed("undo"):
		if Input.is_action_pressed("shift"):
			move_undo(1)
		else:
			move_undo(-1)
	if Input.is_action_just_pressed("redo"):
		move_undo(1)
	
	pass
