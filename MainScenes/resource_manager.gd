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
	await on_item_types_received(item_types_data)

	# Step 2: Fetch the items this specific user owns
	fetch_user_items(user_id)
	var user_items_data = await SignalBus.user_items_received
	on_user_items_received(user_items_data)

	# Step 3: Fetch all possible ingredients
	fetch_ingredients()
	var ingredients_data = await SignalBus.ingredients_received
	await on_ingredients_received(ingredients_data)

	# Step 4: Fetch ingredients this specific user owns
	fetch_user_ingredients(user_id)
	var user_ingredients_data = await SignalBus.user_ingredients_received
	on_user_ingredients_received(user_ingredients_data)

	# Step 5: Fetch all possible potions
	fetch_potions()
	var potions_data = await SignalBus.potions_received
	await on_potions_received(potions_data)

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

func on_item_types_received(data: Array):
	for item_data in data:
		var res = ItemTypeResource.new()
		res.type_id = item_data["id"]
		res.item_name = item_data["name"]
		res.max_level = item_data["max_level"]
		res.area = item_data["area"]
		# IMPORTANT: You still need to map the name to a local scene file
		# res.scene = load("res://scenes/items/" + res.item_name + ".tscn")
		item_types[res.type_id] = res
	print("Processed %d item types." % item_types.size())

	
func on_ingredients_received(data: Array):
	for item_data in data:
		var res = IngredientResource.new()
		res.id = item_data["id"]
		res.item_name = item_data["name"]
		res.rarity = item_data["rarity"]
		res.area = item_data["area"]
#		res.asset_key = item_data.get("asset_key", "") # Use .get for optional keys
		ingredients[res.id] = res
	print("Processed %d ingredients." % ingredients.size())

		
func on_potions_received(data: Array):
	for item_data in data:
		var res = PotionResource.new()
		res.id = item_data["id"]
		res.item_name = item_data["name"]
		res.rarity = item_data["rarity"]
		res.collection_id = item_data["collection_id"]
#		res.asset_key = item_data.get("asset_key", "")
		potions[res.id] = res
	print("Processed %d potions." % potions.size())

		
func on_recipes_received(data: Array):
	for recipe_data in data:
		var res = RecipeResource.new()
		res.potion_id = recipe_data["potion_id"]

		var required_ings_from_server: Dictionary[String, int] = {}
		for ingredient_detail in recipe_data["ingredients"]:
			var ing_id = ingredient_detail["ingredient_id"]
			var quantity: int = ingredient_detail["quantity_required"]
			required_ings_from_server[ing_id] = quantity
			
		res.required_ingredients_dict = required_ings_from_server
		
		var required_ings_as_resources: Dictionary[IngredientResource, int] = {}
		for ingredient_id in res.required_ingredients_dict:
			var quantity = res.required_ingredients_dict[ingredient_id]
		
			var ingredient_resource: IngredientResource = get_ingredient(ingredient_id)

			if ingredient_resource:
				required_ings_as_resources[ingredient_resource] = quantity
			else:
				printerr("Recipe for potion '%s' requires an unknown ingredient with ID: '%s'" % [res.potion_id, ingredient_id])
			
		res.required_ingredients = required_ings_as_resources
		
		recipes[res.potion_id] = res

	print("Loaded and processed %d recipes." % recipes.size())


# --- User Data Functions (Dynamic data) ---

func on_user_items_received(data: Array):
	for item_data in data:
		var item_type: ItemTypeResource = get_item_type(item_data.type_id)
		print("Player has item type: ", item_type.item_name)


func on_user_ingredients_received(data: Array):
	for item_data in data:
		var item_type: IngredientResource = get_ingredient(item_data.id)
		print("Player has potion: ", item_type.item_name)


func on_user_potions_received(data: Array):
	for item_data in data:
		var item_type: PotionResource = get_potion(item_data.id)
		print("Player has potion: ", item_type.item_name)
		

# --- Public Access Functions ---
func get_item_type(type_id: String) -> ItemTypeResource:
	return item_types.get(type_id)

func get_ingredient(ing_id: String) -> IngredientResource:
	return ingredients.get(ing_id)

func get_potion(potion_id: String) -> PotionResource:
	return potions.get(potion_id)

func get_recipe_for_potion(potion_id: String) -> RecipeResource:
	return recipes.get(potion_id)
