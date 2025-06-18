class_name RecipeResource
extends Resource

# The potion this recipe creates
@export var potion_id: String

# A dictionary where: key = ingredient_id (String), value = quantity (int)
@export var required_ingredients_dict: Dictionary[String, int]
@export var required_ingredients: Dictionary[IngredientResource, int]
