extends Node


var websocket_url = "ws://localhost:12345"

var socket = WebSocketPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var err = socket.connect_to_url(websocket_url)
	if err == OK:
		print("Connecting to %s..." % websocket_url)
		await get_tree().create_timer(2).timeout
		print("> Sending test packet.")
		socket.send_text("Test packet")
	else:
		push_error("Unable to connect.")
		set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	socket.poll()
	var state = socket.get_ready_state()
	
	var message = "test_packed".to_ascii_buffer()
	if Input.is_action_just_pressed("ui_down"): socket.send(message)
	
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet = socket.get_packet()
			print(packet)
			#if socket.was_string_packet():
				#var packet_text = packet.get_string_from_utf8()
				#print("< Got text data from server: %s" % packet_text)
			#else:
				#print("< Got binary data from server: %d bytes" % packet.size())
	
	elif state == WebSocketPeer.STATE_CLOSING:
		pass
	
	elif state == WebSocketPeer.STATE_CLOSED:
			# The code will be `-1` if the disconnection was not properly notified by the remote peer.
			var code = socket.get_close_code()
			print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
			set_process(false) # Stop processing.
	
	pass
