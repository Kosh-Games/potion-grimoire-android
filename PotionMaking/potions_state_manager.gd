extends Node2D

const cauldron_scene = preload("uid://cc1sqlrkpbmai")
# uids of potion scenes
const all_potions: Dictionary = {
	"test_potion": "uid://ce52wljgvlrgk"
										  }
@onready var all_unlocked_potions: Array[PackedScene] = [preload(all_potions.test_potion)]

@export var new_timer_method: HTTPRequest
@export var plus_button: Control


func add_new_timer(_cauldron_id, time: float):
	# placeholder
	var timer = await get_tree().create_timer(time).timeout
	
	
func add_new_cauldron(button_position, _specs: Dictionary = {null: null}):
	var new_cauldron = cauldron_scene.instantiate()
	new_cauldron.position = button_position
	add_child(new_cauldron)





func _on_add_cauldron_pressed(extra_arg_0: Vector2) -> void:
	add_new_cauldron(extra_arg_0)
	plus_button.visible = false
	print(plus_button.name)
