extends Control

class_name ServerButton

@export var server_name_label: Label
@export var server_status_label: Label
@export var edit_button: Button
@export var connect_button: Button

@export var requester: HTTPRequest

var manager: TitleServerManager
var server_folder: String = ""
var server_network_address: String = ""

func connect_to_this_server():
	manager.connect_to_server(self)

func edit_this_server():
	manager.start_edit_server(self)

func create_button(given_folder: String, given_address: String):
	
	connect_button.process_mode = Node.PROCESS_MODE_DISABLED
	connect_button.visible = false
	server_status_label.text = "(checking...)"
	
	server_folder = given_folder
	server_name_label.text = given_folder
	server_network_address = given_address
	requester.request_completed.connect(_http_request_completed)
	var body = "ping_graffiti_server".to_ascii_buffer()
	requester.request_raw("http://" + server_network_address, [], HTTPClient.METHOD_GET, body)

func set_online(is_online: bool):
	if is_online:
		connect_button.process_mode = Node.PROCESS_MODE_INHERIT
		connect_button.visible = true
		server_status_label.text = "(response recieved!)"
		
	if !is_online:
		connect_button.process_mode = Node.PROCESS_MODE_DISABLED
		connect_button.visible = false
		server_status_label.text = "(no response)"


func _http_request_completed(result, response_code, headers, body):
	var content: String = body.get_string_from_ascii()
	if response_code == 200:
		if content == "graffiti_server_online":
			set_online(true)
		else:
			server_status_label.text = "(incompatible server)"
	elif response_code == 0:
		set_online(false)
	else:
		server_status_label.text = "(unusual response code)"
		
		
	pass

func _process(delta: float) -> void:
	
	
	pass
