extends Node2D

@export var level: int
@export var texture_pack: Dictionary =  {
	"empty": PackedScene,
	"boiling": PackedScene,
	'ready': PackedScene
}
@export var cauldron_id: uuid
@export var contents: Array = []





	
