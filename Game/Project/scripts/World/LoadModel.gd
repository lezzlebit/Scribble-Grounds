extends Node

class_name LoadModel

var directory: String = GlobalNetworkValues.save_directory + GlobalNetworkValues.save_folder

func _init():
	GlobalGameplayValues.load_model = self



func load_gltf():
	var gltf_document_load = GLTFDocument.new()
	var gltf_state_load = GLTFState.new()
	var error = gltf_document_load.append_from_file(directory + GlobalNetworkValues.model_name, gltf_state_load)
	if error == OK:
		var gltf_scene_root_node = gltf_document_load.generate_scene(gltf_state_load)
		# add_child(gltf_scene_root_node)
		convert_to_drawing_world(gltf_scene_root_node)
		print("ADDED!")
	else:
		print("Couldn't load glTF scene (error code: %s)." % error_string(error))


func convert_to_drawing_world(parent: Node):
	
	var new_node: Node = Node.new()
	add_child(new_node)
	
	for i in parent.get_children():
		if i is MeshInstance3D:
			var transform_applied: bool = i.position == Vector3.ZERO and i.rotation == Vector3.ZERO and i.scale == Vector3.ONE
			if i.mesh.surface_get_material(0) != null and transform_applied:
				print(i)
				print(i.position)
				var new_tile: DrawTile = DrawTile.new()
				new_tile.position = i.position
				new_tile.rotation = i.rotation
				new_tile.scale = i.scale
				var new_texture: ImageTexture = i.mesh.surface_get_material(0).albedo_texture
				new_tile.material_override = preload("res://assets/Materials/draw_tile/draw_tile_material.tres").duplicate()
				new_tile.set_instanced_material()
				new_tile.material_override.set_shader_parameter("lightmap_texture", new_texture)
				new_tile.mesh = i.mesh
				new_node.add_child(new_tile)
				new_tile.create_trimesh_collision()
				new_tile.name = i.name
			else:
				if "-col" in i.name:
					i.create_trimesh_collision()
				if "-colonly" in i.name:
					i.visible = false
				new_node.add_child(i.duplicate())
				
	GlobalGameplayValues.network_handler.begin_loading()
	GlobalGameplayValues.player_controller.paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
