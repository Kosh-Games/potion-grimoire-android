extends Node

# You'll need to assign these container nodes from your main scene in the editor
@export var brewery_container: Node
@export var garden: Node
@export var cats_container: Node

@export var cauldron_carousel: Node
@export var ResourceManager: Node

func _ready():
	# SceneBuilder listens for when the user's items have been received
	SignalBus.user_items_received.connect(_on_user_items_received)

func _on_user_items_received(data: Array):

	clear_existing_items()
	data.sort_custom(func(a, b): return a.get("display_index") < b.get("display_index"))
	print("SceneBuilder received and sorted user items. Building scene...")

	for item_data in data:
		# Step 1: Get the server-defined properties for this type
		var item_type: ItemTypeResource = ResourceManager.get_item_type(item_data.type_id)

		if not item_type:
			printerr("Cannot build item. Unknown item_type_id in ResourceManager: %s" % item_data.type_id)
			continue

		# Step 2: Get the local asset definition for this type
		var definition: ItemDefinition = GameDefinitions.get_definition(item_data.type_id)
		print('ITEM DEFINITION %s' % definition)

		if not definition:
			printerr("Cannot build item. No ItemDefinition found in GameDefinitions for type_id: %s" % item_data.type_id)
			continue

		# Step 3: Instantiate the scene from the local definition
		if not definition.scene:
			printerr("Cannot build item '%s'. Its ItemDefinition is missing a scene reference." % item_type.item_name)
			continue
		var new_item_instance: Node = definition.scene.instantiate()
		print('ITEM INSTANCE %s' % new_item_instance)

		# Step 4: Initialize the new instance with ALL the data it needs
		if new_item_instance.has_method("initialize"):
			new_item_instance.initialize(item_data, definition, ResourceManager)
			print('the instance is initialised')
			print(item_type.area)

		# Step 5: Add the new instance to the correct container using the 'area' from the ItemTypeResource
		match item_type.area:
			Enums.ItemTypeArea.Brewery:
				if cauldron_carousel and cauldron_carousel.has_method("add_cauldron"):
					cauldron_carousel.add_cauldron(new_item_instance)
					print('added the cauldron to the carousel')
				else:
					printerr("Cauldron Carousel is not set up correctly in SceneBuilder!")
			Enums.ItemTypeArea.Garden:
				garden.place_pot(new_item_instance, item_data["display_index"])
			Enums.ItemTypeArea.Cats:
				cats_container.add_child(new_item_instance)
			_:
				printerr("Cannot place item '%s'. Unknown area: %s" % [item_type.item_name, item_type.area])

func clear_existing_items():
	for child in brewery_container.get_children():
		child.queue_free()
#	for child in garden_container.get_children():
#		child.queue_free()
	for child in cats_container.get_children():
		child.queue_free()
