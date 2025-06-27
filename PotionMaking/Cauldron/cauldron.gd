extends Node2D

@export var item_id: String

@export var timer_label: Label
@export var start_button: Button
@export var collect_button: Button

var time_left: float = 0.0
var is_brewing: bool = false

func _ready():
	# Connect to the signals from the central bus
	SignalBus.brew_started.connect(_on_brew_started)
	SignalBus.potion_collected.connect(_on_item_collected)

	start_button.pressed.connect(start_brewing_pressed)
	collect_button.pressed.connect(collect_potion_pressed)

	update_visual_state()


func initialize(server_data: Dictionary, definition: ItemDefinition):
	# Set properties from the server (level, active timer, etc.)
	self.item_id = server_data["item_id"]
	# ... set level, timer, etc. ...

	# Set properties from the local definition (visuals, etc.)
	# This assumes your cauldron scene has a Sprite2D node named CauldronSprite
	var sprite_node = $CauldronImage # Or the correct path
	if sprite_node and definition.display_sprite:
		sprite_node.texture = definition.display_sprite

	# You can also configure other things from the definition
	# var animation_player = $AnimationPlayer
	# var anim_name = definition.custom_properties.get("idle_animation", "default_idle")
	# animation_player.play(anim_name)

	update_visual_state()

func _process(delta):
	if is_brewing and time_left > 0:
		time_left -= delta
		timer_label.text = "Time: %d" % int(time_left)
		if time_left <= 0:
			is_brewing = false
			# The server will be the source of truth, but we can update UI for responsiveness
			update_visual_state()

func start_brewing_pressed():
	var mock_potion_id: String = item_id # Replace with a real one
	var data: Dictionary       = {
							 "user_id": NetworkManagerGlobal.user_id, # We still need the user_id
							 "potion_id": mock_potion_id
						 }
	# Pass metadata including THIS cauldron's item_id
	var metadata: Dictionary = {
					   "type": "start_brewing",
					   "item_id": self.item_id
				   }
	var endpoint: String     = "/items/%s/brew" % self.item_id
	NetworkManagerGlobal.post_request(endpoint, data, metadata)

func collect_potion_pressed():
	var data: Dictionary     = {"user_id": NetworkManagerGlobal.user_id}
	var metadata: Dictionary = {
				   "type": "collect_item",
				   "item_id": self.item_id
			   }
	var endpoint: String     = "/items/%s/collect" % self.item_id
	NetworkManagerGlobal.post_request(endpoint, data, metadata)

# --- Signal Handlers ---

func _on_brew_started(id_from_signal: String, server_response: Dictionary) -> void:
	# Check if the signal is for THIS cauldron
	if id_from_signal != self.item_id:
		return

	print("'%s' received brew_started signal. Response: %s" % [self.item_id, server_response])
	# Let's assume the API response for starting a brew gives us the timer length
	# Based on your API spec, we can't know for sure, so let's check PlayerItemResponse
	# to see what a timer looks like. It has 'time_left_seconds'.
	# We'll assume the brew response also contains this.
	if server_response.has("time_left_seconds"):
		time_left = server_response["time_left_seconds"]
		is_brewing = true
		update_visual_state()
	else:
		# Fallback if the brew response is empty, maybe get from a local resource
		print("Brew response didn't contain time_left_seconds, using a default.")
		time_left = 60.0 # Default to 60 seconds
		is_brewing = true
		update_visual_state()


func _on_item_collected(id_from_signal: String, server_response: Dictionary) -> void:
	if id_from_signal != self.item_id:
		return
	
	# Todo: Add the process of updating the user inventory
	print("'%s' collected successfully!" % self.item_id)
	time_left = 0
	is_brewing = false # Reset state
	update_visual_state()


func update_visual_state():
	if is_brewing:
		start_button.visible = false
		collect_button.visible = false
		timer_label.visible = true
	elif time_left <= 0 and not is_brewing and not start_button.visible:
		start_button.visible = false
		collect_button.visible = true
		timer_label.text = "Ready!"
	else:
		start_button.visible = true
		collect_button.visible = false
		timer_label.visible = false





	
