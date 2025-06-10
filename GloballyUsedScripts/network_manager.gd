class_name NetworkManager
extends Node

signal timer_start_request_completed(success: bool, data: Dictionary)
signal player_timers_request_completed(success: bool, data: Dictionary)


const SERVER_BASE_URL: String = "https://grimoire-api-dev.kosh.games" # Or your actual server URL
const TIMERS_ENDPOINT: String = "/timers"


var _http_request: HTTPRequest


const MOCK_USER_ID: String = "123e4567-e89b-12d3-a456-426614174000" # Replace with a valid UUID

func _ready():
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)


func _on_request_completed(response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	var response_data = null

	if error == OK:
		response_data = json.get_data()
	else:
		printerr("NetworkManager: JSON parsing error: ", json.get_error_message(), " in ", body.get_string_from_utf8())
		return

	var request_type = _http_request.get_meta("request_type", "unknown")

	if response_code >= 200 && response_code < 300:
		prints("NetworkManager: Request successful (", response_code, "): ", response_data)
		if request_type == "start_timer":
			timer_start_request_completed.emit(true, response_data)
		elif request_type == "get_player_timers":
			player_timers_request_completed.emit(true, response_data)
		else:
			printerr("NetworkManager: Unknown successful request type: ", request_type)
	else:
		printerr("NetworkManager: Request failed! Code: ", response_code, ", Body: ", response_data)
		if request_type == "start_timer":
			timer_start_request_completed.emit(false, response_data if response_data else str(response_code))
		elif request_type == "get_player_timers":
			player_timers_request_completed.emit(false, response_data if response_data else str(response_code))
		else:
			printerr("NetworkManager: Unknown failed request type: ", request_type)

func start_server_timer(duration_seconds: int, item_unique_id: String):
	var url: String             = SERVER_BASE_URL + TIMERS_ENDPOINT + "/timer/start"
	var headers: Array[Variant] = ["Content-Type: application/json"]
	var body: Dictionary        = {
											  "duration_seconds": duration_seconds,
											  "user_id": MOCK_USER_ID,
											  "item_id": item_unique_id
										  }

	_http_request.set_meta("request_type", "start_timer") # Mark what this request is for
	var error: int = _http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if error != OK:
		printerr("NetworkManager: An error occurred in HTTPRequest (start_server_timer): ", error)
		timer_start_request_completed.emit(false, "HTTPRequest error: " + str(error))


func fetch_player_timers():
	if MOCK_USER_ID == "":
		printerr("NetworkManager: MOCK_USER_ID is not set.")
		player_timers_request_completed.emit(false, "User ID not set.")
		return

	var url: String = "%s%s/%s" % [SERVER_BASE_URL, TIMERS_ENDPOINT, MOCK_USER_ID]
# For a GET request with path parameters, the body is not used.
# If TimersRequest was meant to be populated from query for GET:
# var url = SERVER_BASE_URL + TIMERS_ENDPOINT + "/some_path_if_any" + "?user_id=" + MOCK_USER_ID

	_http_request.set_meta("request_type", "get_player_timers")
	var error: int = _http_request.request(url, [], HTTPClient.METHOD_GET) # No body for GET
	
	if error != OK:
		printerr("NetworkManager: An error occurred in HTTPRequest (fetch_player_timers): ", error)
		player_timers_request_completed.emit(false, "HTTPRequest error: " + str(error))
