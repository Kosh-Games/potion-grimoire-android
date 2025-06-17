class_name PotionResource
extends Resource

@export var id: String
@export var item_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var recipe: Array[IngredientResource] # An array of required ingredients
@export var brew_time_seconds: int
@export var rarity: Enums.Rarity