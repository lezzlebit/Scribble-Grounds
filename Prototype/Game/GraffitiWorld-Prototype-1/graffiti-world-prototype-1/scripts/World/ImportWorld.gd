@tool
extends EditorScenePostImport


# Called by the editor when a scene has this script set as the import script in the import tab.
func _post_import(scene: Node) -> Object:
	
	for i in scene.get_children():
		if i is MeshInstance3D:
			var newTile = DrawTile.new()
			newTile.mesh = i.mesh
			newTile.name = i.name
			newTile.set_surface_override_material(0, preload("res://assets/Materials/draw_tile/draw_tile_material.tres"))
			i.replace_by(newTile)
			newTile.create_trimesh_collision()
	
	return scene # Return the modified root node when you're done.
