@tool
extends EditorScenePostImport


# Called by the editor when a scene has this script set as the import script in the import tab.
func _post_import(scene: Node) -> Object:
	

	for i in scene.get_children():
		if i is MeshInstance3D:
			
			var can_edit: bool = true
			if "lights" in i.name:
				can_edit = false
				i.set_surface_override_material(0, preload("res://assets/Materials/draw_tile/light.tres"))
			if "Grass" in i.name:
				can_edit = false
				i.reparent(scene.get_node(i.name.replace("Grass","Beach")))
			if "water" in i.name:
				can_edit = false
				i.set_surface_override_material(0, preload("res://assets/Materials/water/water.tres"))
				i.visible = false
				i.process_mode = Node.PROCESS_MODE_DISABLED
			
			if can_edit:
				print(i.get_meta_list())
				var newTile = DrawTile.new()
				newTile.mesh = i.mesh
				newTile.name = i.name
				if "Beach" in i.name:
					newTile.set_surface_override_material(0, preload("res://assets/Materials/draw_tile/beach_material.tres"))
				elif "Rocks" in i.name:
					newTile.set_surface_override_material(0, preload("res://assets/Materials/draw_tile/rocks_material.tres"))
				else:
					newTile.set_surface_override_material(0, preload("res://assets/Materials/draw_tile/draw_tile_material.tres"))
				i.replace_by(newTile)
				newTile.create_trimesh_collision()
				
	for a in scene.get_children():
		for i in a.get_children():
			if "Grass" in i.name:
				var draw_tile_parent: DrawTile = i.get_parent()
				i.set_surface_override_material(0, draw_tile_parent.get_surface_override_material(0))
	

	
	return scene # Return the modified root node when you're done.
