extends Node2D

@export var level: int
@export var texture_pack: Dictionary =  {
	"empty": PackedScene,
	"boiling": PackedScene,
	'ready': PackedScene
}
@export var cauldron_id: int
@export var contents: Array = []


func add_ingredient(item: Area2D) -> bool: 
	# retract amount from item
	item.specs.amount -= 1
	print(item.specs.id)
	print(item.specs.amount)
	print(item.specs.name)
	print(item.image.texture)
	contents += [item]
	print(contents[0].name)
	return true



	
