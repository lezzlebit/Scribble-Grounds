extends Node

class_name TitleServerManager


@export_subgroup("References")
@export var server_button: PackedScene
@export var main_game: PackedScene
@export var button_parent: Control
@export var username_setter: TitleInputLine
@export var disable_on_edit: Array[Control]
@export var loading_visibilities: Dictionary[Control, bool]

@export_subgroup("Editor")
@export var editor_parent: Control
@export var address_setter: TitleInputLine
@export var folder_setter: TitleInputLine
@export var password_setter: TitleInputLine
@export var create_server_button: Button
@export var edit_server_button: Button
@export var delete_server_button: Button

var server_path: String = GlobalNetworkValues.server_directory
var file_extension: String = ".txt"
var username_path: String = GlobalNetworkValues.game_directory + "username.txt"

var created_instances: Array[ServerButton]

signal make_new_button

func _ready() -> void:
	DirAccess.make_dir_absolute(GlobalNetworkValues.game_directory)
	DirAccess.make_dir_absolute(server_path)
	
	username_setter.text_input.text_changed.connect(update_username_to)
	get_username()
	
	refresh()
	close_editor()


func get_username():
	if FileAccess.file_exists(username_path):
		var r = FileAccess.open(username_path, FileAccess.READ).get_as_text()
		username_setter.text = r

func update_username_to(new_name: String):
	update_username()

func update_username():
	var w = FileAccess.open(username_path, FileAccess.WRITE)
	w.store_string(username_setter.text)

func open_path():
	OS.shell_open( ProjectSettings.globalize_path(GlobalNetworkValues.game_directory) )

func connect_to_server(button: ServerButton):
	update_username()
	if (len(username_setter.text)) <= 0:
		GlobalGameplayValues.user_error_log("Please enter a username")
		return
	for i in loading_visibilities:
		i.visible = loading_visibilities[i]
	await RenderingServer.frame_post_draw
	GlobalNetworkValues.username = username_setter.text
	

	
	GlobalNetworkValues.network_address = "http://" + button.server_network_address
	GlobalNetworkValues.save_folder = button.server_name + "-" + button.server_folder + "/"
	GlobalNetworkValues.server_password = button.server_password
	DirAccess.make_dir_absolute(GlobalNetworkValues.save_directory)
	DirAccess.make_dir_absolute(GlobalNetworkValues.save_directory + GlobalNetworkValues.save_folder)
	get_tree().change_scene_to_packed(main_game)

func set_editor_enabled(is_enabled: bool):
	editor_parent.visible = is_enabled
	if is_enabled: editor_parent.process_mode = Node.PROCESS_MODE_INHERIT
	if !is_enabled: editor_parent.process_mode = Node.PROCESS_MODE_DISABLED
	for i in disable_on_edit:
		i.visible = !is_enabled

func close_editor():
	set_editor_enabled(false)

func start_edit_server(button: ServerButton):
	set_editor_enabled(true)
	address_setter.text = button.server_network_address
	folder_setter.text = button.server_name
	password_setter.text = button.server_password
	address_setter.visible = true
	folder_setter.visible = true
	folder_setter.text_input.editable = false
	create_server_button.visible = false
	edit_server_button.visible = true
	delete_server_button.visible = true
	pass

func start_create_server():
	set_editor_enabled(true)
	address_setter.text = ""
	folder_setter.text = ""
	password_setter.text = ""
	address_setter.visible = true
	folder_setter.visible = true
	folder_setter.text_input.editable = true
	create_server_button.visible = true
	edit_server_button.visible = false
	delete_server_button.visible = false
	pass

func delete_server():
	
	var folder_name = folder_setter.text
	var path = text_file_path(folder_name)
	
	print(path)
	if FileAccess.file_exists(path):
		print("yep")
		DirAccess.remove_absolute(path)
		erase_server_object(folder_name)
		close_editor()
	

func erase_server_object(server_name):
	for i in created_instances:
			if i.server_name == server_name:
				i.queue_free()
				created_instances.erase(i)

func text_file_path(file_name):
	return server_path + file_name + file_extension

func create_server():
	
	var new_dictionary: Dictionary[String, String]
	new_dictionary["folder"] = folder_setter.text
	new_dictionary["address"] = address_setter.text
	new_dictionary["password"] = password_setter.text
	
	if len(folder_setter.text) <= 1 and len(address_setter.text) <= 1:
		GlobalGameplayValues.user_error_log("Please enter server info")
		return
	
	var text_to_write: String = dictionary_to_text(new_dictionary)
	
	var path = text_file_path(new_dictionary["folder"])
	if FileAccess.file_exists(path):
		erase_server_object(new_dictionary["folder"])
	var w = FileAccess.open(path, FileAccess.WRITE)
	w.store_string(text_to_write)
	create_server_from_dict(new_dictionary)
	close_editor()
	


func refresh():
	
	for i in created_instances:
		i.queue_free()
	
	created_instances.clear()
	

	var dir = DirAccess.open(server_path)
	
	for i: String in dir.get_files():
		if i.find(".txt"):
			var read_text = FileAccess.open(server_path + i, FileAccess.READ).get_as_text()
			var server_info = text_list_to_dictionary(read_text)
			create_server_from_dict(server_info)
	
			


func create_server_from_dict(server_info: Dictionary[String, String]):
	var server_button_instance: ServerButton = server_button.instantiate()
	button_parent.add_child(server_button_instance)
	button_parent.move_child(server_button_instance, 2)
	if server_info.has("password"):
		server_button_instance.create_button(server_info["folder"], server_info["address"], server_info["password"])
	
	server_button_instance.manager = self
	created_instances.append(server_button_instance)
	make_new_button.emit()

func dictionary_to_text(in_dict: Dictionary[String, String]):
	var text_return = ""
	for i in in_dict:
		text_return += i + "=" + in_dict[i] + "\n"
	return text_return

func text_list_to_dictionary(text: String):
	var all_text = text.split("\n")
	var return_list: Dictionary[String, String]
	for i in all_text:
		var pair = i.replace("\n", "").split("=")
		if (pair.size() > 1):
			return_list[pair[0]] = pair[1].replace("\r","")
	return return_list


func _on_button_pressed() -> void:
	pass # Replace with function body.


func _on_connect_button_pressed() -> void:
	pass # Replace with function body.
