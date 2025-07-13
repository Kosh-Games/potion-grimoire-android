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
@onready var sprite: Sprite2D = $Sprite2D # The main pot sprite
@onready var plant_sprite: Sprite2D = $PlantSprite # A separate sprite for the plant
@onready var collect_button: TextureButton = $CollectButton # A button for collecting

func _ready():
	## Connect the collect button's signal
	collect_button.pressed.connect(_on_collect_pressed)
	## Connect to the main input event for this node
	self.input_event.connect(_on_input_event)

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
func initialize(server_data: Dictionary, _definition: ItemDefinition):
	self.item_id = server_data.item_id

	# Set initial state based on server data
	var timer_data = server_data.get("timer")
	if timer_data and timer_data is Dictionary:
		# We need to know which ingredient is growing. This should be added
		# to the PlayerItemResponse from the server in the future.
		# For now, we can't know, so we can't show the right plant.
		self.growing_ingredient_id = timer_data.get("resource_id")
		self.time_left = timer_data.get("time_left_seconds", 0.0)
		self.current_state = State.READY_TO_COLLECT if timer_data.get("is_finished", false) else State.GROWING
	else:
		self.current_state = State.EMPTY

	update_visuals()

## This function updates what the player sees based on the current state
func update_visuals():
	match current_state:
		State.EMPTY:
			plant_sprite.visible = false
			collect_button.visible = false
		State.GROWING:
			plant_sprite.visible = true
			collect_button.visible = false
		# TODO: Set texture to "growing" sprite
		State.READY_TO_COLLECT:
			plant_sprite.visible = true
			collect_button.visible = true
# TODO: Set texture to "grown" sprite

# This handles when the pot itself is clicked
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventScreenTouch and event.is_pressed():
		if current_state == State.EMPTY:
			## Emit a signal to tell the UI to open the ingredient selection menu
			print("Empty pot clicked! Opening ingredient selection...")
			SignalBus.emit_signal("pot_selected_for_planting", self)
		else:
			print("The pot is not empty, not reacting")

# This fuction handles  when the collect button (over the grown plant) is clicked
func _on_collect_pressed():
	if current_state == State.READY_TO_COLLECT:
		print("Collecting from pot ", item_id)
		# TODO: Send collection request to NetworkManager
