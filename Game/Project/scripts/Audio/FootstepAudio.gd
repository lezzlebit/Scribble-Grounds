extends Node


@export var player_movement : PlayerMovement
@export var footstep_distance: float = 1
var distance_traveled: float
@export var max_footstep_speed: float = 10

@export var sound_types: Dictionary[String, RandomAudioOneshot]

signal step_taken


func footstep(delta: float):
	var horizontal_velocity: Vector2 = Vector2(player_movement.velocity.x, player_movement.velocity.z)
	var limit_amount = clamp(horizontal_velocity.length_squared(), 0, max_footstep_speed)
	distance_traveled += limit_amount * delta
	if player_movement.is_on_floor() and limit_amount > 0.01 and GlobalGameplayValues.first_person:
		if distance_traveled >= footstep_distance:
			distance_traveled = 0
			on_step()
	else:
		distance_traveled = footstep_distance


func on_step():
	
	if player_movement.last_collider != null:
		for i in sound_types:
			if i in player_movement.last_collider.name:
				sound_types[i].play_random()
				return
	sound_types["none"].play_random()
	step_taken.emit()
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !GlobalGameplayValues.paused:
		footstep(delta)
		
	pass
