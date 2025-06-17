extends Node

# Dictionaries to hold all our game data, indexed by ID
var item_types: Dictionary = {}
var ingredients: Dictionary = {}
var potions: Dictionary = {}

# We'll need a new GET method in our NetworkManager for this
func _ready():
	# When the game starts, after login, we'll fetch all this data
	SignalBus.login_successful.connect(fetch_user_items)
	SignalBus.user_items_recieved.connect(on_user_items_received)

func fetch_user_items(_user_id):
	print("New version of items is ready, downloading...")
	# This assumes you have a GET method in NetworkManager
	# and a new endpoint like /items/ that returns all static item types
	NetworkManagerGlobal.get_request("/items/{user_id}".format({"user_id": _user_id}), {"type": "fetch_user_items"})
	
# NetworkManager.get_request("/ingredients/", {"type": "fetch_ingredients"})
# NetworkManager.get_request("/potions/", {"type": "fetch_potions"})

func on_user_items_received(data: Array):
	for item_data in data:
#		var res = ItemTypeResource.new()
#		res.type_id = item_data["id"]
#		res.item_name = item_data["name"]
#		res.max_level = item_data["max_level"]
#		res.area = item_data["area"]
#		# IMPORTANT: We need to map the server data to our local scenes
#		res.scene = load("res://scenes/items/" + res.item_name + ".tscn") # Example path
#
#		item_types[res.type_id] = res
		print(item_data)
	print("Loaded %d item types." % item_types.size())

# Add similar functions for on_ingredients_received, etc.

# --- Public Access Functions ---
func get_item_type(type_id: String) -> ItemTypeResource:
	return item_types.get(type_id)

	
func on_item_types_received(data: Array):
	for item_data in data:
		var res = ItemTypeResource.new()
		res.type_id = item_data["id"]
		res.item_name = item_data["name"]
		res.max_level = item_data["max_level"]
		res.area = item_data["area"]
		# IMPORTANT: We need to map the server data to our local scenes
		res.scene = load("res://scenes/items/" + res.item_name + ".tscn") # Example path

		item_types[res.type_id] = res
		print(item_data)
	print("Loaded %d item types." % item_types.size())
