extends CharacterBody3D


@export var CameraPivot: Node3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005
var vertical_look: float

var GameValues = GlobalGameplayValues


func _unhandled_input(event: InputEvent):
	
	if GameValues.first_person:
	
		if event is InputEventMouseButton:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif event.is_action_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * SENSITIVITY)
			CameraPivot.rotation.x = vertical_look
			vertical_look += (-event.relative.y * SENSITIVITY)
			vertical_look = clampf(vertical_look, -PI/2, PI/2)
	else: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func process_movement(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func _physics_process(delta: float) -> void:
	if GameValues.first_person:
		process_movement(delta)
