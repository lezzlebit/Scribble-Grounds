extends Node



var options_dictionary: Dictionary[String, String]
var directory: String = GlobalNetworkValues.game_directory + "options.txt"
var file_got: bool = false

var options_applier: ApplyOptions


func get_file():
	if file_got: return
	file_got = true
	if FileAccess.file_exists(directory):
		var options_file = FileAccess.open(directory, FileAccess.READ)
		options_dictionary = text_list_to_dictionary(options_file.get_as_text())
	else:
		var options_file = FileAccess.open(directory, FileAccess.WRITE)
		options_file.store_string("")

	pass 

func store(key: String, value: String):
	print("Stored " + key + ":" + value)
	options_dictionary[key] = value
	var to_store = dictionary_to_text(options_dictionary)
	var options_file = FileAccess.open(directory, FileAccess.WRITE)
	options_file.store_string(to_store)

func text_list_to_dictionary(text: String):
	var all_text = text.split("\n")
	var return_list: Dictionary[String, String]
	for i in all_text:
		var pair = i.replace("\n", "").split(":")
		if (pair.size() > 1):
			return_list[pair[0]] = pair[1]
	return return_list

func dictionary_to_text(in_dict: Dictionary[String, String]):
	var text_return = ""
	for i in in_dict:
		text_return += i + ":" + in_dict[i] + "\n"
	return text_return
