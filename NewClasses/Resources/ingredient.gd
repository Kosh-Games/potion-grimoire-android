class_name Ingredient
extends Resource


enum RARITY {
	BASIC = 0,
	SPECIAL = 1,
	RARE = 2,
	EPIC = 3
}


var item_uuid: uuid
@export var quantity: int
@export var rarity: RARITY
@export var text_name: String

const uuid_util = preload('res://addons/uuid/uuid.gd')


# TODO: check if this breaks any consistancy on reloads and if it needs to be saved locally
func _init() -> void:
	item_uuid = uuid_util.v4()

