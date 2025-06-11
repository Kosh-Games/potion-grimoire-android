extends Area2D

@export var book_animation_player: AnimationPlayer
@export var control_node: Control


func _on_input_event(_viewport:Node, event:InputEvent, _shape_idx:int) -> void:
	if event is InputEventScreenTouch and event.pressed == true:
		print('oppening grimuire')
	else:
		pass
