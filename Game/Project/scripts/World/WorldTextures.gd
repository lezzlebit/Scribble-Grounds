extends Node3D

class_name WorldTextures

@export var update_audio: DrawingUpdateAudio

var tiles: Dictionary[String, DrawTile]
var image_pool: Dictionary[String, Image]

var painted_tiles: Array[DrawTile]

var directory: String = GlobalNetworkValues.save_directory + GlobalNetworkValues.save_folder

var updated_image_queue: Dictionary[String, float]

func _init() -> void:
	GlobalGameplayValues.world_textures = self

func _ready() -> void:
	check_tiles_dictionary()



func get_all_children(node):
	var nodes : Array = []
	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(get_all_children(N))
		else:
			nodes.append(N)
	return nodes

func check_tiles_dictionary():
	
	var all_children = get_all_children(self)
	
	if tiles.size() < 1:
		for child in all_children:
			if child is DrawTile: 
				tiles[child.name] = child



func get_file_name(path: String):
	var splitted: PackedStringArray = path.split("/")
	var file_name: String = splitted[splitted.size() - 1]
	return file_name

func save_unsaved_textures():
	print(painted_tiles)
	var path = GlobalNetworkValues.save_directory + GlobalNetworkValues.save_folder
	
	for i in painted_tiles:
		
		i.end_drawing()
		i.clear_undo_buffer()
		
		var name_path = GlobalNetworkValues.username + "/"
		var save_id = i.name + ".png"
		
		if i.image:
			var image_to_save: Image = i.image
			
			DirAccess.make_dir_absolute(path + name_path)
			image_to_save.save_png(path + name_path + save_id)
			# GlobalGameplayValues.network_handler.create_image_offline(name_path + save_id)
			GlobalGameplayValues.network_handler.upload_image(name_path + save_id)
	
	painted_tiles.clear()


func update_one_image(image_path: String):
	
	var imported_image: Image = Image.new()
	var err = imported_image.load(directory + image_path)
	if err != OK:
		print("no image found (singular)")
		return false
	var original_name = image_path.split(".")[0]
	
	var file_name: String = get_file_name(original_name)
	var image_username: String = original_name.split("/")[0]
	
	if tiles.has(file_name):
		var tile_found: DrawTile = tiles[file_name]
		
		tile_found.set_image(image_username, imported_image)
	return true
	
	

func update_image_pool(update_all: bool):
	
	check_tiles_dictionary()
	
	var network_handler: NetworkHandler = GlobalGameplayValues.network_handler
	
	var files_to_get: Dictionary[String, String]
	if update_all: files_to_get = network_handler.current_images
	if !update_all: files_to_get = network_handler.required_images
	
	for i in files_to_get:
		
		var selected_name = i.split(".")[0]
		get_one_image(selected_name, i)
	
	assign_all_textures()

	pass
	
func get_one_image(selected_name: String, i: String):
	var imported_image: Image = Image.new()
	var err = imported_image.load(directory + i)
	if err != OK:
		print("no image found (load)")
		return false

	image_pool[selected_name] = imported_image
	return true

func assign_all_textures():
	for i in image_pool:
		var file_name: String = get_file_name(i)
		var image_username: String = i.split("/")[0]
		if tiles.has(file_name):
			var tile_found: DrawTile = tiles[file_name]
			tile_found.set_image(image_username, image_pool[i])

func add_image_to_queue(image_path: String):
	updated_image_queue[image_path] = 0.3

func process_image_queue(delta: float):
	
	var items_to_erase: Array[String]
	
	for i in updated_image_queue:
		updated_image_queue[i] -= delta
		if updated_image_queue[i] < 0:
			update_one_image(i)
			items_to_erase.append(i)
	
	for i in items_to_erase:
		updated_image_queue.erase(i)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	process_image_queue(delta)
	pass
