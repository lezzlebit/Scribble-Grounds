extends CharacterBody3D

class_name PlayerMovement

@export var CameraPivot: Node3D
@export var min_speed = 2.0
@export var max_speed = 15.0
@export var seconds_to_full_speed: float = 5.0
@export var jump_velocity = 4.5
@export var max_camera_sensitivity = 0.001
@export var min_camera_sensitivity = 0.001
@export var all_camera_sensitivity_multiplier = 0.001
var vertical_look: float
var acceleration: Vector3 = Vector3.ZERO
var speed_lerp: float = 0

var GameValues = GlobalGameplayValues
var first_person_switch: bool = false
var last_collider

signal on_jump

var able_to_jump: bool

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		GlobalGameplayValues.paused = !GlobalGameplayValues.paused

func _unhandled_input(event: InputEvent):
	
	if GameValues.first_person:
	
		
		var camera_sensitivity = lerp(min_camera_sensitivity, max_camera_sensitivity, GlobalGameplayValues.camera_sensitivity) * all_camera_sensitivity_multiplier
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * camera_sensitivity)
			CameraPivot.rotation.x = vertical_look
			vertical_look += (-event.relative.y * camera_sensitivity)
			vertical_look = clampf(vertical_look, -PI/2, PI/2)
	else: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func process_movement(delta: float):
	
	var move_friction: float = 7.0
	var stop_friction: float = 25.0
	
	if not is_on_floor():
		move_friction = 4.0
		stop_friction = 2.0
		velocity += get_gravity() * delta

	if Input.is_action_pressed("jump") and is_on_floor():
		if !able_to_jump:
			on_jump.emit()
			velocity.y = jump_velocity
		able_to_jump = true
	else:
		able_to_jump = false

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		var true_speed = lerp(min_speed, max_speed, speed_lerp)
		if Input.is_action_pressed("sprint"):
			true_speed *= 1.5
		acceleration.x = lerp(acceleration.x, direction.x * true_speed, delta * move_friction)
		acceleration.z = lerp(acceleration.z, direction.z * true_speed, delta * move_friction)
		speed_lerp = lerp(speed_lerp, 1.0, delta / seconds_to_full_speed)
	else:
		speed_lerp = lerp(speed_lerp, 0.0, delta * 2)
		acceleration.x = lerp(acceleration.x, 0.0, delta * stop_friction)
		acceleration.z = lerp(acceleration.z, 0.0, delta * stop_friction)
	
	velocity.x = acceleration.x
	velocity.z = acceleration.z
	

	move_and_slide()
	var current_last_collider = get_last_slide_collision()
	if current_last_collider != null:
		last_collider = current_last_collider.get_collider(0)

func _physics_process(delta: float) -> void:
	if GameValues.first_person and !GlobalGameplayValues.paused:

		process_movement(delta)
		if !first_person_switch: 
			get_parent().reset_physics_interpolation()
			get_parent().physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	else:
		if first_person_switch:
			get_parent().reset_physics_interpolation()
			get_parent().physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	first_person_switch = GameValues.first_person and !GlobalGameplayValues.paused
