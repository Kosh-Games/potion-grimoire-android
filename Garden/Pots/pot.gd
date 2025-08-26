class_name Pot
extends Node2D

## The state machine for the pot
enum State {
	EMPTY, 
	GROWING, 
	READY_TO_COLLECT
}
var current_state: State = State.EMPTY

# Data from the server and local definitions
var item_id: String
var growing_ingredient_id: String
var time_left: float = 0.0

### On-ready variables for child nodes
@export var pot_sprite: Sprite2D ## The main pot sprite
@export var plant_sprite: Sprite2D ## A separate sprite for the plant

func _ready():
	update_visuals()
	
## We check timers every frame
func _process(delta: float):
	if current_state == State.GROWING:
		time_left -= delta
		if time_left <= 0:
			time_left = 0
			current_state = State.READY_TO_COLLECT
			update_visuals()

## Function that is called by the SceneBuilder to set up the pot
func initialize(server_data: Dictionary, _definition: ItemDefinition, _resource_manager: ResourceManager):
	self.item_id = server_data.item_id

	# Set initial state based on server data
	var timer_data = server_data.get("timer")
	if timer_data and timer_data is Dictionary:
		self.growing_ingredient_id = timer_data.get("resource_id")
		self.time_left = timer_data.get("time_left_seconds", 0.0)
		self.current_state = State.READY_TO_COLLECT if timer_data.get("is_finished") else State.GROWING
	else:
		self.current_state = State.EMPTY

	update_visuals()

## This function updates what the player sees based on the current state
func update_visuals():
	match current_state:
		State.EMPTY:
			plant_sprite.visible = false
		State.GROWING:
			plant_sprite.visible = true
		# TODO: Set texture to "growing" sprite
		State.READY_TO_COLLECT:
			plant_sprite.visible = true
# TODO: Set texture to "grown" sprite

## This handles when the pot itself is clicked
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# We only care about the moment the player taps down.
	if not (event is InputEventScreenTouch and event.is_pressed()):
		return

	# Now, decide what to do based on the pot's current state.
	match current_state:
		State.EMPTY:
			# If the pot is empty, emit the signal for the UI to open.
			print("Empty pot #%s clicked! Emitting signal." % item_id)
			SignalBus.emit_signal("pot_selected_for_planting", self)

		State.READY_TO_COLLECT:
			# If the pot is ready, trigger the collect logic.
			# We'll connect the button later, but this works too.
			_on_collect_pressed()

		State.GROWING:
			# If it's growing, do nothing.
			print("This pot is still growing.")

# This fuction handles  when the collect button (over the grown plant) is clicked
func _on_collect_pressed():
	if current_state == State.READY_TO_COLLECT:
		print("Collecting from pot ", item_id)
		# TODO: Send collection request to NetworkManager


func start_growing(ingredient_to_grow_id: String) -> void:
	# TODO: create a check if the player has the seeds in their inventory
	if current_state != State.EMPTY:
		print("Cannot plant, pot is not empty!")
		return

	print("Pot #%s starting to grow ingredient #%s" % [item_id, ingredient_to_grow_id])

	# Update state immediately for visual feedback
	self.current_state = State.GROWING
	self.growing_ingredient_id = ingredient_to_grow_id
	update_visuals() # This will show the "growing" sprite

	# Send the request to the server
	var data: Dictionary     = {
				   "user_id": PlayerData.user_id,
				   "seed_rarity": "Common", # Or however you determine this
				   "ingredient_id": ingredient_to_grow_id
			   }
	var metadata: Dictionary = {"type": "start_growing", "item_id": self.item_id}
	var endpoint: String     = "/items/%s/grow" % self.item_id
	NetworkManagerGlobal.post_request(endpoint, data, metadata)	
