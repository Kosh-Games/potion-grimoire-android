class_name IngredientSelectItem
extends Panel

signal chosen(ingredient_resource: IngredientResource)

@onready var icon: TextureRect = $Icon
@onready var name_label: Label = $NameLabel
@onready var select_button: Button = $Icon/SelectButton

var ingredient_resource: IngredientResource

func _ready():
	select_button.pressed.connect(func(): emit_signal("chosen", ingredient_resource))

func set_data(ingredient_resource_from_data: IngredientResource):
	self.ingredient_resource = ingredient_resource_from_data
	name_label.text = ingredient_resource.item_name
	if ingredient_resource.art_resource:
		icon.texture = ingredient_resource.art_resource.ui_icon
