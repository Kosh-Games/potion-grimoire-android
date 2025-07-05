class_name PotionSelectItem
extends Panel

# A signal to notify the parent UI when this item is clicked.
signal potion_selected(potion_id)

# Nodes from the scene
@onready var icon_rect: TextureRect = $PotionIcon
@onready var name_label: Label = $PotionNameLabel
@onready var select_button: Button = $PotionIcon/SelectButton

# This will be set by the GrimoireUI when this item is created.
var potion_id: String

func _ready():
	# Connect the button's pressed signal to our own function.
	select_button.pressed.connect(_on_select_button_pressed)

# This function populates the UI element with data from a PotionResource.
func set_potion_data(potion_resource: PotionResource):
	self.potion_id = potion_resource.id
	name_label.text = potion_resource.item_name

	if potion_resource.icon:
		icon_rect.texture = potion_resource.icon
	else:
		# Set a placeholder texture if no icon is found
		icon_rect.texture = load("res://PotionMaking/Potions/placeholder_potion.png")

func _on_select_button_pressed():
	# When clicked, emit our custom signal with our stored potion_id.
	emit_signal("potion_selected", potion_id)
