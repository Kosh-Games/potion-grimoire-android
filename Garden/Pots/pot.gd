class_name Pot
extends Area2D

## The state machine for the pot
enum State {
	EMPTY, 
	GROWING,
	VERIFYING,
	READY_TO_COLLECT
}
var current_state: State = State.EMPTY

# Data from the server and local definitions
var item_id: String
var definition: ItemTypeResource
var growing_ingredient_id: String
var growring_ingredient: IngredientResource
var time_left: float = 0.0

### On-ready variables for child nodes
@export var pot_sprite: Sprite2D ## The main pot sprite
@export var plant_sprite: Sprite2D ## A separate sprite for the plant
## The label to display the remaining grow time.
@export var timer_label: Label

func _ready():
	SignalBus.item_state_updated.connect(_update_state_from_server)
	SignalBus.item_collected.connect(_on_item_collected)
	update_visuals()
	
## We check timers every frame
func _process(delta: float):
	if current_state == State.GROWING:
		time_left -= delta
		if time_left > 0:
			# TODO: test if the division makes the right assumption about the amount of minutes every time, regardless of the number after the decimal point
			var minutes: int = int(time_left) / 60
			var seconds: int = int(time_left) % 60
			timer_label.text = "%02d:%02d" % [minutes, seconds]
		else:
			print("Pot #%s has finished growing!" % item_id)
			
			# Stop the timer from going negative and hide the label.
			time_left = 0
			timer_label.text = "Ready!"
			
			current_state = State.VERIFYING
			# Disable the pot visually while we wait
			self.modulate = Color(0.7, 0.7, 0.7)
			
			SignalBus.emit_signal("request_single_item_update", self.item_id)
			

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
			timer_label.visible = false
			
		State.GROWING:
			plant_sprite.texture = growring_ingredient.art_resource.growing_sprite
			plant_sprite.visible = true
			timer_label.visible = true
			
		State.READY_TO_COLLECT:
			plant_sprite.texture = growring_ingredient.art_resource.ready_sprite
			plant_sprite.visible = true
			
		State.VERIFYING:
			pass							

## This handles when the pot itself is clicked
func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# We only care about the moment the player taps down.
	if not (event is InputEventScreenTouch and event.is_pressed()):
		return

	# Now, decide what to do based on the pot's current state.
	match current_state:
		State.EMPTY:
			# If the pot is empty, emit the signal for the UI to open.
			SignalBus.emit_signal("pot_selected_for_planting", self)

		State.READY_TO_COLLECT:
			# If the pot is ready, trigger the collect logic.
			# We'll connect the button later, but this works too.
			_on_collect_pressed()

		State.GROWING:
			# If it's growing, do nothing.
			print("[NOT PROCESSING UNPUT] This pot is still growing.")

		State.VERIFYING:
			pass
# This fuction handles  when the collect button (over the grown plant) is clicked
func _on_collect_pressed() -> void:
	if current_state != State.READY_TO_COLLECT:
		return

	print("Collecting from pot #%s" % item_id)
	var data: Dictionary[Variant, Variant]     = {"user_id": PlayerData.user_id}
	var metadata: Dictionary[Variant, Variant] = {"type": "collect_item", "item_id": self.item_id}
	var endpoint: String                       = "/items/%s/collect" % self.item_id
	NetworkManager.post_request(endpoint, data, metadata)


func start_growing(ingredient_resource: IngredientResource) -> void:
	# TODO: create a check if the player has the seeds in their inventory
	if current_state != State.EMPTY:
		print("[NOT PROCESSING UNPUT] Cannot plant, pot is not empty!")
		return

	print("[ITEM STATE INFO] Pot #%s starting to grow ingredient #%s" % [item_id, ingredient_resource.id])
	
	self.growring_ingredient = ingredient_resource

	# Send the request to the server
	var data: Dictionary     = {
					"user_id": PlayerData.user_id, 
					"seed_rarity": Enums.Rarity.keys()[ingredient_resource.rarity], # Or however you determine this
					"ingredient_id": ingredient_resource.id
				}
	var metadata: Dictionary = {"type": "start_growing", "item_id": self.item_id}
	var endpoint: String     = "/items/%s/grow" % self.item_id
	NetworkManager.post_request(endpoint, data, metadata)
	

	
func _update_state_from_server(server_data: Dictionary) -> void:
	if self.item_id == server_data["item_id"]:
		# Restore the pot's appearance
		self.modulate = Color(1, 1, 1)
	
		var timer_info = server_data.get("timer")
		if timer_info and timer_info.get("is_finished", false):
			print("[ITEM STATE INFO] Server confirms pot #%s is finished. Moving to READY_TO_COLLECT." % item_id)
			current_state = State.READY_TO_COLLECT
		elif timer_info and not timer_info["is_finished"]:
			# This can happen if there's a clock mismatch.
			# The server says it's not done, so we trust it and go back to growing.
			print("[ITEM STATE INFO] Server says pot #%s is NOT finished. Resyncing timer." % item_id)
			self.time_left = timer_info.get("time_left_seconds")
			current_state = State.GROWING
		else:
			self.current_state = State.EMPTY
			print("[ITEM STATE INFO] Server says pot #%s is Empty. Removing timer." % item_id)
			
		update_visuals()
	else:
		return
		
		
func _on_item_collected(item_id_from_signal: String, response_data: Dictionary) -> void:
	if item_id_from_signal != self.item_id:
		return

	print("Server confirmed collection for pot '%s'. Result: %s" % [self.item_id, response_data])
	# Reset the cauldron to its idle state
	self.current_state = State.EMPTY
	self.growring_ingredient = null
	update_visuals()
