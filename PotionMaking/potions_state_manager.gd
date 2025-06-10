class_name PotionsStateManager
extends Node2D

var _active_potions: Dictionary
var _next_potion_id: int = 0
@export var SYNC_INTERVAL: float = 60.0


func start_new_potion(potion: Potion):
	var potion_id: int = _next_potion_id
	_next_potion_id += 1
	
	#creating potion data structure
	var potion_data: Dictionary = {
		id = potion_id,
		potion = potion,
		start_time = Time.get_unix_time_from_system(),
		elapsed_time_secs = 0.0,
		brewing_time = potion.brew_time_sec,
		last_sync = Time.get_unix_time_from_system()
					  }
	
	# adding to active potions
	_active_potions[potion_id] = potion_data
	
#calculation of the time each frame
func _process(delta: float) -> void:
	for potion in _active_potions:
		potion.elapsed_time_secs += delta
		
		if Time.get_unix_time_from_system() - potion.last_sync > SYNC_INTERVAL:
			potion.last_sync = Time.get_unix_time_from_system()
			_queue_server_sync(potion.id)
			
			
func _queue_server_sync(potion_id: int):
	var queued_potion = _active_potions[potion_id]
	NetworkManagerGlobal.add_potion_to_queue(queued_potion)
	
