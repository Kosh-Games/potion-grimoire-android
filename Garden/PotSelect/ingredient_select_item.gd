class_name IngredientSelectItem
extends Panel

signal chosen(ingredient_id)

@onready var icon: TextureRect = $Icon
@onready var name_label: Label = $NameLabel
@onready var select_button: Button = $SelectButton

var ingredient_id: String

func _ready():
	select_button.pressed.connect(func(): emit_signal("chosen", ingredient_id))

func set_data(ingredient_resource):
	self.ingredient_id = ingredient_resource.id
	name_label.text = ingredient_resource.item_name
	if ingredient_resource.art_resource:
		icon.texture = ingredient_resource.art_resource.ui_icon
