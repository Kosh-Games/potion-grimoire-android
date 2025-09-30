extends CanvasLayer

@export var ResourceManager: Node
@export var item_scene: PackedScene
@export var grid_container: GridContainer
@export var back_button: TextureButton

var target_pot: Pot = null

func _ready():
	## Hide at the start
	self.visible = false
	## Listen for the signal from any pot that gets clicked
	SignalBus.pot_selected_for_planting.connect(_on_pot_selected)
	back_button.pressed.connect(on_back_button_pressed)
	

func _on_pot_selected(pot_instance: Pot):
	# Store a reference to the pot that was clicked
	self.target_pot = pot_instance
	# Populate the list and show the UI
	populate_list()
	self.visible = true

func populate_list():
	# Clear any old items
	if grid_container.get_child_count() > 0:
		for child in grid_container.get_children():
			child.queue_free()

	# Get all ingredients from the resource manager
	var all_ingredients: Dictionary = ResourceManager.ingredients
	for ingredient_id in all_ingredients:
		var ingredient_res = all_ingredients[ingredient_id]

		var item_instance: IngredientSelectItem = item_scene.instantiate()
		grid_container.add_child(item_instance)
		item_instance.set_data(ingredient_res)
		# Connect to this specific item's "chosen" signal
		item_instance.chosen.connect(_on_ingredient_chosen)
		
# TODO: debug the function and see if the right argument is being passed when it is called by the button
func _on_ingredient_chosen(ingredient: IngredientResource):
	# When an ingredient is chosen, tell the target pot to start growing it
	if is_instance_valid(target_pot):
		target_pot.start_growing(ingredient)

	# Hide the UI
	self.visible = false
	self.target_pot = null


func on_back_button_pressed():
	self.visible = false
