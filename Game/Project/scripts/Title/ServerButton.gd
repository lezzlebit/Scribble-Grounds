extends Control

class_name ServerButton

@export var server_name_label: Label
@export var server_status_label: Label
@export var edit_button: Button
@export var connect_button: Button
@export var offline_button: Button

@export var requester: HTTPRequest


var manager: TitleServerManager
var server_name: String = ""
var server_folder: String = ""
var server_world: String = ""
var has_custom_world: bool = false
var server_network_address: String = ""
var server_password: String = ""
var server_prefix = GlobalNetworkValues.server_prefix
var offline_server_directory = ""
var selected_changelog_name = ""

var proposed_changelog_name = ""

func connect_to_this_server():
	GlobalNetworkValues.changelog_filename = GlobalNetworkValues.default_changelog_filename
	GlobalGameplayValues.viewing_offline = false
	requester.request_completed.connect(_colors_retrieved)
	var body = "connect_retrieve_colors".to_ascii_buffer()
	var headers = ["Authorization: " + server_password + "," + GlobalNetworkValues.compatibility_version]
	requester.request_raw(server_prefix + server_network_address, headers, HTTPClient.METHOD_GET, body)



func start_server_offline():
	GlobalNetworkValues.changelog_filename = selected_changelog_name
	GlobalGameplayValues.viewing_offline = true
	server_folder = offline_server_directory
	manager.connect_to_server(self)

func get_offline_server_dir():
	var files: PackedStringArray = DirAccess.get_directories_at(GlobalNetworkValues.save_directory)
	var newest_path: Dictionary[String, int]
	var changelog_type: Dictionary[String, String]
	for i in files:
		var pairs: PackedStringArray = i.split("-")
		if len(pairs) > 1:
			if pairs[0] == server_name:
				var check_name = i
				var store_name = i
				newest_path[store_name] = get_most_recent_timestamp_from_potential_changelog(check_name)
				changelog_type[store_name] = proposed_changelog_name
	
	var newest_date: int = 0
	var final_path: String = ""
	for i in newest_path:
		if newest_path[i] > newest_date:
			final_path = i
			newest_date = newest_path[i]
			selected_changelog_name = changelog_type[i]
	if len(final_path) > 0:
		var pairs = final_path.split("-")
		if len(pairs) > 1:
			offline_server_directory = get_server_provided_name(final_path)
			print(offline_server_directory)

func get_server_provided_name(s: String):
	var pairs = s.split("-")
	if len(pairs) > 1:
		var server_provided_name = ""
		var strings_to_add: Array[String] = []
		for i in pairs:
			if i != pairs[0]: strings_to_add.append(i)
		server_provided_name = "-".join(strings_to_add)
		return server_provided_name
	else:
		return ""

func get_most_recent_timestamp_from_potential_changelog(directory_name: String) -> int: 
	
	var file_check_path = GlobalNetworkValues.save_directory + directory_name + "/"
	var highest_number: int = 0
	
	var local_selected_changelog_name = ""
	var potential_changelog_names = ["changelog_latest.txt", "changelog.txt", GlobalNetworkValues.default_changelog_filename]
	var file_read: String = ""
	for p in potential_changelog_names:
		if FileAccess.file_exists(file_check_path + p):
			var local_file_read = FileAccess.open(file_check_path + p,FileAccess.READ).get_as_text()
			if len(local_file_read) > 1:
				file_read = local_file_read
				local_selected_changelog_name = p
	
	if len(file_read) > 1:
		var changelog_dict: Dictionary[String, int] = text_list_to_dictionary(file_read)
		for c in changelog_dict:
			if changelog_dict[c] > highest_number:
				highest_number = changelog_dict[c]
	proposed_changelog_name = local_selected_changelog_name
	return highest_number


func text_list_to_dictionary(text: String):
	var all_text = text.split("\n")
	var image_return_list: Dictionary[String, int]
	for i in all_text:
		var pair = i.replace("\n", "").split(":")
		if (pair.size() > 1):
			if pair[1].is_valid_int():
				image_return_list[pair[0]] = int(pair[1])
	return image_return_list

func edit_this_server():
	manager.start_edit_server(self)

func create_button(given_folder: String, given_address: String, given_password: String):
	
	connect_button.process_mode = Node.PROCESS_MODE_DISABLED
	connect_button.visible = false
	offline_button.visible = false
	server_status_label.text = "(checking...)"
	
	server_name = given_folder
	server_name_label.text = given_folder
	server_network_address = given_address
	server_password = given_password
	requester.request_completed.connect(_http_request_completed)
	var body = "ping_scribble_server".to_ascii_buffer()
	var headers = ["Authorization: " + server_password + "," + GlobalNetworkValues.compatibility_version]
	
	requester.request_raw(server_prefix + server_network_address, headers, HTTPClient.METHOD_GET, body)

func set_online(is_online: bool):
	if is_online:
		connect_button.process_mode = Node.PROCESS_MODE_INHERIT
		connect_button.visible = true
		server_status_label.text = "(online)"
		server_status_label.modulate = Color.AQUA
		
	if !is_online:
		get_offline_server_dir()
		connect_button.process_mode = Node.PROCESS_MODE_DISABLED
		connect_button.visible = false
		
		if len(offline_server_directory) > 0:
			offline_button.visible = true
		server_status_label.text = "(no response)"
		server_status_label.modulate = Color.DARK_GRAY


func _colors_retrieved(result, response_code, headers, body):
	var content: String = body.get_string_from_ascii()
	
	
	if response_code == 200:
		GlobalGameplayValues.set_palette(content)
		manager.connect_to_server(self)
	elif response_code == 0:
		set_online(false)
	else:
		server_status_label.text = "(unusual response code)"
		server_status_label.modulate = Color.DARK_GRAY
		
		
	pass

func _http_request_completed(result, response_code, headers, body):
	var content: String = body.get_string_from_ascii()
	
	
	if response_code == 200:
		
		
		var pair = content.split("/")
		print(pair)
		if pair[0] == "scribble_server_online" or pair[0] == "graffiti_server_online":
			if len(pair) > 1:
				server_folder = pair[1]
				if len(pair) > 2:
					if len(pair[2]) > 1:
						has_custom_world = true
						server_world = pair[2]
						print(server_world)
			else:
				server_folder = server_name
			set_online(true)
		else:
			server_status_label.text = content
			server_status_label.modulate = Color.DARK_GRAY
	elif response_code == 0:
		set_online(false)
	else:
		server_status_label.text = "(unusual response code)"
		server_status_label.modulate = Color.DARK_GRAY
		
		
	pass

func _process(delta: float) -> void:
	
	
	pass
