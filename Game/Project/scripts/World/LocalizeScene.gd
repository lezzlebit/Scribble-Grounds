@tool
extends Node
@export_tool_button("Localize Scene") var make_scene_local = localize_scene

func get_all_children(node):
	var nodes : Array = []
	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(get_all_children(N))
		else:
			nodes.append(N)
	return nodes

func localize_scene():
	for i in get_all_children(get_tree().root):
		print(i.name)
