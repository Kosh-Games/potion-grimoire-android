extends Node2D

const cauldron_scene = preload("uid://cc1sqlrkpbmai")



@onready var all_unlocked_potions: Array[Resource] = []

@export var plus_button: Control
@export var TableContents: Control
@export var main_menu: Control
@export var back_button: TextureButton


func _ready() -> void:
	back_button.pressed.connect(on_back_button_pressed)


func add_new_cauldron(_button_position, _specs: Dictionary = {null: null}):
	var new_cauldron = cauldron_scene.instantiate()
	new_cauldron.position = plus_button.position
	TableContents.add_child(new_cauldron)


func _on_add_cauldron_pressed(extra_arg_0: Vector2) -> void:
	add_new_cauldron(extra_arg_0)
	plus_button.visible = false
	
	
func on_back_button_pressed():
	self.visible = false
	main_menu.visible = true