extends Node3D

class_name FootstepHandler

var my_footsteps: Array[String]

var recieved_footsteps: Dictionary[String, AddedFootstep]
var time_to_appear: float = GlobalNetworkValues.footstep_appear_delay
var time_to_delete: float = GlobalNetworkValues.footstep_delete_time
var process_timer: float = 0.0
var process_interval: float = 0.2

var scene_timer: float = 0.0


func _init() -> void:
	GlobalGameplayValues.footsteps = self

func round_str(r: float):
	var t = 10
	r = round(r * t) / t
	return str(r)

func position_string(pos: Vector3):
	return round_str(pos.x) + "," + round_str(pos.y) + "," + round_str(pos.z)

func create_footstep():
	
	if !GlobalGameplayValues.use_footsteps:
		return
	
	var time_round = round_str(Time.get_unix_time_from_system())
	var color_index = str(GlobalNetworkValues.footstep_color)
	var footstep_information: String = position_string(global_position) + "/" + time_round + "/" + color_index
	
	my_footsteps.append(footstep_information)

	var new_step = footstep_from_string(footstep_information)
	new_step.time -= time_to_appear
	new_step.instanced = true
	var identifier = position_string(global_position)
	if not recieved_footsteps.has(identifier):
		recieved_footsteps[identifier] = new_step
	instance_footstep(new_step)

func vec3_from_string(from: String) -> Vector3:
	var splitted = from.split(",")
	var return_vec = Vector3.ZERO
	if len(splitted) == 3:
		return_vec = Vector3(float(splitted[0]), float(splitted[1]), float(splitted[2]))
	return return_vec

func read_footsteps(read: String):
	var all = read.split("\n")
	for i in all:
		var values = i.split("/")

		if len(values) == 3:
			var new_step = footstep_from_string(i)
			var identifier = values[0]
			if not recieved_footsteps.has(identifier):
				recieved_footsteps[identifier] = new_step
	pass

func footstep_from_string(value: String) -> AddedFootstep:
	var new_step = AddedFootstep.new()
	var values = value.split("/")
	if len(values) == 3:
		new_step.step_position = vec3_from_string(values[0])
		new_step.time = float(values[1])
		new_step.color_index = int(values[2])
	return new_step;

func process_footsteps():
	var time = Time.get_unix_time_from_system()
	
	
	var footsteps_to_erase: Array[String]
	
	for i in recieved_footsteps:
		if time - time_to_appear > recieved_footsteps[i].time:
			if recieved_footsteps[i].instanced == false:
				recieved_footsteps[i].instanced = true
				if scene_timer > 1:
					instance_footstep(recieved_footsteps[i])
		if time - time_to_delete > recieved_footsteps[i].time:
			footsteps_to_erase.append(i)
	for i in footsteps_to_erase:
		recieved_footsteps.erase(i)
		
	if scene_timer < 1:
		initialize_all_footsteps()

func initialize_all_footsteps():
	for i in recieved_footsteps:
		recieved_footsteps[i].instanced = true

func instance_footstep(step: AddedFootstep):
	var new_step: SingleFootstep = SingleFootstep.new()
	new_step.target_position = Vector3.DOWN * 4
	GlobalGameplayValues.world_textures.add_child(new_step)
	new_step.position = step.step_position
	new_step.global_rotation = Vector3.ZERO
	new_step.color = Color.from_string(GlobalGameplayValues.palette_colors[step.color_index], Color.BLACK)
	new_step.cast_ray()

func _process(delta: float) -> void:
	scene_timer += delta
	process_timer += delta
	if process_timer > process_interval:
		process_footsteps()
		process_timer = 0
	pass
