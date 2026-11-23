extends Node

class_name NetworkHandler

@export var Motd: Label

var network_address: String = GlobalNetworkValues.network_address
var directory: String = GlobalNetworkValues.save_directory + GlobalNetworkValues.save_folder
var changelog_filename: String = GlobalNetworkValues.changelog_filename

var current_images: Dictionary[String, String]
var new_images: Dictionary[String, String]
var required_images: Dictionary[String, String]

@export var wait_until_model_loaded: bool = false
var model_name: String = GlobalNetworkValues.model_name


func _init():
	pass

func _ready():
	GlobalGameplayValues.network_handler = self
	if !wait_until_model_loaded:
		begin_loading()
	else:
		request_model()
	if GlobalGameplayValues.playing_locally:
		Motd.text = "This is your local, offline save\nJoin a server to play with others"

func begin_loading():
	get_list_from_disk()
	await GlobalGameplayValues.world_textures.update_image_pool(true)
	retrieve_list()
	initialize_process_timers()


func initialize_process_timers():
	initialize_single_timer("RetrieveTimer", 2, retrieve_list)

func initialize_single_timer(timer_name: String, timer_length: float, signal_out: Callable):
	var added_timer: Timer = Timer.new()
	add_child(added_timer)
	added_timer.wait_time = timer_length
	added_timer.autostart = true
	added_timer.name = timer_name
	added_timer.timeout.connect(signal_out)
	added_timer.start()

func create_request(headers, method, body):
	if GlobalGameplayValues.playing_locally: return
	var request: SingleRequest = SingleRequest.new()
	add_child(request)
	request.network_handler = self
	request.request_completed.connect(request._http_request_completed)
	request.timeout = 20
	headers.append("Authorization: " + GlobalNetworkValues.server_password + "," + GlobalNetworkValues.compatibility_version)
	request.request_raw(network_address, headers, method, body)


# Select the correct response to data
func _http_request_completed(_result, response_code, headers, body):
	
	if response_code == 0:
		print("No response from web server!")
		GlobalGameplayValues.user_error_log("No response from web server")
		return
	
	var headers_dictionary = headers_to_dictionary(headers)
	var content_type = headers_dictionary["Content-type"]
	if headers_dictionary.has("Access-control-request-method"):
		var request_method = headers_dictionary["Access-control-request-method"]
		
		
		if (content_type == "text/plain" && request_method == "GET"):
			_on_retrieve_list(headers_dictionary, body)
		if (content_type == "text/plain" && request_method == "POST"):
			_on_image_uploaded(headers_dictionary, body)
		if (content_type == "image/png" && request_method == "POST"):
			_on_retrieve_image(headers_dictionary, body)
		if (content_type == "model/gltf-binary" && request_method == "POST"):
			_on_retrieve_model(headers_dictionary, body)
		if (content_type == "text/csv" && request_method == "POST"):
			_on_retrieve_steps(headers_dictionary, body)

func headers_to_dictionary(strings: PackedStringArray):
	
	var return_dictionary: Dictionary[String, String]
	for i in strings:
		var pair = i.split(": ")
		if len(pair) > 1:
			return_dictionary[pair[0]] = pair[1]
	return return_dictionary



func get_list_from_disk():
	DirAccess.make_dir_absolute(directory)
	
	if (FileAccess.file_exists(directory + changelog_filename)):

		var read = FileAccess.open(directory + changelog_filename, FileAccess.READ)
		current_images = text_list_to_dictionary(read.get_as_text())
	current_images = discard_images(current_images)

# Get required images (GET)
func retrieve_list():
	
	
	get_list_from_disk()
	
	var body = "retrieve_drawings_list".to_ascii_buffer()
	
	var headers = ["Content-type: text/plain"]
	
	if GlobalGameplayValues.viewing_offline: 
		GlobalGameplayValues.user_message_log("Viewing saved offline data")
		return
	create_request(headers, HTTPClient.METHOD_GET, body)
	if GlobalGameplayValues.use_footsteps: send_steps()



func discard_images(dict: Dictionary[String, String]):
	var marked_for_erase: Array[String]
	for i in dict:
		if int(dict[i]) == 0:
			marked_for_erase.append(i)
	
	for i in marked_for_erase:
		dict.erase(i)
	return dict

func _on_retrieve_list(_headers, body):
	
	var new_read = body.get_string_from_ascii()
	new_images = text_list_to_dictionary(new_read)
	if new_images.has("Motd"):
		if Motd != null:
			Motd.text = new_images["Motd"].replace("\\n","\n")
		new_images.erase("Motd")
	new_images = discard_images(new_images)
	
	required_images = compare_dictionaries(current_images, new_images)
	# print(required_images)
	# required_images = remove_username_from_dictionary(required_images)
	get_one_required_image()

func compare_dictionaries(dict_1, dict_2):
	
	var return_list: Dictionary[String, String]
	for i in dict_2:
		if (dict_1.has(i)):
			if (int(dict_2[i]) > int(dict_1[i])):
				return_list[i] = dict_2[i]
			
		else:
			return_list[i] = dict_2[i]
	
	return return_list

func remove_username_from_dictionary(dict_1: Dictionary[String, String]):
	for i in dict_1:
		if i.split("/")[0] == GlobalNetworkValues.username:
			dict_1.erase(i)
	return dict_1

# Update Changelog
func save_current_changelog():
	var text_to_save = dictionary_to_text(current_images)
	var file = FileAccess.open(directory + changelog_filename, FileAccess.WRITE)
	file.store_string(text_to_save)

func text_list_to_dictionary(text: String):
	var all_text = text.split("\n")
	var image_return_list: Dictionary[String, String]
	for i in all_text:
		var pair = i.replace("\n", "").split(":")
		if (pair.size() > 1):
			image_return_list[pair[0]] = pair[1]
	return image_return_list

func dictionary_to_text(in_dict: Dictionary[String, String]):
	var text_return = ""
	for i in in_dict:
		text_return += i + ":" + in_dict[i] + "\n"
	return text_return




# Get image from server (POST)
func get_one_required_image():

	var earliest: float = -1
	var selected: String = ""
	
	for i in required_images:
		var time_updated: float = float(required_images[i])
		
		if (earliest == -1) or (time_updated < earliest): 
			earliest = time_updated
			selected = i
	
	if len(selected) > 1:
		request_image(selected)
	else:
		pass

func request_image(filename: String):
	var headers = ["Content-type: text/plain"]
	var body = filename.to_ascii_buffer()
	
	create_request(headers, HTTPClient.METHOD_POST, body)

func _on_retrieve_image(headers, body):
	
	var filename = headers['Content-name']
	required_images.erase(filename)
	current_images[filename] = new_images[filename]
	save_current_changelog()
	if len(required_images) > 0:
		GlobalGameplayValues.user_message_log("Retrieving from Server (" + str(len(required_images)) + " drawings remaining)")
	else:
		GlobalGameplayValues.user_message_log("World updated")
	
	
	DirAccess.make_dir_absolute(directory + get_only_directory(filename))
	var image_file = FileAccess.open(directory + filename, FileAccess.WRITE)
	image_file.store_buffer(body)
	GlobalGameplayValues.world_textures.add_image_to_queue(filename)
	if len(required_images) > 0:
		get_one_required_image()



func upload_image(filename: String):
	
	var img = Image.new()
	var err = img.load(directory + filename)
	if err != OK:
		GlobalGameplayValues.user_error_log("Tried to upload image, but it was corrupted")
		return false
	var body: PackedByteArray = img.save_png_to_buffer()
	
	
	var headers = ["Content-type: image/png","Content-name: " + filename, "Content-length: " + str(len(body))]
	
	if GlobalGameplayValues.playing_locally:
		create_image_offline(filename)
	else:
		create_request(headers, HTTPClient.METHOD_POST, body)

func create_image_offline(filename):
	current_images[filename] = str(Time.get_unix_time_from_system()).split(".")[0]
	save_current_changelog()

func _on_image_uploaded(_headers, body):
	var content = body.get_string_from_ascii()
	var pair = content.split(":")
	current_images[pair[0]] = pair[1]
	save_current_changelog()
	GlobalGameplayValues.user_message_log("Uploaded drawing")


func send_steps():
	
	var all: String = ""
	for i in GlobalGameplayValues.footsteps.my_footsteps:
		all += i + "\n"
	GlobalGameplayValues.footsteps.my_footsteps.clear()

	var body = all.to_ascii_buffer()
	var headers = ["Content-type: text/csv","Content-length: " + str(len(body))]

	
	create_request(headers, HTTPClient.METHOD_POST, body)

func _on_retrieve_steps(headers, body):
	
	var new_all: String = body.get_string_from_ascii()
	GlobalGameplayValues.footsteps.read_footsteps(new_all)

func request_model():

	GlobalGameplayValues.player_controller.paused = true
	var model_exists: bool = FileAccess.file_exists(directory + model_name)
	if !model_exists:
		GlobalGameplayValues.user_message_log("Downloading world models...")
		var headers = ["Content-type: text/plain"]
		var body = GlobalNetworkValues.model_name.to_ascii_buffer()
		
		create_request(headers, HTTPClient.METHOD_POST, body)
	else:
		GlobalGameplayValues.load_model.load_gltf()

func _on_retrieve_model(headers, body):
	
	DirAccess.make_dir_recursive_absolute(directory)
	var model_file = FileAccess.open(directory + model_name, FileAccess.WRITE)
	await model_file.store_buffer(body)
	model_file.close()
	await get_tree().create_timer(0.5).timeout
	print("Done storing")
	GlobalGameplayValues.load_model.load_gltf()
	
	

func get_only_directory(only_directory):
	return only_directory.split("/")[0]
