extends Node2D

const cauldron_scene = preload("uid://cc1sqlrkpbmai")
const uuid_util = preload('res://addons/uuid/uuid.gd')
# uids of potion scenes


@onready var all_unlocked_potions: Array[Resource] = []

@export var new_timer_method: HTTPRequest
@export var plus_button: Control


func add_new_cauldron(button_position, _specs: Dictionary = {null: null}):
	var new_cauldron = cauldron_scene.instantiate()
	new_cauldron.position = button_position
	add_child(new_cauldron)


func _on_add_cauldron_pressed(extra_arg_0: Vector2) -> void:
	add_new_cauldron(extra_arg_0)
	plus_button.visible = false
