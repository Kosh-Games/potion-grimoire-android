extends Node

# Dictionaries to hold all our game data, indexed by ID
var item_types: Dictionary = {}
var ingredients: Dictionary = {}
var potions: Dictionary = {}

# We'll need a new GET method in our NetworkManager for this
func _ready():
	# When the game starts, after login, we'll fetch all this data
	SignalBus.login_successful.connect(fetch_user_items)

func fetch_user_items(_user_id):
	print("Login successful, fetching all game data...")
	# This assumes you have a GET method in NetworkManager
	# and a new endpoint like /items/ that returns all static item types
	NetworkManager.get_request("/items/", {"type": "fetch_item_types"})

# You would also fetch ingredients, potions, etc.
# NetworkManager.get_request("/ingredients/", {"type": "fetch_ingredients"})
# NetworkManager.get_request("/potions/", {"type": "fetch_potions"})

# We also need to add handlers in NetworkManager for these new request types.

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
	print("Loaded %d item types." % item_types.size())

# Add similar functions for on_ingredients_received, etc.

# --- Public Access Functions ---
func get_item_type(type_id: String) -> ItemTypeResource:
	return item_types.get(type_id)
