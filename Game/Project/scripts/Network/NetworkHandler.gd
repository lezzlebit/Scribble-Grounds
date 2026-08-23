extends Node

class_name NetworkHandler

@export var Motd: Label

var network_address: String = GlobalNetworkValues.network_address
var directory: String = GlobalNetworkValues.save_directory + GlobalNetworkValues.save_folder
var changelog_filename: String = GlobalNetworkValues.changelog_filename

var current_images: Dictionary[String, String]
var new_images: Dictionary[String, String]
var required_images: Dictionary[String, String]


func _init():
	GlobalGameplayValues.network_handler = self

func _ready():
	retrieve_list()
	GlobalGameplayValues.world_textures.update_image_pool(true)
	initialize_process_timers()

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("debug_action")):
		get_one_required_image()
	if (Input.is_action_just_pressed("ui_down")):
		retrieve_list()

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
	var request: SingleRequest = SingleRequest.new()
	add_child(request)
	request.network_handler = self
	request.request_completed.connect(request._http_request_completed)
	request.timeout = 10
	headers.append("Authorization: " + GlobalNetworkValues.server_password)
	request.request_raw(network_address, headers, method, body)


# Select the correct response to data
func _http_request_completed(_result, response_code, headers, body):
	
	if response_code == 0:
		print("No response from web server!")
		GlobalGameplayValues.user_error_log("No response from web server")
		return
	
	var headers_dictionary = headers_to_dictionary(headers)
	var content_type = headers_dictionary["Content-type"]
	var request_method = headers_dictionary["Access-control-request-method"]
	
	
	if (content_type == "text/plain" && request_method == "GET"):
		_on_retrieve_list(headers_dictionary, body)
	if (content_type == "text/plain" && request_method == "POST"):
		_on_image_uploaded(headers_dictionary, body)
	if (content_type == "image/png" && request_method == "POST"):
		_on_retrieve_image(headers_dictionary, body)

func headers_to_dictionary(strings: PackedStringArray):
	print(strings)
	
	var return_dictionary: Dictionary[String, String]
	for i in strings:
		var pair = i.split(": ")
		if len(pair) > 1:
			return_dictionary[pair[0]] = pair[1]
	return return_dictionary



# Get required images (GET)
func retrieve_list():
	
	DirAccess.make_dir_absolute(directory)
	
	if (FileAccess.file_exists(directory + changelog_filename)):

		var read = FileAccess.open(directory + changelog_filename, FileAccess.READ)
		current_images = text_list_to_dictionary(read.get_as_text())
	
	
	var body = "retrieve_drawings_list".to_ascii_buffer()
	
	var headers = ["Content-type: text/plain"]
	
	create_request(headers, HTTPClient.METHOD_GET, body)

func _on_retrieve_list(_headers, body):
	
	var new_read = body.get_string_from_ascii()
	new_images = text_list_to_dictionary(new_read)
	if new_images.has("Motd"):
		if Motd != null:
			Motd.text = new_images["Motd"].replace("\\n","\n")
		new_images.erase("Motd")
	
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
	if len(required_images) >= 1:
		GlobalGameplayValues.user_message_log("Updating drawings (" + str(len(required_images)) + " remaining)")
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
	img.load(directory + filename)
	var body: PackedByteArray = img.save_png_to_buffer()
	
	
	var headers = ["Content-type: image/png","Content-name: " + filename, "Content-length: " + str(len(body))]
	
	create_request(headers, HTTPClient.METHOD_POST, body)

func create_image_offline(filename):
	current_images[filename] = str(Time.get_unix_time_from_system()).split(".")[0]
	save_current_changelog()

func _on_image_uploaded(_headers, body):
	var content = body.get_string_from_ascii()
	var pair = content.split(":")
	current_images[pair[0]] = pair[1]
	save_current_changelog()
	
	print(content)
	GlobalGameplayValues.user_message_log("Uploaded drawing")
	
func get_only_directory(only_directory):
	return only_directory.split("/")[0]
