class_name GomiPusherCodeEditSubmitWithButton
extends Node

signal on_submit_gdscript_to_execute_once(code:String)
signal on_submit_gdscript_to_execute_in_background(code_unique_name:String,code:String)
signal on_submit_gdscript_to_execute_as_main_script(code:String)
signal on_stop_gdscript_execution_by_name(code_unique_name:String)


@export var code_to_execute_editor:CodeEdit
@export var code_file_name:LineEdit

@export var button_to_submit_execute_once:Button
@export var button_to_submit_execute_in_background:Button
@export var button_to_submit_execute_as_main_script:Button
@export var button_to_stop_execute_in_background:Button

@export var button_to_zoom_in:Button
@export var button_to_zoom_out:Button

@export var min_font_size:int = 8
@export var max_font_size:int = 72
@export var font_size_step:int = 2


func _ready() -> void:
	if button_to_submit_execute_once:
		button_to_submit_execute_once.button_down.connect(submit_code_to_run_once)
	if button_to_submit_execute_in_background:
		button_to_submit_execute_in_background.button_down.connect(submit_code_to_run_in_background)
	if button_to_submit_execute_as_main_script:
		button_to_submit_execute_as_main_script.button_down.connect(submit_code_to_run_as_main_script)
	if button_to_zoom_in:
		button_to_zoom_in.button_down.connect(zoom_in_text)
	if button_to_zoom_out:
		button_to_zoom_out.button_down.connect(zoom_out_text)

	if button_to_stop_execute_in_background:
		button_to_stop_execute_in_background.button_down.connect(stop_code_execution_by_name)
	
func _exit_tree() -> void:
	if button_to_submit_execute_once:
		button_to_submit_execute_once.button_down.disconnect(submit_code_to_run_once)
	if button_to_submit_execute_in_background:
		button_to_submit_execute_in_background.button_down.disconnect(submit_code_to_run_in_background)
	if button_to_submit_execute_as_main_script:
		button_to_submit_execute_as_main_script.button_down.disconnect(submit_code_to_run_as_main_script)
	if button_to_zoom_in:
		button_to_zoom_in.button_down.disconnect(zoom_in_text)
	if button_to_zoom_out:
		button_to_zoom_out.button_down.disconnect(zoom_out_text)

func submit_code_to_run_as_main_script() -> void:
	if not code_to_execute_editor:
		return
	
	var code:String = code_to_execute_editor.text
	on_submit_gdscript_to_execute_as_main_script.emit(code)

func stop_code_execution_by_name() -> void:
	if not code_file_name:
		return
	var code_name:String = code_file_name.text if code_file_name else "default"
	if code_name.is_empty():
		code_name = "default"
	on_stop_gdscript_execution_by_name.emit(code_name)

func submit_code_to_run_once() -> void:
	if not code_to_execute_editor:
		return
	
	var code:String = code_to_execute_editor.text
	on_submit_gdscript_to_execute_once.emit(code)

func submit_code_to_run_in_background() -> void:
	if not code_to_execute_editor:
		return

	var code:String = code_to_execute_editor.text
	var code_name:String = code_file_name.text if code_file_name else "default"
	if code_name.is_empty():
		code_name = "default"
	on_submit_gdscript_to_execute_in_background.emit(code_name, code)

		
func zoom_in_text():
	if not code_to_execute_editor:
		return
	var new_size:int = clampi(code_to_execute_editor.get_theme_font_size("font_size") + font_size_step, min_font_size, max_font_size)
	code_to_execute_editor.add_theme_font_size_override("font_size", new_size)
	
func zoom_out_text():
	if not code_to_execute_editor:
		return
	var new_size:int = clampi(code_to_execute_editor.get_theme_font_size("font_size") - font_size_step, min_font_size, max_font_size)
	code_to_execute_editor.add_theme_font_size_override("font_size", new_size)
