extends Node
func _ready():
	# Connect to the signal from NetworkManager
	if not NetworkManagerGlobal.player_timers_request_completed.is_connected(_on_player_timers_received):
		NetworkManagerGlobal.player_timers_request_completed.connect(_on_player_timers_received)
	NetworkManagerGlobal.fetch_player_timers()


func _on_player_timers_received(success: bool, data: Variant):
	if success:
		var timers_data: Dictionary = data as Dictionary
		var server_timers_array     = timers_data.get("timers", []) # This is based on your TimersData model

		for server_timer in server_timers_array:
			var server_timer_dict: Dictionary = server_timer as Dictionary
			var item_id_from_server           = server_timer_dict.get("item_id", "") # Needs to be added to server response
			var time_left = server_timer_dict.get("time_left_seconds", 0)
			var server_timer_guid = server_timer_dict.get("id", "")

			if item_id_from_server == "":
				printerr("SceneLoadManager: Server timer is missing 'item_id'. Cannot assign to a game item.")
				continue

			var target_item_node: Node = find_item_node_by_id(item_id_from_server)
			var target_cauldron: Node  = target_item_node
 
			if is_instance_valid(target_cauldron) and target_cauldron.has_method("set_timer_from_server_data"):
				target_cauldron.set_timer_from_server_data(server_timer_guid, time_left)
			else:
				print("SceneLoadManager: Could not find or update item: ", item_id_from_server)
	else:
		printerr("SceneLoadManager: Failed to fetch player timers. Reason: ", data)




func find_item_node_by_id(id_str: String) -> Node: 
	return $PathToCauldronsContainer.get_node_or_null(id_str)
	
