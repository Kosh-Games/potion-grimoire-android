extends Node

# Dictionaries to hold all our game data, indexed by ID
var item_types: Dictionary = {}
var ingredients: Dictionary = {}
var potions: Dictionary = {}
var recipes: Dictionary = {}

func _ready():
	# We only connect to the initial login signal.
	# This will kick off our entire loading sequence.
	SignalBus.login_successful.connect(start_loading_sequence)

# This is our new "master" loading function. It's an async function,
# which allows it to pause and wait for signals.
func start_loading_sequence(user_id):
	print("--- Starting Game Data Loading Sequence for user: %s ---" % user_id)

	# Step 1: Fetch all possible item types
	fetch_item_types()
	var item_types_data = await SignalBus.item_types_received
	on_item_types_received(item_types_data)

	# Step 2: Fetch the items this specific user owns
	fetch_user_items(user_id)
	var user_items_data = await SignalBus.user_items_received
	on_user_items_received(user_items_data)

	# Step 3: Fetch all possible ingredients
	fetch_ingredients()
	var ingredients_data = await SignalBus.ingredients_received
	on_ingredients_received(ingredients_data)

	# Step 4: Fetch ingredients this specific user owns
	fetch_user_ingredients(user_id)
	var user_ingredients_data = await SignalBus.user_ingredients_received
	on_user_ingredients_received(user_ingredients_data)

	# Step 5: Fetch all possible potions
	fetch_potions()
	var potions_data = await SignalBus.potions_received
	on_potions_received(potions_data)

	# Step 6: Fetch potions this user owns
	fetch_user_potions(user_id)

	var user_potions_data = await SignalBus.user_potions_received 
	on_user_potions_received(user_potions_data)

	# Step 7: Fetch all possible recipes
	fetch_recipes()
	var recipes_data = await SignalBus.recipes_received
	on_recipes_received(recipes_data)

	print("--- ALL GAME DATA LOADED SUCCESSFULLY ---")


# --- Fetch Functions (These remain unchanged) ---

func fetch_item_types():
	print("Fetching all item types...")
	NetworkManagerGlobal.get_request("/items/", {"type": "fetch_item_types"})

func fetch_user_items(user_id: String):
	print('Fetching user items...')
	var endpoint: String = "/items/%s" % user_id
	NetworkManagerGlobal.get_request(endpoint, {"type": "fetch_user_items"})

func fetch_ingredients():
	print('Fetching all ingredients...')
	NetworkManagerGlobal.get_request("/ingredients/", {"type": "get_ingredients"})

func fetch_user_ingredients(user_id: String):
	print('Fetching user ingredients...')
	var endpoint: String = "/ingredients/%s" % user_id
	NetworkManagerGlobal.get_request(endpoint, {"type": "get_user_ingredients"})

func fetch_potions():
	print('Fetching all potions...')
	NetworkManagerGlobal.get_request("/potions/", {"type": "get_potions"})

func fetch_user_potions(user_id: String):
	print('Fetching user potions...')
	var endpoint: String = "/potions/%s" % user_id
	NetworkManagerGlobal.get_request(endpoint, {"type": "get_user_potions"})

func fetch_recipes():
	print('Fetching all recipes...')
	NetworkManagerGlobal.get_request("/potions/recipes", {"type": "get_recipes"})


# --- On Data Received Functions (These also remain unchanged) ---

func on_user_items_received(data: Array):
	for item_data in data:
		print("User owns item: ", item_data)
	print("Processed %d user items." % data.size())

func on_item_types_received(data: Array):
	for item_data in data:
		print("Game has item type: ", item_data['name'])
	print("Processed %d item types." % data.size())

func on_ingredients_received(data: Array):
	for item_data in data:
		print("Game has ingredient: ", item_data["name"])

func on_user_ingredients_received(data: Array):
	print("User owns ingredients: %s" % data)

func on_potions_received(data: Array):
	for item_data in data:
		print("Game has potion: ", item_data["name"])
		
func on_user_potions_received(data: Array):
	for item_data in data:
		print("Player has potion: ", item_data["name"])

func on_recipes_received(data: Array):
	for item_data in data:
		print("Game has recipe: ", item_data["name"])


# --- Public Access Functions ---
func get_item_type(type_id: String) -> ItemTypeResource:
	return item_types.get(type_id)
