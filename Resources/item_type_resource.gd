class_name ItemTypeResource
extends Resource

@export var type_id: String # This corresponds to the 'id' from your TimerItemType
@export var item_name: String
@export var max_level: int
@export var area: String # "Garden", "Brewery", etc.
@export var scene: PackedScene # A reference to the .tscn file for this item