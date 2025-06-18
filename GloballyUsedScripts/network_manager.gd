class_name NetworkManager
extends Node

# --- Basic Config ---
const uuid_util = preload('res://addons/uuid/uuid.gd')
# --- Server Configuration ---
@export var base_api_url: String = "https://grimoire-api-dev.kosh.games"

# --- Player State ---
var user_id: String = "d55e4905-610e-478a-930d-e3c05412f67c"


func initialize():
	_login()
	
func _login():
	var save_file_path: String = "user://player.save"
	var saved_id: String       = ""
	if FileAccess.file_exists(save_file_path):
		var file: FileAccess = FileAccess.open(save_file_path, FileAccess.READ)
		saved_id = file.get_line()
		file.close()

	if saved_id.is_empty():
		print('user_id was empty')
		saved_id = user_id

	var data_to_send: Dictionary = {"id": saved_id}
	var metadata: Dictionary = {"type": "login"}
	post_request("/users/login", data_to_send, metadata)


# --- GET Request Template ---
func get_request(endpoint: String, metadata: Dictionary):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed.bind(metadata, http_request))

	var url: String = "%s%s" % [base_api_url, endpoint]
	# GET requests don't have a body, so headers are simpler.
	var headers: Array[Variant] = ["Content-Type: application/json"]

	print("Sending GET request to '%s' with metadata: %s" % [endpoint, metadata])
	var error = http_request.request(url, headers, HTTPClient.METHOD_GET)
	if error != OK:
		printerr("HTTPRequest failed for '%s': %s" % [endpoint, error])
		http_request.queue_free()

# --- POST Request Template ---
func post_request(endpoint: String, data: Dictionary, metadata: Dictionary):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	
	http_request.request_completed.connect(_on_request_completed.bind(metadata, http_request))

	var url: String             = "%s%s" % [base_api_url, endpoint]
	var headers: Array[Variant] = ["Content-Type: application/json"]
	var body: String            = JSON.stringify(data)

	print("Sending POST to '%s' with metadata: %s" % [endpoint, metadata])
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		printerr("HTTPRequest failed for '%s': %s" % [endpoint, error])
		http_request.queue_free()

# --- Response Handling ---
func _on_request_completed(result, response_code, headers, body, metadata, request_node: HTTPRequest):
	var response_body = JSON.parse_string(body.get_string_from_utf8())
	var request_type = metadata.get("type", "unknown")

	if response_code != 200:
		printerr("API Error for '%s': Status %d, Body: %s" % [request_type, response_code, response_body])
		# You might want to add failure signals for get requests here too
		request_node.queue_free()
		return

	# On success, emit the correct signal on the bus
	match request_type:
		"login":
			if response_body.has("user_id"):
				PlayerData.user_id = response_body["user_id"]
			else:
				SignalBus.emit_signal("login_failed")
		"start_brewing":
			SignalBus.emit_signal("brew_started", metadata.get("item_id"), response_body)
		"collect_item":
			SignalBus.emit_signal("item_collected", metadata.get("item_id"), response_body)
			
		"fetch_item_types":
			SignalBus.emit_signal("item_types_received", response_body)

		"fetch_user_items":
			SignalBus.emit_signal("user_items_received", response_body)
			
		"get_ingredients":
			SignalBus.emit_signal("ingredients_received", response_body)

		"get_user_ingredients":
			SignalBus.emit_signal("user_ingredients_received", response_body)
			
		"get_potions":
			SignalBus.emit_signal("potions_received", response_body)

		"get_user_potions":
			SignalBus.emit_signal("user_potions_received", response_body)
			
		"get_recipes":
			SignalBus.emit_signal("recipes_received", response_body)

		_:
			print("Received response for unknown request type: ", request_type)

	request_node.queue_free()
