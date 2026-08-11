extends RayCast3D

class_name RaycastPainter

var GameValues = GlobalGameplayValues
var current_mesh: MeshInstance3D
var last_raycast_pos: Vector3

var previous_frame_available: bool = false

var tiles_painted: Array[DrawTile]


func draw_line(pos_1, pos_2, obj: DrawTile):
	var distance: int = (pos_1.distance_to(pos_2) + 0.1) * 64
	for i in range(distance):
		var lerpPos: Vector3 = pos_2.lerp(pos_1, float(i)/float(distance))
		var coords = UvPosition.get_uv_coords(lerpPos - obj.position, get_collision_normal(), false)
		if coords:
			obj.set_pixel(coords.x, coords.y)

func paint(obj: DrawTile):
	
	if Input.is_action_pressed("pen_down"):
		
		
		
		var collision_point: Vector3 = get_collision_point()
		
		var new_mesh = obj as MeshInstance3D
		if current_mesh != new_mesh: 
			UvPosition.set_mesh(obj as MeshInstance3D)
			previous_frame_available = false
		current_mesh = new_mesh
		
		if previous_frame_available:
			draw_line(last_raycast_pos, collision_point, obj)

		
		var coords = UvPosition.get_uv_coords(get_collision_point() - obj.position, get_collision_normal(), false)
		obj.set_pixel(coords.x, coords.y)
		
		last_raycast_pos = collision_point
		previous_frame_available = true
		
		pass
	else:
		previous_frame_available = false



func raycast_draw(ray_length: float):
	
	var cam: Camera3D = GameValues.main_camera as Camera3D
	
	var mousepos = get_viewport().get_mouse_position()
	global_position = cam.project_ray_origin(mousepos)
	look_at(global_position + cam.project_ray_normal(mousepos) * 1)
	var space_state = get_world_3d().direct_space_state

	var result: Object = get_collider()
	
	
	var could_reach: bool = false
	if result as StaticBody3D:
		var parent = result.get_parent()
		if parent is DrawTile:
			paint(parent)
			could_reach = true
			pass
	if !could_reach:
		previous_frame_available = false
		current_mesh = null
	
	pass
