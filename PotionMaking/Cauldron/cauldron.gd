extends Node2D

var item_id: String
var level: int = 1
var is_brewing: bool = false
var time_left: float = 0.0
var ResourceManager: Node

var brewing_potion_id: String = ""

@export var timer_label: Label
@export var collect_potion_button: TextureButton


@onready var cauldron_sprite: Sprite2D = $CauldronImage


func _ready():
	SignalBus.item_state_updated.connect(_on_item_state_updated)

	# NEW: Connect the pressed signal from our new button
	collect_potion_button.pressed.connect(_on_collect_button_pressed)

	# We will also need a signal for when collection is confirmed by the server
	SignalBus.item_collected.connect(_on_item_collected)
	
	update_visual_state()

func _process(delta: float):
	if is_brewing and time_left > 0:
		time_left -= delta
		timer_label.text = "Time: %d" % int(time_left)
		if time_left <= 0:
			SignalBus.emit_signal("request_single_item_update", self.item_id)
#			is_brewing = false
#			# The server will be the source of truth, but we can update UI for responsiveness.
#			update_visual_state()

# This is called by the SceneBuilder when the cauldron is first created.
func initialize(server_data: Dictionary, definition: ItemDefinition, resource_manager: Node):
	ResourceManager = resource_manager
	
	# This function now just calls our main state update function.
	update_state_from_data(server_data)

	# Set properties from the local definition (visuals, etc.)
	if cauldron_sprite and definition.display_sprite:
		cauldron_sprite.texture = definition.display_sprite

# This is the new central function for processing data from the server.
func update_state_from_data(data: Dictionary):
	self.item_id = data["item_id"]
	self.level = data.get("level", 1) # Use .get for safety

	var timer_data = data.get("timer")
	if timer_data is Dictionary:
		self.is_brewing = not timer_data.get("is_finished", false)
		self.time_left = timer_data.get("time_left_seconds", 0.0)
		self.brewing_potion_id = timer_data.get("resource_id")
	else:
		# No timer data means it's idle.
		self.is_brewing = false
		self.time_left = 0.0
	print('[ITEM STATUS] CAULDRON IS UPDATED')
	update_visual_state()

# This is the signal handler for when this cauldron's state is updated.
func _on_item_state_updated(item_data: Dictionary) -> void:
	# Check if the update is for THIS cauldron.
	if item_data.get("item_id") != self.item_id:
		return

	print("[ITEM STATUS] Cauldron '%s' received a state update from the server." % self.item_id)
	update_state_from_data(item_data)

# This is the function called by the Grimoire UI.
func start_brewing_with_potion(potion_to_brew_id: String) -> void:
	if is_brewing:
		print("Cannot brew, this cauldron is already busy!")
		return

	print("[ITEM STATUS] Cauldron '%s' sending request to brew potion '%s'" % [self.item_id, potion_to_brew_id])

	var data: Dictionary     = {
					"user_id": PlayerData.user_id,
					"potion_id": potion_to_brew_id
				}
	var metadata: Dictionary = {
					"type": "start_brewing",
					"item_id": self.item_id
				}
	var endpoint: String     = "/items/%s/brew" % self.item_id
	NetworkManager.post_request(endpoint, data, metadata)

# This function updates the UI based on the cauldron's current state.
func update_visual_state():
	timer_label.visible = is_brewing

	var is_ready_to_collect: bool = not is_brewing and not brewing_potion_id.is_empty()
	collect_potion_button.visible = is_ready_to_collect

	if is_ready_to_collect:
		# Get the potion resource to find its icon
		var potion_res: PotionResource = ResourceManager.get_potion(brewing_potion_id)
		print(potion_res.item_name)
		if potion_res and potion_res.icon:
			collect_potion_button.texture_normal = potion_res.icon
		else:
			# Fallback icon if something goes wrong
			collect_potion_button.texture_normal = load("res://visuals/MainPotionMaking/Potions/placeholder_potion.png")



func _on_collect_button_pressed():
	print("[ITEM STATUS] Collecting potion '%s' from cauldron '%s'" % [brewing_potion_id, item_id])

	var data: Dictionary     = {"user_id": PlayerData.user_id}
	var metadata: Dictionary = {"type": "collect_item", "item_id": self.item_id}
	var endpoint: String     = "/items/%s/collect" % self.item_id
	NetworkManager.post_request(endpoint, data, metadata)

	# hide the button to prevent double-clicks
	collect_potion_button.visible = false


func _on_item_collected(item_id_from_signal: String, response_data: Dictionary) -> void:
	if item_id_from_signal != self.item_id:
		return

	print("[ITEM STATUS] Server confirmed collection for cauldron '%s'. Result: %s" % [self.item_id, response_data])
	# Reset the cauldron to its idle state
	self.brewing_potion_id = ""
	update_visual_state()
