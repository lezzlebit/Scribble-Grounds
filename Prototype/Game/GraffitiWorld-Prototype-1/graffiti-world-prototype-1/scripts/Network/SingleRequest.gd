extends HTTPRequest

class_name SingleRequest

var network_handler: NetworkHandler


func _http_request_completed(result, response_code, headers, body):
	network_handler._http_request_completed(result, response_code, headers, body)
	queue_free()
