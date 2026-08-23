extends Node

class_name ApplyOptions

@export_category("Options")
@export var volume_slider: HSlider
@export var sensitivity_slider: HSlider
@export var left_palette: CheckBox
@export var fullscreen_mode: CheckBox
@export var tablet_driver: OptionButton
var fullscreen_mode_switch
@export_category("Applying References")
@export var palette_margin_container: Control

func _init() -> void:
	UserOptionsSaving.options_applier = self



func set_global_volume():
	var linear = volume_slider.value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(linear))

func set_palette_left():
	if GlobalGameplayValues.first_person:
		if left_palette.button_pressed:
			palette_margin_container.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
		else:
			palette_margin_container.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)

func set_fullscreen_mode():
	if fullscreen_mode_switch != fullscreen_mode.button_pressed:
		fullscreen_mode_switch = fullscreen_mode.button_pressed
		if fullscreen_mode_switch:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	


func _process(delta: float) -> void:
	if volume_slider:
		set_global_volume()
	if left_palette:
		set_palette_left()
	if sensitivity_slider:
		GlobalGameplayValues.camera_sensitivity = sensitivity_slider.value
	if fullscreen_mode:
		set_fullscreen_mode()
	

	pass
