extends RayCast3D

class_name SingleFootstep

var selected_tile: DrawTile
var uv_coords: Vector2

var fade: float = 0.0

var timer: float
var fade_time: float = GlobalNetworkValues.footstep_fade_time

var color: Color = Color.BLACK

func _ready() -> void:

	
	pass

func draw_on_tile():

	if uv_coords:
		selected_tile.set_footstep_color(uv_coords, color, fade)

func get_coords(obj: DrawTile):
	var collision_point = get_collision_point()
	var collision_normal = get_collision_normal()
	
	UvPosition.set_mesh(obj as MeshInstance3D, true)
	uv_coords = UvPosition.get_uv_coords(collision_point, collision_normal, false)
	if uv_coords:
		selected_tile = obj

func cast_ray():
	force_raycast_update()
	
	var obj = get_collider()
	if obj == null:
		self.queue_free()
		return
	if obj is StaticBody3D:
		var parent = obj.get_parent()
		if parent is DrawTile:
			get_coords(parent)
			fade = 1.0
			draw_on_tile()

	# await get_tree().create_timer(fade_time).timeout
	var steps: int = 4
	for i in range(steps):
		await get_tree().create_timer(fade_time / float(steps)).timeout
		fade = lerp(1.0 - (float(i) / float(steps)), 1.0, 0.5)
		draw_on_tile()
	fade = 0.0
	draw_on_tile()
	self.queue_free()
