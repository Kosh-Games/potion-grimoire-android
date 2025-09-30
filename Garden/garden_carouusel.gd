extends Node2D

## The node that will hold all the room scenes and slide.

@export var sliding_container: Node2D
@export var max_room_scenes: int = 4

@export var back_button: TextureButton
@export var menu: Control


# --- State Variables ---
var current_room_index: int = 0
var room_width: float = 1440 ## The width of one room, should match the project's viewport width


# --- Swipe/Drag Variables ---
var is_dragging: bool = false
var drag_start_x: float = 0.0
var drag_accumulated_x: float = 0.0
const SWIPE_THRESHOLD: float = 300.0
var active_snap_tween: Tween


func _ready() -> void:
	back_button.pressed.connect(back_to_menu)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			is_dragging = true
			drag_start_x = sliding_container.position.x
			drag_accumulated_x = 0
			kill_snap_tween()
		elif not event.is_pressed() and is_dragging:
			is_dragging = false
			snap_to_closest_room()

	if event is InputEventScreenDrag and is_dragging:
		# While dragging, move the container
		drag_accumulated_x += event.relative.x
	
		# 1. Calculate the new potential position
		var new_pos_x: float = drag_start_x + drag_accumulated_x

		# 2. Define the minimum and maximum allowed positions
		var min_x: float = -(max_room_scenes - 1) * room_width
		var max_x: float = 0.0

		# 3. Clamp the new position within our boundaries
		sliding_container.position.x = clampf(new_pos_x, min_x, max_x)



func snap_to_closest_room() -> void:
	if abs(drag_accumulated_x) > SWIPE_THRESHOLD:
		if drag_accumulated_x < 0:
			current_room_index = min(current_room_index + 1, max_room_scenes - 1)
		else:
			current_room_index = max(current_room_index - 1, 0)

	var target_x: float = -current_room_index * room_width

	active_snap_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	active_snap_tween.tween_property(sliding_container, "position:x", target_x, 0.35)

func kill_snap_tween() -> void:
	if is_instance_valid(active_snap_tween):
		active_snap_tween.kill()

		
	
## Function for the back button signal
func back_to_menu():
	self.visible = false
	menu.visible = true

	
## Public Function that ResourceBuilder uses to add pots
func place_pot(pot: Node, display_index: int) -> void:
	var room_node: Node2D
	if display_index < 10:
		room_node = sliding_container.get_child(0)
	elif display_index < 20:
		room_node = sliding_container.get_child(1)
	elif display_index < 30:
		room_node = sliding_container.get_child(2)
	else:
		room_node = sliding_container.get_child(3)
	print("Placing the pot in the %d", room_node.name)
	room_node.place_pot_in_slot(pot, display_index)