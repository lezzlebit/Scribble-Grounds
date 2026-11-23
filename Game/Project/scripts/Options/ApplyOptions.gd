extends Node

class_name ApplyOptions

@export_category("Options")
@export var reflection_quality: HSlider
@export var volume_slider: HSlider
@export var sensitivity_slider: HSlider
@export var left_palette: CheckBox
@export var fullscreen_mode: CheckBox
@export var tablet_driver: OptionButton
@export var undo_history: SpinBox
@export var ui_scale: SpinBox
@export var vertical_sync: CheckBox
@export var toggle_sprint: CheckBox
var fullscreen_mode_switch
var vertical_sync_switch
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
	
func set_reflection_quality():

	if GlobalGameplayValues.reflection_camera != null:
		GlobalGameplayValues.reflection_camera.can_view_objects = reflection_quality.value != 0
		GlobalGameplayValues.reflection_camera.pixel_size = (reflection_quality.max_value + 1) - reflection_quality.value
	
func set_undo_history():
	GlobalGameplayValues.undo_limit = undo_history.value

func set_vertical_sync():
	if vertical_sync_switch != vertical_sync.button_pressed:
		vertical_sync_switch = vertical_sync.button_pressed
		if vertical_sync.button_pressed:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func set_ui_scale():
	get_window().content_scale_factor = ui_scale.value

func _process(delta: float) -> void:
	
	if vertical_sync:
		set_vertical_sync()
	
	if reflection_quality:
		set_reflection_quality()
	if volume_slider:
		set_global_volume()
	if left_palette:
		set_palette_left()
	if sensitivity_slider:
		GlobalGameplayValues.camera_sensitivity = sensitivity_slider.value
	if fullscreen_mode:
		set_fullscreen_mode()
	if undo_history:
		set_undo_history()
		
	if ui_scale:
		set_ui_scale()
		
	if toggle_sprint:
		GlobalGameplayValues.sprint_is_toggle = toggle_sprint.button_pressed
	

	pass
