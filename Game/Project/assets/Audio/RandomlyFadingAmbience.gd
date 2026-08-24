extends AudioStreamPlayer3D


@export var linear_volume: float = 1
@export var min_on_time: float = 2
@export var max_on_time: float = 10
@export var min_off_time: float = 2
@export var max_off_time: float = 10

@export var fade_time: float = 5.0

var on_time: float
var off_time: float

var timer: float
var is_on: bool

var linear_volume_amount: float = 1

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize_times()
	pass # Replace with function body.


func randomize_times():
	off_time = rng.randf_range(min_off_time, max_off_time)
	on_time = rng.randf_range(min_on_time, max_on_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if is_on:
		if timer > on_time:
			is_on = false
			timer = 0
			randomize_times()
	else:
		if timer > off_time:
			is_on = true
			timer = 0
			randomize_times()
	
	var target = 0
	if is_on: target = 1
	linear_volume_amount = move_toward(linear_volume_amount, target, delta / fade_time)
	volume_linear = linear_volume_amount * linear_volume
	
	
	pass
