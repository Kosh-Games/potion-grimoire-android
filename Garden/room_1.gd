class_name Room
extends Node2D

## If the player has unlocked this particular room
@export var unlocked_by_default: bool = false
## The 10 fixed positions for the pots in this room
@export var pot_slot_positions: Array[Vector2]
## The node that will be the parent of all the pots in this room
@export var pots_container: Node2D

var is_unlocked: bool = false
## An array to hold the actual pot node instances, indexed by their slot number.
var pot_slots: Array[Node]

func _ready():
	is_unlocked = unlocked_by_default

	# Resize the pot_slots array to match the number of defined positions
	pot_slots.resize(pot_slot_positions.size())
	
	if not is_unlocked:
		lock_room()

## This public function will be called by the SceneBuilder to place a pot.
func place_pot_in_slot(pot_node: Node, slot_index: int) -> void:
	if not is_unlocked:
		printerr("Attempted to place a pot in a locked room!")
		pot_node.queue_free() # Clean up the unused instance
		return
	
	# Converting to an index that fits indexes from 0 to 9
	if slot_index > 9 and slot_index < 20:
		slot_index -= 10
	elif slot_index > 19 and slot_index < 30:
		slot_index -= 20
	elif slot_index > 29:
		slot_index -= 30
	
	
	if slot_index >= 0 and slot_index < pot_slot_positions.size():
		# Check if a pot is already in that slot to avoid duplicates
		if is_instance_valid(pot_slots[slot_index]):
			pot_slots[slot_index].queue_free()

		# Set the pot's position based on our predefined array
		pot_node.position = pot_slot_positions[slot_index]
		pots_container.add_child(pot_node)
		pot_slots[slot_index] = pot_node
	else:
		printerr("Invalid slot_index % for pot.", slot_index)
		pot_node.queue_free()


## Public function to unlock the room. Will be called by SceneBuilder/ResourceManager to update the rooms status	
func unlock_room():
	print('Room is unlocked')
	
	
func lock_room():
	print("Room is locked")