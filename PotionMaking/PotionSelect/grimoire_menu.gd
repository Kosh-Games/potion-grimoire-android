extends CanvasLayer # Using CanvasLayer is good for UI that floats above the game world

@export var ResourceManager: Node

# The scene for each individual item in our list.
@export var potion_item_scene: PackedScene

# The container inside the ScrollContainer where we will add the items.
@export var item_list_container: GridContainer

# Reference to the grimoire button in the main game scene.
@export var grimoire_button: Node # Or whatever node you use

# Reference to the main carousel script.
@export var cauldron_carousel: Node

func _ready():
	# Hide this UI at the start of the game.
	self.visible = false
	grimoire_button.pressed.connect(show_ui)

func show_ui():
	self.visible = true
	populate_potion_list()

func hide_ui():
	self.visible = false

func populate_potion_list():
	# First, clear any old items from the list.
	for child in item_list_container.get_children():
		child.queue_free()

	# Get all the potion definitions from our resource manager.
	var all_potions: Dictionary = ResourceManager.potions

	for potion_id in all_potions:
		var potion_resource: PotionResource = all_potions[potion_id]

		# Create an instance of our item scene.
		var new_item: Node = potion_item_scene.instantiate()

		# Add it to the list and set its data.
		item_list_container.add_child(new_item)
		new_item.set_potion_data(potion_resource)

		# Connect to its signal.
		new_item.potion_selected.connect(_on_potion_selected)

func _on_potion_selected(potion_id: String):
	print("Player selected potion with ID: ", potion_id)

	# Hide the grimoire UI.
	hide_ui()

	# Get the currently active cauldron from the carousel.
	var active_cauldron = cauldron_carousel.get_current_cauldron()

	if active_cauldron and active_cauldron.has_method("start_brewing_with_potion"):
		# Tell the cauldron to start brewing this potion.
		active_cauldron.start_brewing_with_potion(potion_id)
	else:
		printerr("Could not find an active cauldron or it's missing the brew function!")
