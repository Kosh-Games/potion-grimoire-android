extends Control

## The node that will hold all cauldrons and slide left/right.
@export var sliding_container: Node2D
@export var scene_root: Node2D

# --- State Variables ---
var cauldrons: Array[Node] = []
var current_index: int = 0
var cauldron_width: float = 1440 ## The width of one cauldron "page". Should match the viewport width.

# --- Swipe/Drag Variables ---
var is_dragging: bool = false
var drag_start_x: float = 0.0
var drag_accumulated_x: float = 0.0
const SWIPE_THRESHOLD: float = 200.0 ## A threshold for the "snap" decision
var active_snap_tween: Tween

## The function that handles the movement of the carousel
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and scene_root.visible == true:
		if event.is_pressed():
			# Start of a drag/touch
			is_dragging = true
			drag_start_x = sliding_container.position.x
			drag_accumulated_x = 0
			# If a tween is running, kill it so the user can take control
			kill_snap_tween()
		elif not event.is_pressed() and is_dragging:
			# End of a drag/touch
			is_dragging = false
			snap_to_closest_cauldron()

	if event is InputEventScreenDrag and is_dragging:
		# While dragging, move the container
		drag_accumulated_x += event.relative.x
		sliding_container.position.x = drag_start_x + drag_accumulated_x

## Public function for the SceneBuilder to add cauldrons
## Public function for the SceneBuilder to add cauldrons
func add_cauldron(cauldron_node: Node) -> void:
	# Get the height of the viewport to center the cauldron vertically.
	var viewport_height: float = get_viewport().get_visible_rect().size.y

	# --- The Fix ---
	# We now set both the X and Y positions to precisely place the cauldron.
	# The X position places it horizontally in the sequence.
	# The Y position centers it vertically within the viewport.
	var new_position: Vector2 = Vector2(
						   cauldrons.size() * cauldron_width,
						   0
					   )
	cauldron_node.position = new_position

	print("Adding cauldron at position: %s" % new_position)

	cauldrons.append(cauldron_node)
	sliding_container.add_child(cauldron_node)

	# After the first cauldron is added, snap to it.
	if cauldrons.size() == 1:
		snap_to_closest_cauldron()

func snap_to_closest_cauldron() -> void:
	# If we dragged far enough, change the index
	if abs(drag_accumulated_x) > SWIPE_THRESHOLD:
		if drag_accumulated_x < 0:
			# Swiped left, go to next
			current_index = min(current_index + 1, cauldrons.size() - 1)
		else:
			# Swiped right, go to previous
			current_index = max(current_index - 1, 0)

	# Calculate the target position
	var target_x: float = (-current_index * cauldron_width)
	print(target_x)

	active_snap_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	active_snap_tween.tween_property(sliding_container, "position:x", target_x, 0.25)


func kill_snap_tween() -> void:
	# If the tween we stored is valid and running, kill it.
	if is_instance_valid(active_snap_tween):
		active_snap_tween.kill()
		active_snap_tween = null

## A public function other scripts can use to get the active cauldron
func get_current_cauldron() -> Node:
	if current_index >= 0 and current_index < cauldrons.size():
		return cauldrons[current_index]
	return null
