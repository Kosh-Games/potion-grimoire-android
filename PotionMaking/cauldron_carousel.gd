extends Control

# Assign this node in the editor. This is the center point for the visible cauldron.
@export var cauldron_container: Node2D

# This will hold all the instantiated cauldron scenes from the SceneBuilder
var cauldrons: Array[Node] = []
var current_index: int = -1

# Swipe detection variables
var swipe_start_pos: Vector2 = Vector2.ZERO
var is_swiping: bool = false
const SWIPE_THRESHOLD: float = 75.0 # Min pixels to drag to be considered a swipe

func _input(event: InputEvent) -> void:
	# Detect start of a touch/drag
	if event is InputEventScreenTouch and event.is_pressed():
		swipe_start_pos = event.position
		is_swiping = true

	# Detect end of a touch/drag
	if event is InputEventScreenTouch and not event.is_pressed():
		if is_swiping:
			is_swiping = false
			var swipe_end_pos: Vector2 = event.position
			var swipe_vector: Vector2  = swipe_end_pos - swipe_start_pos

			# Check if the swipe was long enough and primarily horizontal
			if abs(swipe_vector.x) > SWIPE_THRESHOLD and abs(swipe_vector.x) > abs(swipe_vector.y):
				if swipe_vector.x < 0:
					show_next()
				else:
					show_previous()

# Public function for the SceneBuilder to add cauldrons
func add_cauldron(cauldron_node: Node) -> void:
	cauldrons.append(cauldron_node)
	print('added the cauldron to the list')
	# If this is the first cauldron, display it immediately
	if current_index == -1:
		current_index = 0
		display_current_cauldron()

func show_next() -> void:
	if cauldrons.size() < 2: return # Can't swipe if there's only one
	var old_index: int = current_index
	current_index = (old_index + 1) % cauldrons.size()
	display_current_cauldron(1)

func show_previous() -> void:
	if cauldrons.size() < 2: return
	var old_index: int = current_index
	current_index = (old_index - 1 + cauldrons.size()) % cauldrons.size()
	display_current_cauldron(-1)

func display_current_cauldron(from_direction: int = 0) -> void: # 1 for next, -1 for previous
	var current_cauldron = cauldron_container.get_children()[0] if cauldron_container.get_child_count() > 0 else null
	var new_cauldron: Node = cauldrons[current_index]

	if current_cauldron == new_cauldron: return

	# --- Animate with Tween ---
	var tween: Tween = create_tween()
	var offscreen_x: float = get_viewport_rect().size.x # A position just off-screen

	# Position the new cauldron off-screen before starting the animation
	new_cauldron.position.x = offscreen_x * from_direction
	cauldron_container.add_child(new_cauldron)

	# Animate the new cauldron moving to the center
	tween.tween_property(new_cauldron, "position:x", 0.0, 0.3).set_trans(Tween.TRANS_QUAD)

	# Animate the old cauldron moving away, if it exists
	if current_cauldron:
		tween.parallel().tween_property(current_cauldron, "position:x", -offscreen_x * from_direction, 0.3).set_trans(Tween.TRANS_QUAD)

		tween.tween_callback(func():
			if is_instance_valid(current_cauldron) and current_cauldron.get_parent():
				current_cauldron.get_parent().remove_child(current_cauldron)
		)
