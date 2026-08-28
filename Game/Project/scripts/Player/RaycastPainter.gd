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

var tiles_hit_in_stroke: Array[DrawTile]

var pen_down_switch: bool = false

@export var brush_type: Brush

signal on_undo_trigger
signal on_redo_trigger

func set_overwrite(set_to: bool):
	should_overwrite = !set_to

func clear_tiles_in_stroke():
	tiles_hit_in_stroke.clear()

func paint(obj: DrawTile):
	

	
	var collision_point: Vector3 = get_collision_point()
	
	if Input.is_action_pressed("pen_down") and !GameValues.main_camera.currently_panning:
		

		if Input.is_action_just_pressed("pen_down") and !undo_triggered:
			clear_tiles_in_stroke()
			undo_slots = 0
			redo_slots = 0
			undo_triggered = true

		var world_textures: WorldTextures = GlobalGameplayValues.world_textures
		if !world_textures.painted_tiles.has(obj):
			world_textures.painted_tiles.append(obj)
				
		for i in world_textures.painted_tiles:
			if !tiles_hit_in_stroke.has(i):
				i.add_undo()
				tiles_hit_in_stroke.append(i)
			
		# GameValues.drawing_controls.update_undo_buttons(undo_slots, redo_slots)
		
		var new_mesh = obj as MeshInstance3D
		if current_mesh != new_mesh: 
			UvPosition.set_mesh(obj as MeshInstance3D, true)
			previous_frame_available = false
		current_mesh = new_mesh
				
		var coords = UvPosition.get_uv_coords(get_collision_point(), get_collision_normal(), false)
		
		var pixel_scale_for_drawing = GameValues.main_camera.current_pixel_scale / float(GlobalNetworkValues.texture_dimensions.x)
		
		if coords:
			
			var hit_data = HitData.new()
			
			hit_data.pixels_per_unit = pixel_scale_for_drawing
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


func add_one_to_undo_buffer(obj: DrawTile):
	obj.add_undo()
	# GameValues.drawing_controls.update_undo_buttons(undo_slots, redo_slots)

func add_to_undo_buffer():
	var edited_objects: Array[DrawTile] = GlobalGameplayValues.world_textures.painted_tiles
	for i in edited_objects:
		i.add_undo()
	# GameValues.drawing_controls.update_undo_buttons(undo_slots, redo_slots)

func move_undo(index: int):
	var edited_objects: Array[DrawTile] = GlobalGameplayValues.world_textures.painted_tiles
	if index == -1: on_undo_trigger.emit()
	if index == 1: on_redo_trigger.emit()
	for i in edited_objects:
		undo_slots = 0
		redo_slots = 0
		i.move_undo(index)
	# GameValues.drawing_controls.update_undo_buttons(undo_slots, redo_slots)

func _process(_delta: float) -> void:
	if !Input.is_action_pressed("pen_down"):
		undo_triggered = false
		
	if Input.is_action_just_pressed("undo"):
		if Input.is_action_pressed("shift"):
			move_undo(1)
		else:
			move_undo(-1)
	if Input.is_action_just_pressed("redo"):
		move_undo(1)
	GameValues.main_camera.mouse_motion_occupied = false
	if !GameValues.main_camera.currently_drawing:
		previous_frame_available = false
	

func look_at_mouse_position():
	var cam: Camera3D = GameValues.main_camera as Camera3D
	var mousepos = GameValues.main_camera.mouse_drawing_position
	global_position = cam.project_position(mousepos, cam.near)
	var end_position: Vector3 = cam.project_position(mousepos, cam.far)
	look_at(end_position)
	var target_distance = global_position.distance_to(end_position)
	target_position = Vector3(0, 0, -target_distance)

func pick_color(obj: DrawTile):
	
	if Input.is_action_just_released("pen_down") and !GameValues.main_camera.currently_panning:
		
		var collision_point: Vector3 = get_collision_point()
		UvPosition.set_mesh(obj as MeshInstance3D, true)
		var coords = UvPosition.get_uv_coords(get_collision_point(), get_collision_normal(), false)
		
		if obj != null and coords != null:
			var got_color: Color = obj.pick_pixel(coords.x, coords.y)
			
			GameValues.drawing_controls.find_button_for_pick_color(got_color)
			
			GameValues.drawing_controls.end_pick_color()
			GameValues.main_camera.picking_color = false

func raycast_draw(_ray_length: float):
	

	if !GameValues.main_camera.currently_drawing:
		previous_frame_available = false

	look_at_mouse_position()
	
	#var space_state = get_world_3d().direct_space_state

	var result: Object = get_collider()
	
	
	var could_reach: bool = false
	if result as StaticBody3D:
		var parent = result.get_parent()
		if parent is DrawTile and able_to_draw:
			if !GameValues.main_camera.picking_color: paint(parent)
			else: pick_color(parent)
			could_reach = true
			pass
	if !could_reach:
		previous_frame_available = false
		current_mesh = null

	
	GameValues.main_camera.hit_paint_wall = could_reach

	

	pass
