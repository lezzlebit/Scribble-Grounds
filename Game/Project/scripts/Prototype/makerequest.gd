extends Node3D


@export var request_maker: HTTPRequest
@export var test_image: Texture2D


func _ready():
	
	request_maker.request_completed.connect(_on_request_completed)
	
	
	request_maker.request_raw("http://127.0.0.1:8000/", [], HTTPClient.METHOD_GET)
	#var img = test_image.get_image()
	#var data: PackedByteArray = img.save_png_to_buffer()
	#
	#
	#var headers = ["Content-type: image/png","Content-name: file_1.png"]
	#
	#var body = data
	#
	#request_maker.request_raw("http://127.0.0.1:8000/", headers, HTTPClient.METHOD_POST, body)


func _on_request_completed(result, response_code, headers, body):
	print("got request!")
	print(body.get_string_from_ascii())
