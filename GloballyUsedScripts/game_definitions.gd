extends Node

# The dictionary is still here, but it's now populated automatically.
var definition_map: Dictionary = {}

# The path to your definition resource files.
const DEFINITIONS_PATH: String = "res://Resources/Definitions/"

func _ready() -> void:
	print("--- Loading all ItemDefinitions automatically ---")

	var dir: DirAccess = DirAccess.open(DEFINITIONS_PATH)
	if not dir:
		printerr("Failed to open ItemDefinitions directory: %s" % DEFINITIONS_PATH)
		return

	var file_names: PackedStringArray = dir.get_files()

	for file_name in file_names:
		var original_file_path: String = ""

		# First, check for the exported/remapped file extension.
		if file_name.ends_with(".tres.remap"):
			# If we find it, we want to load the *original* file name.
			# We get this by stripping the ".remap" suffix.
			original_file_path = DEFINITIONS_PATH + file_name.trim_suffix(".remap")

			# Else, check for the normal extension for when we are in the editor.
		elif file_name.ends_with(".tres"):
			original_file_path = DEFINITIONS_PATH + file_name

		# If we found a valid resource file path, load it.
		if not original_file_path.is_empty():
			var definition: ItemDefinition = load(original_file_path)

			if definition and not definition.item_type_id.is_empty():
				definition_map[definition.item_type_id] = definition
			else:
				printerr("Failed to load or invalid ItemDefinition at: %s" % original_file_path)

	print("Successfully loaded %d ItemDefinitions." % definition_map.size())


# The public function remains the same and works perfectly.
func get_definition(type_id: String) -> ItemDefinition:
	return definition_map.get(type_id)

