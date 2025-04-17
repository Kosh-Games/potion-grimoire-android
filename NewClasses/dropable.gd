extends Area2D
class_name Dropable


@export var amount_label: Node
@export var item: Node = self
@export var specs: Dictionary = {
	"id": '',
	"amount": 1,
	"name": 'name'
								   }
@export var image: Node


var is_dragging: bool = false
var offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO

func _ready():
	original_position = position
	# Enable input detection
	item.input_pickable = true
	amount_label.text = str(specs.amount)
	image = item.find_child('Image')
	
	# Connect the signal
	connect("input_event", self._on_input_event)

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int):
	if item and not is_dragging:
			# Android touch start
			print('started dragging')
			is_dragging = true
			offset = event.position - global_position

	elif event is InputEventScreenDrag and is_dragging:
		# Update position during drag on Android
		item.global_position = event.position - offset
	
	elif event is InputEventScreenTouch:
		print('touch and true')
		is_dragging = true
		
		
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		pass
	else:
		if event is InputEventScreenDrag and is_dragging:
			print('dragging')
			item.global_position = event.position - offset
		else:
			var placed: Array = can_be_placed()
			if placed[0]:
				for area in placed[1]:
					var placable_item = area.get_parent()
					await placable_item.add_ingredient(item)
				if specs.amount > 0:
					# updating label
						amount_label.text = str(specs.amount)
						item.position = original_position
				else:
					item.queue_free()
			else:
				item.position = original_position
				is_dragging = false
	
			
		
	
		
func can_be_placed() -> Array:
	var result
	var areas
	areas = item.get_overlapping_areas()
	
	if areas:
		result = true
	else:
		result = false

	return [result, areas]
