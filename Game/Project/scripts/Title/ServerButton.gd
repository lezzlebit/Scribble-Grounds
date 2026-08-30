extends Control

class_name ServerButton

@export var server_name_label: Label
@export var server_status_label: Label
@export var edit_button: Button
@export var connect_button: Button

@export var requester: HTTPRequest


var manager: TitleServerManager
var server_name: String = ""
var server_folder: String = ""
var server_world: String = ""
var has_custom_world: bool = false
var server_network_address: String = ""
var server_password: String = ""
var connecting: bool = false

func connect_to_this_server():
	
	connecting = true
	connect_button.visible = false
	create_request("join_scribble_server")
	

func edit_this_server():
	manager.start_edit_server(self)

func create_button(given_folder: String, given_address: String, given_password: String):
	
	connect_button.process_mode = Node.PROCESS_MODE_DISABLED
	connect_button.visible = false
	server_status_label.text = "(checking...)"
	
	server_name = given_folder
	server_name_label.text = given_folder
	server_network_address = given_address
	server_password = given_password
	requester.request_completed.connect(_http_request_completed)
	
	create_request("ping_scribble_server")

	
	

func create_request(body_text: String):
	var body = body_text.to_ascii_buffer()
	server_status_label.modulate = Color.WHITE
	server_status_label.text = "(checking...)"
	var authorization: String = "Authorization: " + server_password + "," + GlobalNetworkValues.compatibility_version
	if len(manager.user_password_setter.text) > 0:
		authorization += "," + GlobalNetworkValues.username + "," + GlobalNetworkValues.user_password
	var headers = [authorization]
	
	requester.request_raw("http://" + server_network_address, headers, HTTPClient.METHOD_GET, body)


func set_online(is_online: bool):
	connect_button.visible = false
	if is_online:
		connect_button.process_mode = Node.PROCESS_MODE_INHERIT
		connect_button.visible = true
		server_status_label.text = "(online)"
		server_status_label.modulate = Color.AQUA
		
	if !is_online:
		connect_button.process_mode = Node.PROCESS_MODE_DISABLED
		connect_button.visible = false
		server_status_label.text = "(no response)"
		server_status_label.modulate = Color.DARK_GRAY


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
			if connecting: manager.connect_to_server(self)
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
