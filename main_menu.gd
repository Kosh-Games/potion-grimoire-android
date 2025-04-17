extends Control

@export var start_game_scene: PackedScene
@export var old_scene: Node

var _loading_scene = null
var start_game_scene_loaded: Resource = null


func _ready() -> void:
	var path: String = start_game_scene.get_path()
	# Temporary variable for initial setup
	var load_request: int = ResourceLoader.load_threaded_request(path)

	# Move to persistent storage
	_loading_scene = load_request

	# Now we can safely use _loading_scene throughout the function
	while _loading_scene != null:
		var status: int = ResourceLoader.load_threaded_get_status(path)

		while status < 1.0:
			await get_tree().process_frame
		var resource: Resource = ResourceLoader.load_threaded_get(path)
		_loading_scene = null  # Cleanup
		start_game_scene_loaded = resource
		print('scene loaded')



func _on_start_game_pressed() -> void:
	# Remove current scene
#	var current_scene: Node = get_tree().current_scene
#	print('current scene:', current_scene.name)
	
	# Todo: Check if we need the process of removal of the old scene. Maybe we need to still keep it in memory for going back quickly
	# Todo: Move the scene moving process to the root or probably to the main child of the root
	get_tree().root.remove_child(old_scene)
	old_scene.queue_free()
	
	# Add new scene
	var instanced_scene = start_game_scene_loaded.instantiate()
	get_tree().root.add_child(instanced_scene)
	get_tree().current_scene = instanced_scene
	
