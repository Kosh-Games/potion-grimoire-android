extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.request_single_item_update.connect(_on_request_single_item_update)


## This is called an item when they need some kind of verification of their data
func _on_request_single_item_update(item_id_to_check: String):
	print("Verification requested for item: %s" % item_id_to_check)
	
	var endpoint: String = "/items/item_info/%s" % item_id_to_check
	
	# Add metadata
	var metadata: Dictionary[Variant, Variant] = {
		"type": "single_item_verification",
		"item_id": item_id_to_check
		}
	NetworkManager.get_request(endpoint, metadata)
