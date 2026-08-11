extends Node3D

class_name WorldTextures

var tiles: Dictionary[String, DrawTile]
var image_pool: Dictionary[String, Image]

var painted_tiles: Array[DrawTile]

func _init() -> void:
	GlobalGameplayValues.world_textures = self

func _ready() -> void:
	check_tiles_dictionary()


func check_tiles_dictionary():
	if tiles.size() < 1:
		for child in get_children():
			if child is DrawTile: 
				tiles[child.name] = child


func get_file_name(path: String):
	var splitted: PackedStringArray = path.split("/")
	var name: String = splitted[splitted.size() - 1]
	return name.split(".")[0]

func save_unsaved_textures():
	print(painted_tiles)
	var path = GlobalNetworkValues.save_directory + GlobalNetworkValues.save_folder
	
	for i in painted_tiles:
		
		var name_path = GlobalNetworkValues.username + "/"
		var save_id = i.name + ".png"
		
		var image_to_save: Image = i.image
		
		DirAccess.make_dir_absolute(path + name_path)
		image_to_save.save_png(path + name_path + save_id)
		GlobalGameplayValues.network_handler.create_image_offline(name_path + save_id)
	
	painted_tiles.clear()


func update_image_pool():
	
	check_tiles_dictionary()
	
	var network_handler: NetworkHandler = GlobalGameplayValues.network_handler
	
	var files_to_get: Dictionary[String, String] = network_handler.current_images
	var directory: String = GlobalNetworkValues.save_directory + GlobalNetworkValues.save_folder
	
	for i in files_to_get:
		
		var name = get_file_name(i)
		
		var imported_image: Image = Image.new()
		var err = imported_image.load(directory + i)
		if err != OK:
			print("no image found")
			return false

		image_pool[name] = imported_image

	assign_all_textures()

	pass

func assign_all_textures():
	for i in image_pool:
		if tiles.has(i):
			var tile_found: DrawTile = tiles[i]
			tile_found.set_image(image_pool[i])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
