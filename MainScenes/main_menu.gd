extends Control

@export var main_menu_scene: Node
@export var brewery_scene: Node2D
@export var garden_scene: Node2D
@export var garden_button: TextureButton
@export var brewery_button: TextureButton


func _ready() -> void:
	garden_button.connect('pressed', on_garden_button_pressed)
	brewery_button.pressed.connect(_on_start_game_pressed)
#	brewery_scene = scenes_to_preload['brewery']
#	var path: String = brewery_scene.get_path()
#	# Temporary variable for initial setup
#	var load_request: int = ResourceLoader.load_threaded_request(path)
#
#	# Move to persistent storage
#	_loading_scene = load_request
#
#	# Now we can safely use _loading_scene throughout the function
#	while _loading_scene != null:
#		var status: int = ResourceLoader.load_threaded_get_status(path)
#
#		while status < 1.0:
#			await get_tree().process_frame
#		var resource: Resource = ResourceLoader.load_threaded_get(path)
#		_loading_scene = null  # Cleanup
#		start_game_scene_loaded = resource
#		print('scene loaded')



func _on_start_game_pressed() -> void:
	main_menu_scene.visible = false
	brewery_scene.visible = true
	
#	# Todo: Move the proccess higher up to specific SceneManager Node and just pass names in this function
#	var old_scene_loaded: Node = get_node('../MainMenu')
#	old_scene_loaded.visible = false
#
#	var start_scene_name
#	var scene_state: SceneState = brewery_scene.get_state()
#	if scene_state.get_node_count() > 0:
#		var original_root_name: StringName = scene_state.get_node_name(0)
#		start_scene_name = original_root_name
#	else:
#		start_scene_name = null
#	
#	if check_if_scene_is_loaded(start_scene_name) == false:
#		# Add new scene
#		var instanced_scene = start_game_scene_loaded.instantiate()
#		get_tree().root.add_child(instanced_scene) 	
#		get_tree().current_scene = instanced_scene
#		var potions_manager = instanced_scene.get_node('PotionsStateManager')
#	else:
#		var start_scene_instance: Node = get_node_or_null('/root/{scene_name}'.format({'scene_name': start_scene_name}))
#		start_scene_instance.visible = true
#	
#func check_if_scene_is_loaded(scene_name) -> bool:
#	var scene_instance: Node = get_node_or_null('/root/{scene_name}'.format({'scene_name': scene_name}))
#	if scene_instance == null:
#		return false
#	else:
#		return true

	
func on_garden_button_pressed() -> void:
	main_menu_scene.visible = false
	garden_scene.visible = true
