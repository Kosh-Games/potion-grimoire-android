extends Node2D


func _on_crystals_area_input_event(viewport:Node, event:InputEvent, shape_idx:int) -> void:
	print(event)
	print('lol')


func _on_crystals_area_mouse_entered() -> void:
	print('mouse')


func _on_crystals_area_mouse_shape_entered(shape_idx:int) -> void:
	print('shape')
	pass # Replace with function body.


func _on_crystals_test_mouse_entered() -> void:
	print('finally')
	pass # Replace with function body.
