extends Node

@export var Camera: Camera3D
@export var Raycast: RayCast3D
var meshtool: MeshDataTool

var current_mesh: Mesh

var last_raycast_pos: Vector3

func _ready() -> void:
	meshtool = MeshDataTool.new()
	
	pass


func paint(obj: DrawTile):

	
	var collision_point: Vector3 = Raycast.get_collision_point()
	
	var new_mesh = obj.mesh
	if current_mesh != new_mesh: 
		UvPosition.set_mesh(obj as MeshInstance3D)
		last_raycast_pos = collision_point
	current_mesh = new_mesh
	
	# print(Raycast.get_collision_normal())
	

	
	var distance: int = last_raycast_pos.distance_to(collision_point) * 256
	for i in range(distance):
		var lerpPos: Vector3 = last_raycast_pos.lerp(collision_point, float(i)/float(distance))
		var coords = UvPosition.get_uv_coords(lerpPos - obj.position, Raycast.get_collision_normal(), false)
		# if coords:
			# obj.set_pixel(coords.x, coords.y)
	
	var coords = UvPosition.get_uv_coords(Raycast.get_collision_point() - obj.position, Raycast.get_collision_normal(), false)
	# obj.set_pixel(coords.x, coords.y)
	
	last_raycast_pos = Raycast.get_collision_point()
	

func _process(delta: float) -> void:
	
	var result: Object = Raycast.get_collider()
	# if raycast_hit != null:
	
	var able_to_paint: bool = false
	if result is StaticBody3D:
		if result.get_parent() is DrawTile:
			paint(result.get_parent())
			able_to_paint = true
	
	if !able_to_paint: current_mesh = null
	
	pass
