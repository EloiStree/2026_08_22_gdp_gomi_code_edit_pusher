
class_name GomiPusherRunTextAsGdScript
extends Node

signal on_destroy_previous_node_start(node:Node)
signal on_destroy_previous_node_end()
signal on_created_node(node_created:Node)
signal on_created_node_with_code(node_created:Node, code:String)
signal on_fail_to_load_code(code:String)

@export_multiline()
var given_godot_code_to_execute:String="""
extends Node
func _ready():
	print("Hello World")

func _process(delta: float) -> void:
	pass
"""

@export var where_to_create_node:Node
@export var load_code_inspector_at_ready:bool=true
@export var unique_code_file_name:String ="change_my_name.gd"
@export var create_node_as_node_3d:bool=false

@export_group("Debug")
@export var created_node_holding_code:Node



func _ready() -> void:
	if  load_code_inspector_at_ready:
		await get_tree().create_timer(0.1).timeout
		load_and_run_text_as_godot_script(given_godot_code_to_execute)

func load_and_run_code_from_godot_script(script: Script):
	var local_path = script.resource_path
	var text = FileAccess.get_file_as_string(local_path)
	load_and_run_text_as_godot_script(text)

func unload_current_code():
	on_destroy_previous_node_start.emit(created_node_holding_code)
	if created_node_holding_code:
		## if it existe. kill it. I means... lets is free 
		created_node_holding_code.queue_free()
		created_node_holding_code = null
	on_destroy_previous_node_end.emit()		

func load_and_run_text_as_godot_script(code:String):
	## When we start we need to destroy the previous one.
	unload_current_code()
	## code cant be loaded like that. you need to load from file
	## we can create the file in folde of our application
	var script_path: String = "user://"+unique_code_file_name
	## print(script_path)
	## to see where it is store in the end
	print(ProjectSettings.globalize_path(script_path))
	var file_connection =FileAccess.open(script_path, FileAccess.WRITE)
	if file_connection:
		file_connection.store_string(code)
		file_connection.close()
	else:
		push_error("File was not created")
		on_fail_to_load_code.emit(code)
		return
	
	# lets try to execute it now.
	var script: Script = ResourceLoader.load(
		script_path,
		"GDScript",
		ResourceLoader.CACHE_MODE_IGNORE
	)

	if not script is GDScript:
		push_error("That not a Godot Script")
		on_fail_to_load_code.emit(code)
		return
	
	## we need for that a node
	var node :Node =  Node3D.new() if create_node_as_node_3d else Node.new()
	# we have a new node but not yet in the scene
	node.set_script(script)
	# he has our code 
	node.set_process(true)
	# he now use _process(delta)
	node.set_physics_process(true)
	# in case we need it later
	
	## now we add it in the scene
	created_node_holding_code = node
	if where_to_create_node:
		where_to_create_node.add_child(node)
	else:
		add_child(node)
		
	on_created_node.emit(node)
	on_created_node_with_code.emit(node,code)
	
	

	
	
