class_name IngredientResource
extends Resource

@export var id: String
@export var item_name: String # Use 'item_name' to avoid conflict with Node.name
@export_multiline var description: String
@export var icon: Texture2D
@export var rarity: Enums.Rarity